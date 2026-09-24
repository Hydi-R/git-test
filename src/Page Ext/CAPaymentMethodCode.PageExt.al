pageextension 51020 PaymentMethodExt extends "Payment Methods"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Payment File Code"; Rec."Payment File Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment File Code field.', Comment = '%';
            }
            field("CA Account Type"; Rec."CA Account Type")
            {
                ApplicationArea = All;
                Caption = 'Account Type';
                ToolTip = 'Specifies the value of the CA Account Type field.', Comment = '%';
            }
            field("CA Account No."; Rec."CA Account No.")
            {
                ApplicationArea = All;
                Caption = 'Account No.';
                ToolTip = 'Specifies the value of the CA Account No. field.', Comment = '%';
            }
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}