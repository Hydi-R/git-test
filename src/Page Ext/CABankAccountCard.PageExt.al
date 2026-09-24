/// <summary>
///  Deloitte AK 10082026
///     <FLD> Following Fields Added </FLD>
///        - Institution Number
/// </summary>
pageextension 51002 CABankAccountCard extends "Bank Account Card"
{
    layout
    {
        addafter("Bank Account No.")
        {
            field("Institution Number"; Rec."Institution Number")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Institution Number field.', Comment = '%';
            }
            field("Cheque No. Series"; Rec."Cheque No. Series")
            {
                ApplicationArea = All;
            }
        }
    }
}