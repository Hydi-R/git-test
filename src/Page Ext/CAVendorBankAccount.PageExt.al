/// <summary>
///  Deloitte AK 10082026
///     <FLD> Following Fields Added </FLD>
///        - Institution Number
/// </summary>
pageextension 51009 CAVendorBankAccount extends "Vendor Bank Account Card"
{
    layout
    {
        addbefore("Transit No.")
        {
            field("Institution Number"; Rec."Institution Number")
            {
                ApplicationArea = All;
            }
        }
    }
}