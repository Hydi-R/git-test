/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///        - For SFTP Logs List
/// </summary>
page 51011 CASFTPLogs
{
    ApplicationArea = All;
    Caption = 'SFTP Logs';
    CardPageId = CASFTPLogsCard;
    PageType = List;
    UsageCategory = History;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    // DeleteAllowed = false;
    // Editable = false;
    SourceTable = CASFTPLogs;

    layout
    {
        area(Content)
        {
            repeater("SFTP Logs")
            {
                field("Msg ID"; Rec."Msg ID")
                {
                }
                field("Request File Name"; Rec."Request File Name")
                {
                }
                field("Sent to Azure"; Rec."Sent to SFTP")
                {
                }
                field("Response File Name"; Rec."Response File Name")
                {
                }
                field("File Accepted"; Rec."File Status")
                {
                }
                field("File Error"; Rec."File Error")
                {
                }
                field("Payment Response File Name"; Rec."Payment Response File Name")
                {
                }
                field("Payment Accepted"; Rec."Payment Status")
                {
                }
                field("Payment Error"; Rec."Payment Error")
                {
                }
                field(Remarks; Rec.Remarks)
                {
                }
                field("Response Msg ID"; Rec."Response Msg ID")
                {
                    ApplicationArea = All;
                    Caption = 'Response Msg ID';
                }

                field("Response Created Date Time"; Rec."Response Created Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Response Created Date Time';
                }

                field("Original No Of Transactions"; Rec."Original No. of Transactions")
                {
                    ApplicationArea = All;
                    Caption = 'Original No. of Transactions';
                }

                field("Original Control Sum"; Rec."Original Control Sum")
                {
                    ApplicationArea = All;
                    Caption = 'Original Control Sum';
                }

                field("Response Reason Code"; Rec."Response Reason Code")
                {
                    ApplicationArea = All;
                    Caption = 'Response Reason Code';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Reset ACK")
            {
                ApplicationArea = All;
                Caption = 'Disable ACK';
                Image = DisableBreakpoint;

                trigger OnAction()
                var
                    SFTPLogs: Record CASFTPLogs;
                begin
                    SFTPLogs.Reset();
                    SFTPLogs.ModifyAll("File Status", SFTPLogs."File Status"::Open);
                    SFTPLogs.ModifyAll("File Error", '');
                    SFTPLogs.ModifyAll("Payment Error", '');
                    SFTPLogs.ModifyAll("Payment Status", SFTPLogs."Payment Status"::Open);
                end;
            }
        }
    }
}
