/// <summary>
///  Deloitte AK 10082026
///     <FLD> Following fields added </FLD>
///         - Claim Id
///         - Claimant Name
/// </summary>
pageextension 51007 CAGLEntry extends "General Ledger Entries"
{
    layout
    {
        modify("Debit Amount")
        {
            Visible = true;
            Applicationarea = All;
        }
        modify("Credit Amount")
        {
            Visible = true;
            Applicationarea = All;
        }
        addafter("Bal. Account No.")
        {
            field("Claim ID"; Rec."Claim ID")
            {
                ApplicationArea = All;
            }
            field("Claimant Name"; Rec."Claimant Name")
            {
                ApplicationArea = All;
            }
        }
    }
}
