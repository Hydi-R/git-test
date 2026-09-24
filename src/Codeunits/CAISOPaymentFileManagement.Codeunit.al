/// <summary>
/// Deloitte AK 05092026
///     <NEW> New object created </NEW>
/// </summary>
codeunit 51001 CAISOPaymentFileManagement
{
    var
        IntegrationSetup: Record CAIntegrationSetup;
        NoPaymentLinesFoundMsg: Label 'No payment lines were found.';
        MsgIDNoSeriesNotSetupMsg: Label 'Message ID No. Series must be configured in Integration Setup.';

    procedure GeneratePaymentISOFile(var GenJournalLine: Record "Gen. Journal Line"; DownloadFile: Boolean)
    var
        EFTLines: List of [Dictionary of [Text, Text]];
        EMTLines: List of [Dictionary of [Text, Text]];
        CHQLines: List of [Dictionary of [Text, Text]];
        XMLDoc: XmlDocument;
        XmlRoot: XmlElement;
        Initn: XmlElement;
        TotalTransactions: Integer;
        TotalAmount: Decimal;
        MsgId: Text;
        InStream: InStream;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        CASharepoint: Codeunit CASharepointManagement;
        CAIntegrationSetup: Record CAIntegrationSetup;
        CASFTPLogs: Record CASFTPLogs; // Deloitte AK 11092026
        XMLText: Text; // Deloitte AK 16092026
    begin
        CAIntegrationSetup.Get();
        CollectPaymentLines(GenJournalLine, EFTLines, EMTLines, CHQLines);

        TotalTransactions := EFTLines.Count() + EMTLines.Count() + CHQLines.Count();

        if TotalTransactions = 0 then
            Error(NoPaymentLinesFoundMsg);

        TotalAmount := GetListTotal(EFTLines) + GetListTotal(EMTLines) + GetListTotal(CHQLines);

        MsgId := GetMessageID(DownloadFile);

        FileName := MsgId + '.PA001V3'; // Deloitte AK 11092026

        CreateDocument(XMLDoc, XmlRoot);

        Initn := XmlElement.Create('CstmrCdtTrfInitn');
        XmlRoot.Add(Initn);

        CreateGroupHeader(Initn, MsgId, TotalTransactions, TotalAmount);

        if EFTLines.Count() > 0 then
            CreateEFTPaymentInformation(Initn, EFTLines, CASFTPLogs);

        if EMTLines.Count() > 0 then
            CreateEMTPaymentInformation(Initn, EMTLines, CASFTPLogs);

        if CHQLines.Count() > 0 then
            CreateChequePaymentInformation(Initn, CHQLines, CASFTPLogs);

        // Message(FormatXML(XMLDoc));

        XMLDoc.WriteTo(XMLText);

        XMLText := XMLText.Replace(' xmlns=""', '');
        XMLText := XMLText.Replace('utf-16', 'utf-8');

        XmlDocument.ReadFrom(XMLText, XMLDoc);

        TempBlob.CreateOutStream(OutStream);
        XMLDoc.WriteTo(OutStream);
        //RH 070926++
        if DownloadFile then begin
            TempBlob.CreateInStream(InStream);
            DownloadFromStream(InStream, '', '', '', FileName);
        end else begin
            CASharepoint.ImportManualFile(TempBlob, FileName);
            // Deloitte AK 11092026++
            CreateSFTPLog(CASFTPLogs, CAIntegrationSetup."Payment Template", CAIntegrationSetup."Payment Batch", MsgId, FileName);

            CreateSFTPLogLinesAndUpdateStatus(GenJournalLine, CASFTPLogs, MsgId);

            // Deloitte AK 11092026--
            //RH 070926++
        end;
    end;

    local procedure GetMessageID(DownloadFile: Boolean): Code[20]
    var
        CAIntegrationSetup: Record CAIntegrationSetup;
        NoSeries: Codeunit "No. Series";
    begin
        CAIntegrationSetup.Get();

        if CAIntegrationSetup."Msg ID No. Series" = '' then
            Error(MsgIDNoSeriesNotSetupMsg);

        if DownloadFile then
            exit(NoSeries.PeekNextNo(CAIntegrationSetup."Msg ID No. Series"))
        else
            exit(NoSeries.GetNextNo(CAIntegrationSetup."Msg ID No. Series", Today(), true));
    end;


    // ============================================================
    // COLLECT PAYMENT JOURNAL LINES
    // ============================================================

    local procedure CollectPaymentLines(
        var GenJournalLine: Record "Gen. Journal Line";
        var EFTLines: List of [Dictionary of [Text, Text]];
        var EMTLines: List of [Dictionary of [Text, Text]];
        var CHQLines: List of [Dictionary of [Text, Text]])
    var
        GenJnlLine2: Record "Gen. Journal Line";
        ClaimIDs: Dictionary of [Text, Boolean];
    begin
        GenJnlLine2.Copy(GenJournalLine);
        ValidateClaimIDInCurrentBatch(GenJnlLine2, ClaimIDs);
        if GenJnlLine2.FindSet() then
            repeat
                case GenJnlLine2."Payment Method Code" of
                    'EFT':
                        AddEFTLine(GenJnlLine2, EFTLines);

                    'EMT':
                        AddEMTLine(GenJnlLine2, EMTLines);

                    'CHEQUE':
                        begin
                            AddChequeLine(GenJnlLine2, CHQLines);
                        end;
                end;
            until GenJnlLine2.Next() = 0;
    end;


    // ============================================================
    // EFT
    // ============================================================

    local procedure AddEFTLine(GenJournalLine: Record "Gen. Journal Line"; var EFTLines: List of [Dictionary of [Text, Text]])
    var
        Line: Dictionary of [Text, Text];
    begin
        Line.Add('ClaimID', GenJournalLine."Claim ID");
        Line.Add('Name', GenJournalLine."Claimant Name");
        Line.Add('Amount', FormatDecimal(Abs(GenJournalLine.Amount)));
        Line.Add('Institution', GenJournalLine."Claimant Institution No.");
        Line.Add('Transit', GenJournalLine."Claimant Transit No.");
        Line.Add('Account', GenJournalLine."Claimant Account No.");
        Line.Add('DebtorAccount', GetDebtorAccountOrCPAID(GenJournalLine, true));
        Line.Add('DebtorCPA', GetDebtorAccountOrCPAID(GenJournalLine, false));
        EFTLines.Add(Line);
    end;


    // ============================================================
    // EMT
    // ============================================================

    local procedure AddEMTLine(GenJournalLine: Record "Gen. Journal Line"; var EMTLines: List of [Dictionary of [Text, Text]])
    var
        Line: Dictionary of [Text, Text];
    begin
        Line.Add('ClaimID', GenJournalLine."Claim ID");
        Line.Add('Name', GenJournalLine."Claimant Name");
        Line.Add('Amount', FormatDecimal(Abs(GenJournalLine.Amount)));
        Line.Add('Email', GenJournalLine."Claimant Email");
        Line.Add('Password', GenJournalLine."Claimant Password");
        Line.Add('SecurityQuestion', GenJournalLine."Security Question");
        Line.Add('Memo', GenJournalLine.Memo);
        Line.Add('DebtorAccount', GetDebtorAccountOrCPAID(GenJournalLine, true));
        Line.Add('DebtorCPA', GetDebtorAccountOrCPAID(GenJournalLine, false));
        EMTLines.Add(Line);
    end;


    // ============================================================
    // CHEQUE
    // ============================================================

    local procedure AddChequeLine(GenJournalLine: Record "Gen. Journal Line"; var CHQLines: List of [Dictionary of [Text, Text]])
    var
        Line: Dictionary of [Text, Text];
        DimensionValue: Record "Dimension Value";
        GenLedgerSetup: Record "General Ledger Setup";
    begin
        Line.Add('ClaimID', GenJournalLine."Claim ID");
        Line.Add('Name', GenJournalLine."Claimant Name");
        Line.Add('Amount', FormatDecimal(Abs(GenJournalLine.Amount)));
        Line.Add('ChequeNo', GenJournalLine."Cheque No.");
        Line.Add('Address', GenJournalLine."Claimant Mailing Address");
        AddMailingAddressParts(Line, GenJournalLine."Claimant Mailing Address");
        Line.Add('DeliveryMethod', GenJournalLine."Cheque Delivery Method");
        Line.Add('Estate', GenJournalLine."Cheque Estate");
        Line.Add('DebtorAccount', GetDebtorAccountOrCPAID(GenJournalLine, true));
        Line.Add('DebtorCPA', GetDebtorAccountOrCPAID(GenJournalLine, false));
        If GenLedgerSetup.Get() then begin
            if DimensionValue.Get(GenLedgerSetup."Global Dimension 1 Code", GenJournalLine."Shortcut Dimension 1 Code") then
                Line.Add('ProjectName', DimensionValue.Name)
            else
                Line.Add('ProjectName', '');
        end;
        Line.Add('ProjectNotice', GenJournalLine."Project Notice");
        CHQLines.Add(Line);
    end;

    local procedure GetDebtorAccountOrCPAID(GenJournalLine: Record "Gen. Journal Line"; DebtorID: Boolean): Text
    var
        BankAccount: Record "Bank Account";
        InstitutionNumber: Text;
        BranchNumber: Text;
    begin
        if GenJournalLine."Bal. Account No." = '' then
            Error('Balancing Bank Account is required to generate the ISO payment file for Claim ID %1.', GenJournalLine."Claim ID");
        if not BankAccount.Get(GenJournalLine."Bal. Account No.") then
            Error('Bank Account %1 was not found for Claim ID %2.', GenJournalLine."Bal. Account No.", GenJournalLine."Claim ID");

        if DebtorID then
            exit(BankAccount."Bank Account No.");

        InstitutionNumber := PadLeft(Format(BankAccount."Institution Number"), 3);
        BranchNumber := PadLeft(BankAccount."Bank Branch No.", 5);
        exit('CACPA' + InstitutionNumber + BranchNumber);
    end;

    local procedure AddMailingAddressParts(var Line: Dictionary of [Text, Text]; MailingAddress: Text)
    var
        AddressParts: List of [Text];
    begin
        AddressParts := MailingAddress.Split(',');
        if AddressParts.Count() <> 6 then
            Error('Mailing Address must contain exactly six comma-separated parts. Value: %1', MailingAddress);

        Line.Add('AddressLine1', AddressParts.Get(1).Trim());
        Line.Add('AddressLine2', AddressParts.Get(2).Trim());
        Line.Add('City', AddressParts.Get(3).Trim());
        Line.Add('Province', AddressParts.Get(4).Trim());
        Line.Add('PostalCode', AddressParts.Get(5).Trim());
        Line.Add('Country', AddressParts.Get(6).Trim());
    end;


    // ============================================================
    // GROUP HEADER
    // ============================================================

    local procedure CreateGroupHeader(Initn: XmlElement; MsgId: Text; TotalTransactions: Integer; TotalAmount: Decimal)
    var
        GrpHdr: XmlElement;
        InitgPty: XmlElement;
        Id: XmlElement;
        OrgId: XmlElement;
        Othr: XmlElement;
        Authstn: XmlElement;
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        IntegrationSetup.Get();
        GrpHdr := XmlElement.Create('GrpHdr');
        Initn.Add(GrpHdr);
        AddTextElement(GrpHdr, 'MsgId', MsgId);
        AddTextElement(GrpHdr, 'CreDtTm', GetCurrentUTCDateTime());

        Authstn := XmlElement.Create('Authstn');
        GrpHdr.Add(Authstn);

        // if EnvironmentInfo.IsSandbox() then
        //     AddTextElement(Authstn, 'Prtry', 'T')

        // else if EnvironmentInfo.IsProduction() then
        AddTextElement(Authstn, 'Prtry', 'P');

        AddTextElement(GrpHdr, 'NbOfTxs', Format(TotalTransactions));
        AddTextElement(GrpHdr, 'CtrlSum', FormatDecimal(TotalAmount));
        InitgPty := XmlElement.Create('InitgPty');
        GrpHdr.Add(InitgPty);

        AddTextElement(InitgPty, 'Nm', IntegrationSetup."Sender Name");
        Id := XmlElement.Create('Id');
        InitgPty.Add(Id);
        OrgId := XmlElement.Create('OrgId');
        Id.Add(OrgId);
        Othr := XmlElement.Create('Othr');
        OrgId.Add(Othr);
        AddTextElement(Othr, 'Id', IntegrationSetup."Sender ID");
    end;


    // ============================================================
    // EFT PAYMENT INFORMATION
    // ============================================================

    local procedure CreateEFTPaymentInformation(Initn: XmlElement; EFTLines: List of [Dictionary of [Text, Text]]; var SFTPLogs: Record CASFTPLogs)
    var
        PmtInf: XmlElement;
        PmtTpInf: XmlElement;
        LclInstrm: XmlElement;
        Dbtr: XmlElement;
        PstlAdr: XmlElement;
        DbtrAcct: XmlElement;
        Id: XmlElement;
        Othr: XmlElement;
        DbtrAgt: XmlElement;
        FinInstnId: XmlElement;
        ClrSysMmbId: XmlElement;
        Line: Dictionary of [Text, Text];
        Index: Integer;
    begin
        IntegrationSetup.Get();
        PmtInf := XmlElement.Create('PmtInf');
        Initn.Add(PmtInf);

        AddTextElement(PmtInf, 'PmtInfId', 'EFT-' + PadID(1, 3));

        AddTextElement(PmtInf, 'PmtMtd', 'TRF');

        AddTextElement(PmtInf, 'NbOfTxs', Format(EFTLines.Count()));

        AddTextElement(PmtInf, 'CtrlSum', FormatDecimal(GetListTotal(EFTLines)));

        PmtTpInf := XmlElement.Create('PmtTpInf');
        PmtInf.Add(PmtTpInf);

        LclInstrm := XmlElement.Create('LclInstrm');
        PmtTpInf.Add(LclInstrm);

        AddTextElement(LclInstrm, 'Prtry', 'EFT');

        AddTextElement(PmtInf, 'ReqdExctnDt', Format(CalcDate('<+' + Format(IntegrationSetup."EFT Execution Offset Days") + 'D>', Today()), 0, 9)); // Pending

        Dbtr := XmlElement.Create('Dbtr');
        PmtInf.Add(Dbtr);

        AddTextElement(Dbtr, 'Nm', IntegrationSetup."Sender Name");

        PstlAdr := XmlElement.Create('PstlAdr');
        Dbtr.Add(PstlAdr);

        AddTextElement(PstlAdr, 'TwnNm', 'Toronto'); // Integration Setup
        AddTextElement(PstlAdr, 'Ctry', 'CA');
        AddTextElement(PstlAdr, 'AdrLine', 'Toronto');

        DbtrAcct := XmlElement.Create('DbtrAcct');
        PmtInf.Add(DbtrAcct);

        Id := XmlElement.Create('Id');
        DbtrAcct.Add(Id);

        Othr := XmlElement.Create('Othr');
        Id.Add(Othr);

        AddTextElement(Othr, 'Id', GetValue(EFTLines.Get(1), 'DebtorAccount'));

        AddTextElement(DbtrAcct, 'Ccy', IntegrationSetup."Currency Code");

        DbtrAgt := XmlElement.Create('DbtrAgt');
        PmtInf.Add(DbtrAgt);

        FinInstnId := XmlElement.Create('FinInstnId');
        DbtrAgt.Add(FinInstnId);

        ClrSysMmbId := XmlElement.Create('ClrSysMmbId');
        FinInstnId.Add(ClrSysMmbId);

        AddTextElement(ClrSysMmbId, 'MmbId', GetValue(EFTLines.Get(1), 'DebtorCPA'));

        for Index := 1 to EFTLines.Count() do begin
            Line := EFTLines.Get(Index);

            CreateEFTTransaction(PmtInf, Line, Index);
        end;
    end;


    local procedure CreateEFTTransaction(PmtInf: XmlElement; Line: Dictionary of [Text, Text]; Index: Integer)
    var
        Tx: XmlElement;
        PmtId: XmlElement;
        Amt: XmlElement;
        InstdAmt: XmlElement;
        CdtrAgt: XmlElement;
        FinInstnId: XmlElement;
        PstlAdr: XmlElement;
        ClrSysMmbId: XmlElement;
        Cdtr: XmlElement;
        CdtrAcct: XmlElement;
        Id: XmlElement;
        Othr: XmlElement;
        Purp: XmlElement;
        Routing: Text;
    begin
        IntegrationSetup.Get();
        Tx := XmlElement.Create('CdtTrfTxInf');
        PmtInf.Add(Tx);

        PmtId := XmlElement.Create('PmtId');
        Tx.Add(PmtId);

        AddTextElement(PmtId, 'InstrId', 'TRACE' + PadID(Index, 6));

        AddTextElement(PmtId, 'EndToEndId', GetValue(Line, 'ClaimID'));

        Amt := XmlElement.Create('Amt');
        Tx.Add(Amt);

        InstdAmt := XmlElement.Create('InstdAmt');
        InstdAmt.SetAttribute('Ccy', IntegrationSetup."Currency Code");

        InstdAmt.Add(XmlText.Create(GetValue(Line, 'Amount')));

        Amt.Add(InstdAmt);

        Routing := 'CACPA0' + PadLeft(GetValue(Line, 'Institution'), 3) + PadLeft(GetValue(Line, 'Transit'), 5);

        CdtrAgt := XmlElement.Create('CdtrAgt');
        Tx.Add(CdtrAgt);

        FinInstnId := XmlElement.Create('FinInstnId');
        CdtrAgt.Add(FinInstnId);

        ClrSysMmbId := XmlElement.Create('ClrSysMmbId');
        FinInstnId.Add(ClrSysMmbId);

        AddTextElement(ClrSysMmbId, 'MmbId', Routing);

        PstlAdr := XmlElement.Create('PstlAdr');
        FinInstnId.Add(PstlAdr);

        AddTextElement(PstlAdr, 'Ctry', 'CA');

        Cdtr := XmlElement.Create('Cdtr');
        Tx.Add(Cdtr);

        AddTextElement(Cdtr, 'Nm', GetValue(Line, 'Name'));

        CdtrAcct := XmlElement.Create('CdtrAcct');
        Tx.Add(CdtrAcct);

        Id := XmlElement.Create('Id');
        CdtrAcct.Add(Id);

        Othr := XmlElement.Create('Othr');
        Id.Add(Othr);

        AddTextElement(Othr, 'Id', GetValue(Line, 'Account'));

        Purp := XmlElement.Create('Purp');
        Tx.Add(Purp);

        AddTextElement(Purp, 'Prtry', IntegrationSetup."EFT Purpose Code");
    end;

    // ============================================================
    // EMT PAYMENT INFORMATION
    // ============================================================

    local procedure CreateEMTPaymentInformation(Initn: XmlElement; EMTLines: List of [Dictionary of [Text, Text]]; var SFTPLogs: Record CASFTPLogs)
    var
        PmtInf: XmlElement;
        PmtTpInf: XmlElement;
        LclInstrm: XmlElement;
        Dbtr: XmlElement;
        DbtrAcct: XmlElement;
        Id: XmlElement;
        Othr: XmlElement;
        DbtrAgt: XmlElement;
        FinInstnId: XmlElement;
        ClrSysMmbId: XmlElement;
        ClrSysId: XmlElement;
        Line: Dictionary of [Text, Text];
        Index: Integer;
    begin
        IntegrationSetup.Get();
        PmtInf := XmlElement.Create('PmtInf');
        Initn.Add(PmtInf);

        AddTextElement(PmtInf, 'PmtInfId', 'EMT-' + PadID(1, 3));

        AddTextElement(PmtInf, 'PmtMtd', 'TRF');

        AddTextElement(PmtInf, 'NbOfTxs', Format(EMTLines.Count()));

        AddTextElement(PmtInf, 'CtrlSum', FormatDecimal(GetListTotal(EMTLines)));

        PmtTpInf := XmlElement.Create('PmtTpInf');
        PmtInf.Add(PmtTpInf);

        AddTextElement(PmtTpInf, 'InstrPrty', 'NORM');

        LclInstrm := XmlElement.Create('LclInstrm');
        PmtTpInf.Add(LclInstrm);

        AddTextElement(LclInstrm, 'Prtry', 'EMT');

        AddTextElement(PmtInf, 'ReqdExctnDt', Format(CalcDate('<+' + Format(IntegrationSetup."EMT Execution Offset Days") + 'D>', Today()), 0, 9));

        Dbtr := XmlElement.Create('Dbtr');
        PmtInf.Add(Dbtr);

        AddTextElement(Dbtr, 'Nm', IntegrationSetup."Sender Name");

        DbtrAcct := XmlElement.Create('DbtrAcct');
        PmtInf.Add(DbtrAcct);

        Id := XmlElement.Create('Id');
        DbtrAcct.Add(Id);

        Othr := XmlElement.Create('Othr');
        Id.Add(Othr);

        AddTextElement(Othr, 'Id', GetValue(EMTLines.Get(1), 'DebtorAccount'));

        AddTextElement(DbtrAcct, 'Ccy', IntegrationSetup."Currency Code");

        DbtrAgt := XmlElement.Create('DbtrAgt');
        PmtInf.Add(DbtrAgt);

        FinInstnId := XmlElement.Create('FinInstnId');
        DbtrAgt.Add(FinInstnId);

        ClrSysMmbId := XmlElement.Create('ClrSysMmbId');
        FinInstnId.Add(ClrSysMmbId);

        ClrSysId := XmlElement.Create('ClrSysId');
        ClrSysMmbId.Add(ClrSysId);

        AddTextElement(ClrSysId, 'Cd', 'CACPA');
        AddTextElement(ClrSysMmbId, 'MmbId', GetValue(EMTLines.Get(1), 'DebtorCPA'));

        for Index := 1 to EMTLines.Count() do begin
            Line := EMTLines.Get(Index);

            CreateEMTTransaction(PmtInf, Line, Index);
        end;
    end;


    local procedure CreateEMTTransaction(PmtInf: XmlElement; Line: Dictionary of [Text, Text]; Index: Integer)
    var
        Tx: XmlElement;
        PmtId: XmlElement;
        Amt: XmlElement;
        InstdAmt: XmlElement;
        Cdtr: XmlElement;
        CtctDtls: XmlElement;
        RmtInf: XmlElement;
    begin
        IntegrationSetup.Get();
        Tx := XmlElement.Create('CdtTrfTxInf');
        PmtInf.Add(Tx);

        PmtId := XmlElement.Create('PmtId');
        Tx.Add(PmtId);

        AddTextElement(PmtId, 'InstrId', 'EMT' + PadID(Index, 6));

        AddTextElement(PmtId, 'EndToEndId', GetValue(Line, 'ClaimID'));

        Amt := XmlElement.Create('Amt');
        Tx.Add(Amt);

        InstdAmt := XmlElement.Create('InstdAmt');
        InstdAmt.SetAttribute('Ccy', IntegrationSetup."Currency Code");

        InstdAmt.Add(XmlText.Create(GetValue(Line, 'Amount')));

        Amt.Add(InstdAmt);

        Cdtr := XmlElement.Create('Cdtr');
        Tx.Add(Cdtr);

        AddTextElement(Cdtr, 'Nm', GetValue(Line, 'Name'));

        CtctDtls := XmlElement.Create('CtctDtls');
        Cdtr.Add(CtctDtls);

        AddTextElement(CtctDtls, 'EmailAdr', GetValue(Line, 'Email')); // Missing

        RmtInf := XmlElement.Create('RmtInf');
        Tx.Add(RmtInf);

        if GetValue(Line, 'Memo') <> '' then
            AddTextElement(RmtInf, 'Ustrd', '0034 ' + GetValue(Line, 'Memo')); // Missing

        AddTextElement(RmtInf, 'Ustrd', '0035 ' + GetValue(Line, 'SecurityQuestion'));

        AddTextElement(RmtInf, 'Ustrd', '0036 ' + GetValue(Line, 'Password')); // Missing
    end;

    // ============================================================
    // CHEQUE PAYMENT INFORMATION
    // ============================================================

    local procedure CreateChequePaymentInformation(Initn: XmlElement; CHQLines: List of [Dictionary of [Text, Text]]; var SFTPLogs: Record CASFTPLogs)
    var
        PmtInf: XmlElement;
        PmtTpInf: XmlElement;
        LclInstrm: XmlElement;
        Dbtr: XmlElement;
        PstlAdr: XmlElement;
        DbtrAcct: XmlElement;
        Id: XmlElement;
        Othr: XmlElement;
        DbtrAgt: XmlElement;
        FinInstnId: XmlElement;
        ClrSysMmbId: XmlElement;
        Line: Dictionary of [Text, Text];
        Index: Integer;
    begin
        IntegrationSetup.Get();
        PmtInf := XmlElement.Create('PmtInf');
        Initn.Add(PmtInf);

        AddTextElement(PmtInf, 'PmtInfId', 'CHQ-' + PadID(1, 3));

        AddTextElement(PmtInf, 'PmtMtd', 'TRF');

        AddTextElement(PmtInf, 'NbOfTxs', Format(CHQLines.Count()));

        AddTextElement(PmtInf, 'CtrlSum', FormatDecimal(GetListTotal(CHQLines)));

        PmtTpInf := XmlElement.Create('PmtTpInf');
        PmtInf.Add(PmtTpInf);

        LclInstrm := XmlElement.Create('LclInstrm');
        PmtTpInf.Add(LclInstrm);

        AddTextElement(LclInstrm, 'Prtry', 'CHK');

        AddTextElement(PmtInf, 'ReqdExctnDt', Format(CalcDate('<+' + Format(IntegrationSetup."CHQ Execution Offset Days") + 'D>', Today()), 0, 9));

        Dbtr := XmlElement.Create('Dbtr');
        PmtInf.Add(Dbtr);

        AddTextElement(Dbtr, 'Nm', IntegrationSetup."Sender Name");

        PstlAdr := XmlElement.Create('PstlAdr');
        Dbtr.Add(PstlAdr);
        AddTextElement(PstlAdr, 'PstCd', IntegrationSetup."CHQ Sender Postal Code");
        AddTextElement(PstlAdr, 'TwnNm', IntegrationSetup."CHQ Sender City");
        AddTextElement(PstlAdr, 'CtrySubDvsn', IntegrationSetup."CHQ Sender Province");
        AddTextElement(PstlAdr, 'Ctry', IntegrationSetup."CHQ Sender Country Code");
        AddTextElement(PstlAdr, 'AdrLine', IntegrationSetup."CHQ Sender Title Line");
        AddTextElement(PstlAdr, 'AdrLine', IntegrationSetup."CHQ Sender Address Line" + ' ' + IntegrationSetup."CHQ Sender City");

        DbtrAcct := XmlElement.Create('DbtrAcct');
        PmtInf.Add(DbtrAcct);

        Id := XmlElement.Create('Id');
        DbtrAcct.Add(Id);

        Othr := XmlElement.Create('Othr');
        Id.Add(Othr);

        AddTextElement(Othr, 'Id', GetValue(CHQLines.Get(1), 'DebtorAccount'));

        AddTextElement(DbtrAcct, 'Ccy', IntegrationSetup."Currency Code");

        DbtrAgt := XmlElement.Create('DbtrAgt');
        PmtInf.Add(DbtrAgt);

        FinInstnId := XmlElement.Create('FinInstnId');
        DbtrAgt.Add(FinInstnId);

        ClrSysMmbId := XmlElement.Create('ClrSysMmbId');
        FinInstnId.Add(ClrSysMmbId);

        AddTextElement(ClrSysMmbId, 'MmbId', GetValue(CHQLines.Get(1), 'DebtorCPA'));

        for Index := 1 to CHQLines.Count() do begin
            Line := CHQLines.Get(Index);

            CreateChequeTransaction(PmtInf, Line, Index);
        end;
    end;


    local procedure CreateChequeTransaction(PmtInf: XmlElement; Line: Dictionary of [Text, Text]; Index: Integer)
    var
        Tx: XmlElement;
        PmtId: XmlElement;
        Amt: XmlElement;
        InstdAmt: XmlElement;
        ChqInstr: XmlElement;
        DlvryMtd: XmlElement;
        Cdtr: XmlElement;
        CdtrPstl: XmlElement;
        RmtInf: XmlElement;
        Strd: XmlElement;
        RfrdDocInf: XmlElement;
        Tp: XmlElement;
        CdOrPrtry: XmlElement;
        RfrdDocAmt: XmlElement;
    begin
        IntegrationSetup.Get();
        Tx := XmlElement.Create('CdtTrfTxInf');
        PmtInf.Add(Tx);

        PmtId := XmlElement.Create('PmtId');
        Tx.Add(PmtId);

        AddTextElement(PmtId, 'InstrId', 'CHQ' + PadID(Index, 6));

        AddTextElement(PmtId, 'EndToEndId', 'Claim ID ' + GetValue(Line, 'ClaimID')); // Application ID

        Amt := XmlElement.Create('Amt');
        Tx.Add(Amt);

        InstdAmt := XmlElement.Create('InstdAmt');
        InstdAmt.SetAttribute('Ccy', IntegrationSetup."Currency Code");

        InstdAmt.Add(XmlText.Create(GetValue(Line, 'Amount'))); // PaymentBaseCompensation

        Amt.Add(InstdAmt);

        ChqInstr := XmlElement.Create('ChqInstr');
        Tx.Add(ChqInstr);

        AddTextElement(ChqInstr, 'ChqNb', PadChequeNumber(GetValue(Line, 'ChequeNo'))); // ChequeNumber

        if GetValue(Line, 'DeliveryMethod') <> '' then begin
            DlvryMtd := XmlElement.Create('DlvryMtd');
            ChqInstr.Add(DlvryMtd);

            AddTextElement(DlvryMtd, 'Cd', GetValue(Line, 'DeliveryMethod')); // Missing
        end;

        Cdtr := XmlElement.Create('Cdtr');
        Tx.Add(Cdtr);

        if GetValue(Line, 'Estate') <> '' then
            AddTextElement(Cdtr, 'Nm', 'Estate of ' + GetValue(Line, 'Name') + ' c/o ' + GetValue(Line, 'Estate')) // Missing
        else
            AddTextElement(Cdtr, 'Nm', GetValue(Line, 'Name'));

        // ??? Mailing address parsing needs to be mapped to actual
        // claimant address fields in BC.
        CdtrPstl := XmlElement.Create('PstlAdr');
        Cdtr.Add(CdtrPstl);

        AddTextElement(CdtrPstl, 'PstCd', GetValue(Line, 'PostalCode'));
        AddTextElement(CdtrPstl, 'TwnNm', GetValue(Line, 'City'));
        AddTextElement(CdtrPstl, 'CtrySubDvsn', GetValue(Line, 'Province'));
        AddTextElement(CdtrPstl, 'Ctry', GetValue(Line, 'Country'));
        AddTextElement(CdtrPstl, 'AdrLine', GetValue(Line, 'AddressLine1'));
        if GetValue(Line, 'AddressLine2') <> '' then
            AddTextElement(CdtrPstl, 'AdrLine', GetValue(Line, 'AddressLine2'));

        RmtInf := XmlElement.Create('RmtInf');
        Tx.Add(RmtInf);

        AddTextElement(RmtInf, 'Ustrd', '0034 Claim ID ' + GetValue(Line, 'ClaimID'));

        AddTextElement(RmtInf, 'Ustrd', '0034 Service Number ' + GetValue(Line, 'ServiceNumber'));

        AddTextElement(RmtInf, 'Ustrd', ' - 0034 Cheque number ' + GetLastSixDigits(PadChequeNumber(GetValue(Line, 'ChequeNo'))));

        AddTextElement(RmtInf, 'Ustrd', ' - Please find below your compensation payment cheque related to your ' +
            GetValue(Line, 'ProjectName') +
            '.'); // Missing - Needs to be picked from Project Code

        AddTextElement(RmtInf, 'Ustrd', ' - Please deposit/cash this cheque as soon as possible. It must be cashed within 6 months of issuance to be valid.');

        AddTextElement(RmtInf, 'Ustrd', ' - Thank you for your participation in the ' + GetValue(Line, 'ProjectNotice') + '.'); // Missing

        Strd := XmlElement.Create('Strd');
        RmtInf.Add(Strd);

        RfrdDocInf := XmlElement.Create('RfrdDocInf');
        Strd.Add(RfrdDocInf);

        Tp := XmlElement.Create('Tp');
        RfrdDocInf.Add(Tp);

        CdOrPrtry := XmlElement.Create('CdOrPrtry');
        Tp.Add(CdOrPrtry);

        AddTextElement(CdOrPrtry, 'Cd', 'CINV');

        AddTextElement(RfrdDocInf, 'Nb', 'Service Number ' + GetValue(Line, 'ServiceNumber')); // Missing

        AddTextElement(RfrdDocInf, 'RltdDt', Format(Today(), 0, 9));

        RfrdDocAmt := XmlElement.Create('RfrdDocAmt');
        Strd.Add(RfrdDocAmt);

        AddAmountElement(RfrdDocAmt, 'DuePyblAmt', GetValue(Line, 'Amount'));

        AddAmountElement(RfrdDocAmt, 'DscntApldAmt', '0.00');

        AddAmountElement(RfrdDocAmt, 'RmtdAmt', GetValue(Line, 'Amount'));
    end;

    // ============================================================
    // XML HELPERS
    // ============================================================

    local procedure AddTextElement(ParentElement: XmlElement; ElementName: Text; Value: Text)
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(ElementName);

        if Value <> '' then
            Element.Add(XmlText.Create(Value));

        ParentElement.Add(Element);
    end;


    local procedure AddAmountElement(ParentElement: XmlElement; ElementName: Text; AmountText: Text)
    var
        Element: XmlElement;
    begin
        IntegrationSetup.Get();
        Element := XmlElement.Create(ElementName);
        Element.SetAttribute('Ccy', IntegrationSetup."Currency Code");

        Element.Add(XmlText.Create(AmountText));

        ParentElement.Add(Element);
    end;


    local procedure CreateDocument(var XMLDoc: XmlDocument; var Root: XmlElement)
    begin
        Root := XmlElement.Create('Document', 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03');
        Root.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', 'http://www.w3.org/2001/XMLSchema-instance'));
        XMLDoc := XmlDocument.Create(Root);
    end;

    // ============================================================
    // GENERAL HELPERS
    // ============================================================

    local procedure GetValue(Line: Dictionary of [Text, Text]; Key1: Text): Text
    var
        Value: Text;
    begin
        if Line.Get(Key1, Value) then
            exit(Value);

        exit('');
    end;


    local procedure GetListTotal(Lines: List of [Dictionary of [Text, Text]]): Decimal
    var
        Line: Dictionary of [Text, Text];
        Index: Integer;
        Amount: Decimal;
        Total: Decimal;
    begin
        for Index := 1 to Lines.Count() do begin
            Line := Lines.Get(Index);

            Amount := 0;
            Evaluate(Amount, GetValue(Line, 'Amount'));

            Total += Amount;
        end;

        exit(Total);
    end;


    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Standard Format,2>'));
    end;


    local procedure PadID(Number: Integer; Width: Integer): Text
    begin
        exit(PadStr(Format(Number), Width, '0'));
    end;

    local procedure PadLeft(Value: Text; Width: Integer): Text
    begin
        if StrLen(Value) >= Width then
            exit(Value);
        exit(PadStr('', Width - StrLen(Value), '0') + Value);
    end;


    local procedure PadChequeNumber(Value: Text): Text
    begin
        exit(PadStr(Value, 10, '0'));
    end;


    local procedure GetLastSixDigits(Value: Text): Text
    begin
        if StrLen(Value) <= 6 then
            exit(Value);

        exit(CopyStr(Value, StrLen(Value) - 5, 6));
    end;


    local procedure GetCurrentUTCDateTime(): Text
    var
        CurrentDateTimeValue: DateTime;
    begin
        CurrentDateTimeValue := CurrentDateTime();

        exit(Format(CurrentDateTimeValue, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;

    //Deloitte AK 11092026++
    procedure CreateSFTPLog(var CASFTPLog: Record CASFTPLogs; JournalTemplateName: Code[20]; JournalBatchName: Code[20]; MsgIDNoSeries: Code[20]; FileName: Text)
    begin
        CASFTPLog.Init();
        CASFTPLog.Validate("Template Name", JournalTemplateName);
        CASFTPLog.Validate("Batch Name", JournalBatchName);
        CASFTPLog.Validate("Msg ID", MsgIDNoSeries);
        CASFTPLog.Validate("Request File Name", FileName);
        CASFTPLog.Insert();
    end;

    local procedure CreateSFTPLogLinesAndUpdateStatus(var GenJournalLine: Record "Gen. Journal Line"; CASFTPLog: Record CASFTPLogs; MsgId: Code[20])
    var
        GenJournalLine2: Record "Gen. Journal Line";
        PaymentID: Code[20];
    begin
        GenJournalLine2.Copy(GenJournalLine);

        if GenJournalLine2.FindSet() then
            repeat
                PaymentID := GetPaymentID(GenJournalLine2);

                CreateSFTPLogLine(GenJournalLine2, CASFTPLog, PaymentID);

                GenJournalLine2."CA Payment Status" :=
                    GenJournalLine2."CA Payment Status"::"Sent to SFTP";

                GenJournalLine2."CA Message ID" := MsgId;

                GenJournalLine2.Modify(true);
            until GenJournalLine2.Next() = 0;
    end;

    procedure CreateSFTPLogLine(
    GJL: Record "Gen. Journal Line";
    RecSFTPLog: Record CASFTPLogs;
    PaymentID: Code[20])
    var
        CASFTPLogLines: Record CASFTPLogLines;
    begin
        CASFTPLogLines.Init();

        CASFTPLogLines."Entry No." := RecSFTPLog."Entry No.";
        CASFTPLogLines."Line No." := GJL."Line No.";

        CASFTPLogLines."Account No." := GJL."Account No.";
        CASFTPLogLines."Account Type" := GJL."Account Type";
        CASFTPLogLines."Document No." := GJL."Document No.";
        CASFTPLogLines."Document Type" := GJL."Document Type";
        CASFTPLogLines."Posting Date" := GJL."Posting Date";

        CASFTPLogLines."Msg ID" := RecSFTPLog."Msg ID";

        CASFTPLogLines."Journal Batch Name" :=
            GJL."Journal Batch Name";

        CASFTPLogLines."Journal Template Name" :=
            GJL."Journal Template Name";

        CASFTPLogLines."Payment ID" := PaymentID;

        CASFTPLogLines.Amount := GJL.Amount;
        CASFTPLogLines.Name := GJL.Description;
        CASFTPLogLines."Currency Code" := GJL."Currency Code";

        CASFTPLogLines."Claim ID" := GJL."Claim ID";
        CASFTPLogLines."Cheque No." := GJL."Cheque No.";

        CASFTPLogLines.Insert();
    end;

    local procedure GetPaymentID(GenJournalLine: Record "Gen. Journal Line"): Code[20]
    begin
        // ??? Replace with actual Payment ID source.
        exit(GenJournalLine."Transaction Ref. No.");
    end;

    local procedure ValidateClaimIDInCurrentBatch(
    GenJournalLine: Record "Gen. Journal Line";
    var ClaimIDs: Dictionary of [Text, Boolean])
    var
        ClaimID: Text;
        Dummy: Boolean;
    begin
        ClaimID := UpperCase(DelChr(GenJournalLine."Claim ID", '<>', ' '));

        if ClaimID = '' then
            exit;

        if ClaimIDs.Get(ClaimID, Dummy) then
            Error('Claim ID "%1" is duplicated in the current journal batch. Claim ID must be unique within the current batch.', GenJournalLine."Claim ID");

        ClaimIDs.Add(ClaimID, true);
    end;
    //Deloitte AK 11092026--
}