/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///        - SFTP Log Subform
/// </summary>
page 51014 CASFTPLogSubform
{
    PageType = ListPart;
    SourceTable = CASFTPLogLines;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    // DeleteAllowed = false;
    // Editable = false;
    Caption = 'SFTP Logs Subform';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater("SFTP Log Lines")
            {
                field("Account Type"; Rec."Account Type")
                {
                }
                field("Account No."; Rec."Account No.")
                {
                }
                field(Name; Rec.Name)
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field(Amount; Rec.Amount)
                {
                }
                field("Cheque No."; Rec."Cheque No.")
                {

                }
                field("Claim ID"; Rec."Claim ID")
                {

                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
                field("Payment ID"; Rec."Payment ID")
                {
                }
                field("File Status"; Rec."File Status")
                {

                }
                field("Payment Status"; Rec."Payment Status")
                {

                }
                field(Remarks; Rec.Remarks)
                {

                }
                field("File Error"; Rec."File Error")
                {

                }
                field("Payment Error"; Rec."Payment Error")
                {

                }

                field(Response_Reason_Code; Rec."Response Reason Code")
                {
                    ApplicationArea = All;
                    Caption = 'Response Reason Code';
                }
            }
        }
    }
}
