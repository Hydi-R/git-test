pageextension 51010 BankReconLines extends "Bank Acc. Reconciliation Lines"
{
    layout
    {
        addafter("Document No.")
        {
            field("Cheque No."; Rec."Cheque No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Cheque No. field.', Comment = '%';
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Method Code field.', Comment = '%';
            }
        }
    }
}