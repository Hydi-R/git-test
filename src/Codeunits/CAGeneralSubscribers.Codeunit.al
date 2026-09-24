/// <summary>
/// Deloitte AK 23092026
///     <NEW> General journal validations and audit subscribers </NEW>
/// </summary>
codeunit 51002 CAGeneralSubscribers
{
    [EventSubscriber(ObjectType::Codeunit, codeunit::GenJnlManagement, OnBeforeLookupName, '', false, false)]
    local procedure OnBeforeLookupName(var GenJnlBatch: Record "Gen. Journal Batch"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlBatch.SetRange("Claimant Batch", false);
    end;

    // ============================================================
    // CHEQUE NUMBER VALIDATION
    // ============================================================

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGeneralJournalLine(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    begin
        ValidateChequeNumber(Rec);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyGeneralJournalLine(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    begin
        // Only validate if the cheque number is being changed.
        if Rec."Cheque No." <> xRec."Cheque No." then
            ValidateChequeNumber(Rec);
    end;


    local procedure ValidateChequeNumber(GenJournalLine: Record "Gen. Journal Line")
    var
        ChequeNo: Text;
        ExistingJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
    begin
        ChequeNo := NormalizeChequeNumber(GenJournalLine."Cheque No.");

        if ChequeNo = '' then
            exit;

        // --------------------------------------------------------
        // 1. Check all unposted journal lines
        // --------------------------------------------------------

        ExistingJournalLine.Reset();
        ExistingJournalLine.SetRange("Cheque No.", ChequeNo);

        if ExistingJournalLine.FindFirst() then begin

            // Ignore the current journal line when Modify is executed.
            if not IsSameJournalLine(ExistingJournalLine, GenJournalLine) then
                Error('Cheque No. "%1" is already used in Journal Template "%2", Batch "%3", Line No. %4.',
                    GenJournalLine."Cheque No.",
                    ExistingJournalLine."Journal Template Name",
                    ExistingJournalLine."Journal Batch Name",
                    ExistingJournalLine."Line No.");
        end;


        // --------------------------------------------------------
        // 2. Check posted G/L entries
        // --------------------------------------------------------

        GLEntry.Reset();
        GLEntry.SetRange("Cheque No.", ChequeNo);

        if GLEntry.FindFirst() then
            Error('Cheque No. "%1" has already been posted. G/L Entry No. %2, Document No. "%3", Posting Date %4.',
                GenJournalLine."Cheque No.",
                GLEntry."Entry No.",
                GLEntry."Document No.",
                GLEntry."Posting Date");
    end;


    local procedure IsSameJournalLine(ExistingJournalLine: Record "Gen. Journal Line"; CurrentJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        exit((ExistingJournalLine."Journal Template Name" = CurrentJournalLine."Journal Template Name")
            and (ExistingJournalLine."Journal Batch Name" = CurrentJournalLine."Journal Batch Name")
            and (ExistingJournalLine."Line No." = CurrentJournalLine."Line No."));
    end;


    local procedure NormalizeChequeNumber(ChequeNo: Text): Text
    begin
        exit(UpperCase(DelChr(ChequeNo, '<>', ' ')));
    end;


    // ============================================================
    // JOURNAL AUDIT
    // ============================================================

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyGeneralJournalLine(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        PaymentFileImport: Record CASharePointLogsLine;
    begin
        if Rec."Payment Import Entry No." = 0 then
            exit;

        if xRec."Payment Import Entry No." = 0 then
            exit;

        if not PaymentFileImport.Get(Rec."Payment Import Entry No.", Rec."Payment Import Line No.") then
            exit;

        CreateJournalAuditLine(Rec, PaymentFileImport.Status::Modified);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteGeneralJournalLine(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        PaymentFileImport: Record CASharePointLogsLine;
    begin
        if Rec."Payment Import Entry No." = 0 then
            exit;

        if not PaymentFileImport.Get(Rec."Payment Import Entry No.", Rec."Payment Import Line No.") then
            exit;

        CreateJournalAuditLine(Rec, PaymentFileImport.Status::Deleted);
    end;


    local procedure CreateJournalAuditLine(GenJournalLine: Record "Gen. Journal Line"; AuditStatus: Option Pending,Imported,Processed,Error,Modified,Deleted)
    var
        PaymentFileImportLine: Record CASharePointLogsLine;
        NewLineNo: Integer;
    begin
        PaymentFileImportLine.SetRange("Entry No.", GenJournalLine."Payment Import Entry No.");

        if PaymentFileImportLine.FindLast() then
            NewLineNo := PaymentFileImportLine."Line No." + 1
        else
            NewLineNo := 1;

        if PaymentFileImportLine.Imported then begin

            PaymentFileImportLine.Init();

            PaymentFileImportLine."Entry No." := GenJournalLine."Payment Import Entry No.";

            PaymentFileImportLine."Line No." := NewLineNo;

            PaymentFileImportLine."Source Line No." := GenJournalLine."Payment Import Line No.";

            PaymentFileImportLine."File Name" := GenJournalLine."Payment Import File Name";

            PaymentFileImportLine."Claim ID" := GenJournalLine."Claim ID";

            PaymentFileImportLine.Name := GenJournalLine."Claimant Name";

            PaymentFileImportLine.Amount := GenJournalLine.Amount;

            PaymentFileImportLine."Cheque Number" := GenJournalLine."Cheque No.";

            PaymentFileImportLine."Institution Number" := GenJournalLine."Claimant Institution No.";

            PaymentFileImportLine."Transit Number" := GenJournalLine."Claimant Transit No.";

            PaymentFileImportLine."Account Number" := GenJournalLine."Claimant Account No.";

            PaymentFileImportLine."Email Address" := GenJournalLine."Claimant Email";

            PaymentFileImportLine.Password := GenJournalLine."Claimant Password";

            PaymentFileImportLine."Estate/Care of" := GenJournalLine."Cheque Estate";

            PaymentFileImportLine."Delivery Method" := GenJournalLine."Cheque Delivery Method";

            PaymentFileImportLine.Memo := GenJournalLine.Memo;

            PaymentFileImportLine."Project Notice" := GenJournalLine."Project Notice";

            PaymentFileImportLine."Mailing Address" := GenJournalLine."Claimant Mailing Address";

            PaymentFileImportLine."Payment Batch Number" := GenJournalLine."Payment Batch Number";

            PaymentFileImportLine.Status := AuditStatus;

            PaymentFileImportLine."Journal Template Name" := GenJournalLine."Journal Template Name";

            PaymentFileImportLine."Journal Batch Name" := GenJournalLine."Journal Batch Name";

            PaymentFileImportLine."Journal Line No." := GenJournalLine."Line No.";

            PaymentFileImportLine."Account Number" := GenJournalLine."Account No.";

            PaymentFileImportLine."Last Changed Date Time" := CurrentDateTime();

            PaymentFileImportLine."Last Changed By" := CopyStr(UserId(), 1, MaxStrLen(PaymentFileImportLine."Last Changed By"));

            PaymentFileImportLine.Insert();
        end;
    end;
}