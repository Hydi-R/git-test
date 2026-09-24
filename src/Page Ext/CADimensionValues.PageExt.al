/// <summary>
///  Deloitte AK 10082026
///     <FLD> Following fields added </FLD>
///         - Project Dimension
/// </summary>
pageextension 51006 CADimensionValues extends "Dimension Values"
{
    layout
    {
        addafter(Name)
        {
            field("Project Dimension"; Rec."Project Dimension")
            {
                ApplicationArea = All;
                Visible = IsVisible;
                trigger OnLookup(var Text: Text): Boolean
                var
                    DimensionValue: Record "Dimension Value";
                    DimensionValues: Page "Dimension Value List";
                begin
                    DimensionValue.Reset();
                    DimensionValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                    if DimensionValue.FindSet() then begin
                        DimensionValues.SetTableView(DimensionValue);
                        DimensionValues.LookupMode(true);
                        if DimensionValues.RunModal() = Action::LookupOK then begin
                            Text := CADimensionManagement.GetCodeValueFromSelectionFilter(DimensionValues.GetSelectionFilter());
                            exit(true);
                        end;
                        exit(false);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsVisible := false;
        if (GLSetup.Get()) and (Rec."Dimension Code" = GLSetup."Global Dimension 2 Code") then
            IsVisible := true;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CADimensionManagement: Codeunit CADimensionManagement;
        IsVisible: Boolean;
}
