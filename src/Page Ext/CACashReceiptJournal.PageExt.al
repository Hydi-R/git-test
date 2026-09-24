pageextension 51004 CACashReceiptJournal extends "Cash Receipt Journal"
{
    layout
    {
        modify("Shortcut Dimension 2 Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                GLSetup: Record "General Ledger Setup";
                DimValue: Record "Dimension Value";
            begin
                if not GLSetup.Get() then
                    exit(false);

                // Allow global dimension 1/project to be created anytime.
                if Rec."Shortcut Dimension 1 Code" = '' then
                    Error(
                      'Please create the %1 dimension before adding %2.',
                      GLSetup."Global Dimension 1 Code",
                      GLSetup."Global Dimension 2 Code");

                // Allow standard lookup except for global dimension 2/class.

                DimValue.Reset();
                DimValue.SetRange("Project Dimension", Rec."Shortcut Dimension 1 Code");
                if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                    Rec.Validate("Shortcut Dimension 2 Code", DimValue.Code);
                    CurrPage.Update(False);
                end;


            end;

        }
        addafter("Bal. Account No.")
        {
            field("Transaction Ref. No."; Rec."Transaction Ref. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Transaction Ref. No. field.', Comment = '%';

            }
        }
    }
}