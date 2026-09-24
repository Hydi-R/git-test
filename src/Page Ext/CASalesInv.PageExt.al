pageextension 51014 CASalesInv extends "Sales Invoice"
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
                if Rec."Shortcut Dimension 1 Code" = '' then
                    Error(
                      'Please create the %1 dimension before adding %2.',
                      GLSetup."Global Dimension 1 Code",
                      GLSetup."Global Dimension 2 Code");

                DimValue.Reset();
                DimValue.SetRange("Project Dimension", Rec."Shortcut Dimension 1 Code");
                if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                    Rec.Validate("Shortcut Dimension 2 Code", DimValue.Code);
                    CurrPage.Update(False);
                end;

            end;
        }
        // Add changes to page layout here
    }
}