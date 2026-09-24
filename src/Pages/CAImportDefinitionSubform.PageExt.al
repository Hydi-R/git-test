/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///         - Import Definition Fields
/// </summary>
page 51007 CAImportDefinitionSubform
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'Import Definition Fields';
    SourceTable = CAImportDefinitionFields;

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field("Column No."; Rec."Column No.")
                {
                    ApplicationArea = All;
                }
                field("Column Name"; Rec."Column Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Column No."; Rec."Journal Column No.")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        FieldSelection: Codeunit "Field Selection";
                        RecField: Record Field;
                        GenJournalLine: Record "Gen. Journal Line";
                    begin
                        RecField.Reset();
                        RecField.SetRange(TableNo, GenJournalLine.RecordId.TableNo);
                        if FieldSelection.Open(RecField) then begin
                            Rec."Journal Column No." := RecField."No.";
                            Rec."Journal Column" := RecField."Field Caption";
                            Rec.Modify();
                        end;
                    end;
                }
                field("Journal Column"; Rec."Journal Column")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
