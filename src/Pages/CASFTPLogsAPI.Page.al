/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///        - For SFTP Log API
/// </summary>
page 51012 CASFTPLogsAPI
{
    ApplicationArea = All;
    Caption = 'SFTP Logs API';
    PageType = API;
    APIGroup = 'Integrations';
    APIPublisher = 'CA';
    APIVersion = 'v2.0';
    EntityName = 'SFTPLogsAPI';
    EntitySetName = 'SFTPLogsAPI';
    DelayedInsert = true;
    SourceTable = CASFTPLogs;
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
                field(Template_Name; Rec."Template Name")
                {
                    ApplicationArea = All;
                    Caption = 'Template Name';
                }
                field(Batch_Name; Rec."Batch Name")
                {
                    ApplicationArea = All;
                    Caption = 'Batch Name';
                }
                field(Request_File_Name; Rec."Request File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Request File Name';
                }
                field(Response_File_Name; Rec."Response File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Response File Name';
                }
                field("Payment_Response_File_Name"; Rec."Payment Response File Name")
                {
                    Caption = 'Payment Response File Name';
                }
                field(Msg_ID; Rec."Msg ID")
                {
                    ApplicationArea = All;
                    Caption = 'Msg ID';
                }
                field(Sent_to_SFTP; Rec."Sent to SFTP")
                {
                    ApplicationArea = All;
                    Caption = 'Sent_to_SFTP';
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
                field(Response_Msg_ID; Rec."Response Msg ID")
                {
                    ApplicationArea = All;
                    Caption = 'Response Msg ID';
                }

                field(Response_Created_Date_Time; Rec."Response Created Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Response Created Date Time';
                }

                field(Original_No_Of_Transactions; Rec."Original No. of Transactions")
                {
                    ApplicationArea = All;
                    Caption = 'Original No. of Transactions';
                }

                field(Original_Control_Sum; Rec."Original Control Sum")
                {
                    ApplicationArea = All;
                    Caption = 'Original Control Sum';
                }

                field(Response_Reason_Code; Rec."Response Reason Code")
                {
                    ApplicationArea = All;
                    Caption = 'Response Reason Code';
                }
                part(CASFTPLogLinesAPI; CASFTPLogLinesAPI)
                {
                    SubPageLink = "Msg ID" = field("Msg ID");
                    ApplicationArea = All;
                    EntityName = 'SFTPLogsLinesAPI';
                    EntitySetName = 'SFTPLogsLinesAPI';
                }
            }
        }
    }
    // trigger OnAfterGetRecord()
    // var
    //     GenJnlLine: Record "Gen. Journal Line";
    //     CASFTPLogLines: Record CASFTPLogLines;
    // begin
    //     CASFTPLogLines.Reset();
    //     CASFTPLogLines.SetRange("Msg ID", Rec."Msg ID");
    //     if CASFTPLogLines.FindSet() then
    //         repeat
    //             if GenJnlLine.Get(CASFTPLogLines."Journal Template Name", CASFTPLogLines."Journal Batch Name", CASFTPLogLines."Line No.") then begin

    //                 case Rec."File Status" of
    //                     CAPaymentStatus::RJCT:
    //                         GenJnlLine."CA Payment Status" := GenJnlLine."CA Payment Status"::"File Rejected";
    //                 end;
    //                 GenJnlLine.Modify();
    //             end;
    //         until CASFTPLogLines.Next() = 0;
    // end;
}
