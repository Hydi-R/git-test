/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///        - SFTP Logs Card
/// </summary>
page 51013 CASFTPLogsCard
{
    PageType = Card;
    SourceTable = CASFTPLogs;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    // DeleteAllowed = false;
    // Editable = false;
    Caption = 'SFTP Logs Card';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group("SFTP Logs")
            {
                field("Msg ID"; Rec."Msg ID")
                {
                }
                field("Request File Name"; Rec."Request File Name")
                {
                }
                field("Response File Name"; Rec."Response File Name")
                {
                }
                field("Payment Response File Name"; Rec."Payment Response File Name")
                {
                }
                field("File Accepted"; Rec."File Status")
                {
                }
                field("File Error"; Rec."File Error")
                {
                }
            }
            part(CASFTPLogSubform; CASFTPLogSubform)
            {
                Caption = 'SFTP Logs Subform';
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }
}
