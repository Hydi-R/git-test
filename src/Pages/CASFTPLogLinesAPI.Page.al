/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///        - For SFTP Log Lines API
/// </summary>
page 51010 CASFTPLogLinesAPI
{
    ApplicationArea = All;
    Caption = 'SFTP Log Lines API';
    PageType = API;
    APIGroup = 'Integrations';
    APIPublisher = 'CA';
    APIVersion = 'v2.0';
    EntityName = 'SFTPLogsLinesAPI';
    EntitySetName = 'SFTPLogsLinesAPI';
    DelayedInsert = true;
    SourceTable = CASFTPLogLines;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater("SFTP Logs")
            {
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'System ID';
                }
                field(Template_Name; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    Caption = 'Template Name';
                }
                field(Batch_Name; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Caption = 'Batch Name';
                }

                field(Msg_ID; Rec."Msg ID")
                {
                    ApplicationArea = All;
                    Caption = 'Msg ID';
                }
                field(File_Status; Rec."File Status")
                {
                    ApplicationArea = All;
                    Caption = 'File Status';
                }
                field(Payment_Status; Rec."Payment Status")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Status';
                }
                field(File_Error; Rec."File Error")
                {
                    ApplicationArea = All;
                    Caption = 'File Error';
                }
                field(Payment_Error; Rec."Payment Error")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Error';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    Caption = 'Remarks';
                }
                field(Payment_ID; Rec."Payment ID")
                {
                    ApplicationArea = All;
                    Caption = 'Payment ID';
                }
                field(Response_Reason_Code; Rec."Response Reason Code")
                {
                    ApplicationArea = All;
                    Caption = 'Response Reason Code';
                }
            }
        }
    }
    // trigger OnAfterGetRecord()
    // var
    //     GenJnlLine: Record "Gen. Journal Line";
    // begin
    //     if GenJnlLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then begin

    //         case Rec."Payment Status" of

    //             CAPaymentStatus::ACSC:
    //                 GenJnlLine."CA Payment Status" := GenJnlLine."CA Payment Status"::"Payment Accepted";

    //             CAPaymentStatus::CANC:
    //                 GenJnlLine."CA Payment Status" := GenJnlLine."CA Payment Status"::"Payment Canceled";

    //             CAPaymentStatus::PDNG:
    //                 GenJnlLine."CA Payment Status" := GenJnlLine."CA Payment Status"::"Payment in Pending State";

    //             CAPaymentStatus::RJCT:
    //                 GenJnlLine."CA Payment Status" := GenJnlLine."CA Payment Status"::"Payment Rejected";
    //         end;
    //         if GenJnlLine."Currency Code" <> '' then
    //             GenJnlLine."FX Rate Check Pending" := true;
    //         GenJnlLine.Modify();
    //     end;
    // end;
}
