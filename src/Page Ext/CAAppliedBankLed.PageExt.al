pageextension 51000 AppliedBankLedgerE extends 381
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
        }
    }
}