codeunit 51000 "BNS BAI2 Bank Import"
{
    var
        CurrentEntryNo: Integer;
        CurrentLineNo: Integer;
        CurrentAccountNo: Code[30];
        CurrentRecordContext: Enum "BNS BAI2 Context";

    procedure ImportFile(
       FileName: Text;
       InStream: InStream)
    var
        Line: Text;
        RecordType: Code[2];
        BCBankAccNo: Code[20];
    begin
        CurrentEntryNo :=
            CreateImportHeader(
                FileName);

        CurrentLineNo := 0;
        CurrentAccountNo := '';
        CurrentRecordContext := CurrentRecordContext::None;

        while not InStream.EOS() do begin
            InStream.ReadText(Line);

            Line := DelChr(Line, '<>', ' ');

            if Line = '' then
                continue;

            Line := RemoveRecordSeparator(Line);

            RecordType := GetRecordType(Line);

            case RecordType of
                '01':
                    Process01(Line);

                '02':
                    Process02(Line);

                '03':
                    Process03(Line, BCBankAccNo);

                '16':
                    Process16(Line);

                '88':
                    Process88(Line);

                '49':
                    Process49(Line);

                '98':
                    Process98(Line);

                '99':
                    Process99(Line);

                else
                    Error(
                        'Unsupported BAI2 record type %1.',
                        RecordType);
            end;
        end;

        CreateBankReconciliation(
            CurrentEntryNo,
            BCBankAccNo);
    end;

    local procedure CreateImportHeader(
    FileName: Text): Integer
    var
        Header: Record "BNS BAI2 Import Header";
    begin
        Header.Init();

        Header."File Name" :=
            CopyStr(
                FileName,
                1,
                MaxStrLen(Header."File Name"));

        // Header."BC Bank Account No." :=
        //     BCBankAccountNo;

        Header.Status :=
            Header.Status::Imported;

        Header.Insert(true);

        exit(Header."Entry No.");
    end;

    local procedure GetStatementNo(
    BCBankAccountNo: Code[20];
    StatementDate: Date): Code[20]
    var
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BaseStatementNo: Code[20];
        StatementNo: Code[20];
        Suffix: Integer;
    begin
        BaseStatementNo :=
            CopyStr(
                'BNS-' +
                Format(
                    StatementDate,
                    0,
                    '<Year4><Month,2><Day,2>'),
                1,
                20);

        StatementNo := BaseStatementNo;

        BankAccRecon.SetRange(
            "Bank Account No.",
            BCBankAccountNo);

        BankAccRecon.SetRange(
            "Statement No.",
            StatementNo);

        while BankAccRecon.FindFirst() do begin

            Suffix += 1;

            StatementNo :=
                CopyStr(
                    BaseStatementNo +
                    '-' +
                    Format(Suffix),
                    1,
                    20);

            BankAccRecon.SetRange(
                "Statement No.",
                StatementNo);
        end;

        exit(StatementNo);
    end;

    local procedure CalculateAccountControlTotal(): Decimal
    var
        ImportLine: Record "BNS BAI2 Import Line";
        TotalAmount: Decimal;
    begin
        ImportLine.SetRange(
            "Entry No.",
            CurrentEntryNo);

        if ImportLine.FindSet() then
            repeat
                TotalAmount +=
                    ImportLine."Transaction Amount";
            until ImportLine.Next() = 0;

        exit(TotalAmount);
    end;

    local procedure GetBCBankAccount(
    BCBankAccountNo: Code[20]): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        if not BankAccount.Get(BCBankAccountNo) then
            Error(
                'Bank Account %1 does not exist.',
                BCBankAccountNo);

        exit(BankAccount."No.");
    end;

    local procedure Process01(Line: Text)
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        Header."Sender ID" :=
            CopyStr(Fields.Get(2), 1, MaxStrLen(Header."Sender ID"));

        Header."Receiver ID" :=
            CopyStr(Fields.Get(3), 1, MaxStrLen(Header."Receiver ID"));

        Header.Modify();
    end;

    local procedure Process02(Line: Text)
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        Header."Statement Date" :=
            ConvertBNSDate(Fields.Get(5));

        Header."Currency Code" :=
            CopyStr(
                Fields.Get(7),
                1,
                MaxStrLen(Header."Currency Code"));

        Header.Modify();
    end;

    local procedure Process03(Line: Text; var BCBankAccNo: Code[20])
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        CurrentAccountNo :=
            CopyStr(
                Fields.Get(2),
                1,
                MaxStrLen(Header."BAI2 Account No."));

        Header."BAI2 Account No." :=
            CurrentAccountNo;
        BCBankAccNo := CopyStr(CurrentAccountNo, StrLen(CurrentAccountNo) - 3, StrLen(CurrentAccountNo));
        Header."BC Bank Account No." := CopyStr(CurrentAccountNo, StrLen(CurrentAccountNo) - 3, StrLen(CurrentAccountNo));

        Header."Currency Code" :=
            CopyStr(
                Fields.Get(3),
                1,
                MaxStrLen(Header."Currency Code"));

        Header."Closing Balance" :=
            BAI2Amount(Fields.Get(5));

        Header."Total Credits" :=
            BAI2Amount(Fields.Get(7));

        Header."Credit Count" :=
            BAI2Integer(Fields.Get(8));

        Header.Modify();

        CurrentRecordContext :=
            CurrentRecordContext::AccountHeader;
    end;

    local procedure Process88(Line: Text)
    begin
        case CurrentRecordContext of
            CurrentRecordContext::AccountHeader:
                ProcessAccountHeader88(Line);

            CurrentRecordContext::Transaction:
                ProcessTransaction88(Line);

            else
                Error(
                    'BAI2 88 record found without a valid context.');
        end;
    end;

    local procedure ProcessAccountHeader88(Line: Text)
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        /*
          400 = Debit Total Transaction Code
        */

        Header."Total Debits" :=
            BAI2Amount(Fields.Get(3));

        Header."Debit Count" :=
            BAI2Integer(Fields.Get(4));

        Header.Modify();
    end;

    local procedure Process16(Line: Text)
    var
        ImportLine: Record "BNS BAI2 Import Line";
        Fields: List of [Text];
        TransactionCode: Code[3];
        Amount: Decimal;
        TransactionText: Text;
    begin
        Fields := SplitLine(Line);

        CurrentLineNo += 1;

        TransactionCode :=
            CopyStr(
                Fields.Get(2),
                1,
                MaxStrLen(ImportLine."Transaction Code"));

        Amount :=
            BAI2Amount(Fields.Get(3));

        TransactionText := GetTransactionText(Fields);

        ImportLine.Init();

        ImportLine."Entry No." := CurrentEntryNo;
        ImportLine."Line No." := CurrentLineNo;

        ImportLine."Account No." := CurrentAccountNo;

        ImportLine."Transaction Code" :=
            TransactionCode;

        ImportLine."Transaction Amount" :=
            GetSignedAmount(
                TransactionCode,
                Amount);

        ImportLine."Financial Effect" :=
            GetFinancialEffect(TransactionCode);

        ImportLine."Funds Type" :=
            CopyStr(
                Fields.Get(4),
                1,
                MaxStrLen(ImportLine."Funds Type"));

        ImportLine."Transaction Date" :=
            ConvertBNSDate(Fields.Get(5));

        ImportLine."Transaction Text" :=
            CopyStr(
                TransactionText,
                1,
                MaxStrLen(ImportLine."Transaction Text"));

        ImportLine."Cheque No." :=
            ExtractChequeNo(TransactionText);

        ImportLine.Insert();

        CurrentRecordContext := CurrentRecordContext::Transaction;
    end;

    local procedure BAI2Amount(Value: Text): Decimal
    var
        Amount: Decimal;
        Sign: Integer;
    begin
        Value := DelChr(Value, '<>', ' ');

        if Value = '' then
            exit(0);

        Sign := 1;

        if CopyStr(Value, 1, 1) = '-' then begin
            Sign := -1;
            Value := CopyStr(Value, 2);
        end else
            if CopyStr(Value, 1, 1) = '+' then
                Value := CopyStr(Value, 2);

        if not Evaluate(Amount, Value) then
            Error(
                'Invalid BAI2 amount %1.',
                Value);

        exit(Sign * Amount / 100);
    end;



    local procedure GetFinancialEffect(
    TransactionCode: Code[3]): Enum "BNS Financial Effect"
    begin
        case TransactionCode of

            '165',
            '171',
            '174',
            '184',
            '195',
            '213',
            '238',
            '240',
            '241',
            '275',
            '344',
            '354',
            '357',
            '395',
            '399':
                exit("BNS Financial Effect"::Credit);

            '469',
            '474',
            '475',
            '481',
            '484',
            '495',
            '512',
            '533',
            '541',
            '555',
            '567',
            '575',
            '631',
            '644',
            '695',
            '698',
            '699':
                exit("BNS Financial Effect"::Debit);
        end;

        exit("BNS Financial Effect"::Unknown);
    end;

    local procedure GetSignedAmount(
    TransactionCode: Code[3];
    Amount: Decimal): Decimal
    var
        FinancialEffect: Enum "BNS Financial Effect";
    begin
        FinancialEffect :=
            GetFinancialEffect(TransactionCode);

        case FinancialEffect of
            FinancialEffect::Debit:
                exit(-Abs(Amount));

            FinancialEffect::Credit:
                exit(Abs(Amount));

            else
                exit(Amount);
        end;
    end;

    local procedure ProcessTransaction88(Line: Text)
    var
        ImportLine: Record "BNS BAI2 Import Line";
        Fields: List of [Text];
        ContinuationText: Text;
    begin
        Fields := SplitLine(Line);

        ImportLine.SetRange("Entry No.", CurrentEntryNo);
        ImportLine.SetRange("Line No.", CurrentLineNo);

        if not ImportLine.FindFirst() then
            Error(
                'Transaction continuation found without transaction.');

        ContinuationText := Fields.Get(2);

        ImportLine."Transaction Text" :=
            CopyStr(
                ImportLine."Transaction Text" + ' ' + ContinuationText,
                1,
                MaxStrLen(ImportLine."Transaction Text"));

        ImportLine.Modify();
    end;

    local procedure ExtractChequeNo(TransactionText: Text): Code[20]
    var
        StartPos: Integer;
        RemainingText: Text;
        EndPos: Integer;
    begin
        StartPos := StrPos(TransactionText, 'CHEQUE~');

        if StartPos = 0 then
            exit('');

        RemainingText :=
            CopyStr(
                TransactionText,
                StartPos + StrLen('CHEQUE~'));

        EndPos := StrPos(RemainingText, '~');

        if EndPos > 0 then
            RemainingText :=
                CopyStr(RemainingText, 1, EndPos - 1);

        exit(CopyStr(RemainingText, 1, 20));
    end;

    local procedure GetTransactionText(
    Fields: List of [Text]): Text
    var
        I: Integer;
        ResultText: Text;
    begin
        /*
          Fields 6 onwards contain transaction text
          according to the selected BAI2 text option.
        */

        for I := 6 to Fields.Count() do begin
            if Fields.Get(I) = '' then
                continue;

            if ResultText <> '' then
                ResultText += ' ';

            ResultText += Fields.Get(I);
        end;

        exit(ResultText);
    end;

    local procedure Process49(Line: Text)
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        Header."Account Control Total" :=
            BAI2Amount(Fields.Get(2));

        Header."Account Control Count" :=
            BAI2Integer(Fields.Get(3));

        Header.Modify();

        CurrentRecordContext := CurrentRecordContext::None;
    end;

    local procedure Process98(Line: Text)
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        Header."Group Control Total" :=
            BAI2Amount(Fields.Get(2));

        Header.Modify();
    end;

    local procedure Process99(Line: Text)
    var
        Header: Record "BNS BAI2 Import Header";
        Fields: List of [Text];
    begin
        Header.Get(CurrentEntryNo);

        Fields := SplitLine(Line);

        Header."File Control Total" :=
            BAI2Amount(Fields.Get(2));

        Header.Status :=
            Header.Status::Validated;

        Header.Modify();
    end;

    local procedure GetRecordType(Line: Text): Code[2]
    begin
        exit(CopyStr(Line, 1, 2));
    end;

    local procedure RemoveRecordSeparator(Line: Text): Text
    begin
        if CopyStr(Line, StrLen(Line), 1) = '/' then
            Line := CopyStr(Line, 1, StrLen(Line) - 1);

        exit(Line);
    end;

    local procedure SplitLine(Line: Text): List of [Text]
    var
        Fields: List of [Text];
    begin
        Fields := Line.Split(',');
        exit(Fields);
    end;

    local procedure BAI2Integer(Value: Text): Integer
    var
        Number: Integer;
    begin
        Value := DelChr(Value, '<>', ' ');

        if Value = '' then
            exit(0);

        if not Evaluate(Number, Value) then
            Error(
                'Invalid BAI2 integer %1.',
                Value);

        exit(Number);
    end;

    local procedure ConvertBNSDate(DateText: Text): Date
    var
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        if StrLen(DateText) <> 6 then
            Error(
                'Invalid BAI2 date %1.',
                DateText);

        Year :=
            2000 +
            BAI2Integer(CopyStr(DateText, 1, 2));

        Month :=
            BAI2Integer(CopyStr(DateText, 3, 2));

        Day :=
            BAI2Integer(CopyStr(DateText, 5, 2));

        exit(DMY2Date(Day, Month, Year));
    end;


    local procedure CreateReconciliationLine(
    BankAccRecon: Record "Bank Acc. Reconciliation";
    ImportLine: Record "BNS BAI2 Import Line";
    StatementLineNo: Integer)
    var
        ReconLine: Record "Bank Acc. Reconciliation Line";
    begin
        ReconLine.Init();

        ReconLine."Bank Account No." :=
            BankAccRecon."Bank Account No.";

        ReconLine."Statement No." :=
            BankAccRecon."Statement No.";

        ReconLine."Statement Line No." :=
            StatementLineNo;

        ReconLine."Transaction Date" :=
            ImportLine."Transaction Date";

        ReconLine."Statement Amount" :=
            ImportLine."Transaction Amount";

        ReconLine."Check No." :=
            ImportLine."Cheque No.";

        ReconLine.Description :=
            ImportLine."Transaction Text";

        ReconLine."Additional Transaction Info" :=
            ImportLine."Transaction Code";

        ReconLine.Insert(true);
    end;

    local procedure CreateBankReconciliation(
    ImportEntryNo: Integer;
    BCBankAccountNo: Code[20])
    var
        Header: Record "BNS BAI2 Import Header";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        StatementNo: Code[20];
    begin
        Header.Get(ImportEntryNo);

        if Header.Status <> Header.Status::Validated then
            Error(
                'BAI2 file has not passed validation.');

        StatementNo :=
            GetStatementNo(
                BCBankAccountNo,
                Header."Statement Date");

        BankAccRecon.Init();

        BankAccRecon."Bank Account No." :=
            GetBCBankAccount(BCBankAccountNo);

        BankAccRecon."Statement No." :=
            StatementNo;

        BankAccRecon."Statement Date" :=
            Header."Statement Date";

        BankAccRecon."Statement Ending Balance" :=
            Header."Closing Balance";

        BankAccRecon.Insert(true);

        CreateReconciliationLines(
            BankAccRecon,
            ImportEntryNo);

        Header.Status :=
            Header.Status::ReconciliationCreated;

        Header.Modify();
    end;

    local procedure CreateReconciliationLines(
      BankAccRecon: Record "Bank Acc. Reconciliation";
      ImportEntryNo: Integer)
    var
        ImportLine: Record "BNS BAI2 Import Line";
        ReconLine: Record "Bank Acc. Reconciliation Line";
        StatementLineNo: Integer;
    begin
        ImportLine.SetRange(
            "Entry No.",
            ImportEntryNo);

        if ImportLine.FindSet() then
            repeat
                StatementLineNo += 1;

                ReconLine.Init();

                ReconLine."Bank Account No." :=
                    BankAccRecon."Bank Account No.";

                ReconLine."Statement No." :=
                    BankAccRecon."Statement No.";

                ReconLine."Statement Line No." :=
                    StatementLineNo;

                ReconLine."Transaction Date" :=
                    ImportLine."Transaction Date";

                ReconLine."Statement Amount" :=
                    ImportLine."Transaction Amount";

                ReconLine."Check No." :=
                    ImportLine."Cheque No.";

                ReconLine.Description :=
                    CopyStr(
                        ImportLine."Transaction Text",
                        1,
                        MaxStrLen(ReconLine.Description));

                ReconLine."Additional Transaction Info" :=
                    ImportLine."Transaction Code";

                ReconLine.Insert(true);

            until ImportLine.Next() = 0;
    end;
}