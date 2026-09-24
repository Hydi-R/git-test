/// <summary>
/// Detailed row-level audit records for a payment file import.
/// </summary>
page 51016 CASharePointLogsSubform
{
    PageType = ListPart;
    SourceTable = CASharePointLogsLine;
    ApplicationArea = All;
    Caption = 'SharePoint Log Lines';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Source Line No."; Rec."Source Line No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Claim ID"; Rec."Claim ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Estate/Care of"; Rec."Estate/Care of")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }
                field("Security Question"; Rec."Security Question")
                {
                    ApplicationArea = All;
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Mailing Address"; Rec."Mailing Address")
                {
                    ApplicationArea = All;
                }
                field("Delivery Method"; Rec."Delivery Method")
                {
                    ApplicationArea = All;
                }
                field("Cheque Number"; Rec."Cheque Number")
                {
                    ApplicationArea = All;
                }
                field(Memo; Rec.Memo)
                {
                    ApplicationArea = All;
                }
                field("Institution Number"; Rec."Institution Number")
                {
                    ApplicationArea = All;
                }
                field("Transit Number"; Rec."Transit Number")
                {
                    ApplicationArea = All;
                }
                field("Account Number"; Rec."Account Number")
                {
                    ApplicationArea = All;
                }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                }
                field("Project Notice"; Rec."Project Notice")
                {
                    ApplicationArea = All;
                }
                field("GL Account Number"; Rec."GL Account Number")
                {
                    ApplicationArea = All;
                }
                field("Payment Batch Number"; Rec."Payment Batch Number")
                {
                    ApplicationArea = All;
                }
                field("Error List"; Rec."Error List")
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    ApplicationArea = All;
                }
                field("Last Changed Date Time"; Rec."Last Changed Date Time")
                {
                    ApplicationArea = All;
                }
                field("Last Changed By"; Rec."Last Changed By")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
