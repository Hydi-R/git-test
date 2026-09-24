/// <summary>
/// Deloitte AK 18092026
///     <NEW>New object created </NEW>
/// </summary>
pageextension 51016 CAGeneralLedgerSetup extends "General Ledger Setup"
{
    layout
    {
        addfirst("Financial Reports")
        {
            field("Statement of Operations Report"; Rec."Statement of Operations Report")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Statement of Net Assets Report"; Rec."Statement of Net Assets Report")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Statement of Net Assets field.', Comment = '%';
            }
            field("Stmt. of CashRcpts and Dts."; Rec."Stmt. of CashRcpts and Dts.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Statement of Net Assets field.', Comment = '%';
            }

        }
    }
}