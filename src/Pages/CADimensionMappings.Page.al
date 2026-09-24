/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///         - For Mapping Dimensions for auto-population
/// </summary>
page 51004 CADimensionMappings
{
    ApplicationArea = All;
    Caption = 'Dimensions Mapping';
    PageType = List;
    SourceTable = CADimensionMapping;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Mappings)
            {
                field("Dimension 1 Value Code"; Rec."Dimension 1 Value Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Text := CADimensionManagement.GetDimensionValueCode(1, false, Rec."Dimension 1 Value Code");
                        exit(true);
                    end;
                }
                field("Dimension 2 Value Code"; Rec."Dimension 2 Value Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Output: Text;
                    begin
                        Output := CADimensionManagement.GetDimensionValueCode(2, true, Rec."Dimension 1 Value Code");
                        if Output <> '' then begin
                            Text := Output;
                            exit(true);
                        end;
                        exit(false);
                    end;
                }
                field("Dimension 3 Value Code"; Rec."Dimension 3 Value Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Text := CADimensionManagement.GetDimensionValueCode(3, false, Rec."Dimension 1 Value Code");
                        CurrPage.Update(False);
                        exit(true);
                    end;
                }
                field("Dimension 4 Value Code"; Rec."Dimension 4 Value Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Text := CADimensionManagement.GetDimensionValueCode(4, false, Rec."Dimension 1 Value Code");
                        CurrPage.Update(False);
                        exit(true);
                    end;
                }
            }
        }
    }

    var
        GenLedgerSetup: Record "General Ledger Setup";
        CADimensionManagement: Codeunit CADimensionManagement;

    trigger OnOpenPage()
    begin
        GenLedgerSetup.Get()
    end;
}
