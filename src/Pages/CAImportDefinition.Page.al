/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///         - Importing columns from CSV file or copying from existing definition
/// </summary>
page 51005 CAImportDefinition
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Import Definition';
    SourceTable = CAImportDefinitions;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Project No."; Rec."Project No.")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimensionValue: Record "Dimension Value";
                        GenLedgerSetup: Record "General Ledger Setup";
                        DimensionValueList: Page "Dimension Value List";
                    begin
                        GenLedgerSetup.Get();
                        DimensionValue.Reset();
                        DimensionValue.SetRange("Dimension Code", GenLedgerSetup."Global Dimension 1 Code");

                        DimensionValueList.SetTableView(DimensionValue);
                        DimensionValueList.LookupMode(true);
                        if DimensionValueList.RunModal() = Action::LookupOK then begin
                            Text := CADimensionManagement.GetCodeValueFromSelectionFilter(DimensionValueList.GetSelectionFilter());
                            exit(true);
                        end;

                    end;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = All;
                }
            }
            part(CAImportDefinitionSubform; CAImportDefinitionSubform)
            {
                ApplicationArea = All;
                // SubPageLink = "Project No." = field("Project No."), "Payment Method" = field("Payment Method");  // Payment Method Commented
                SubPageLink = "Project No." = field("Project No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportColumnsFromTemplate)
            {
                Caption = 'Import Columns From Template';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Column;
                trigger OnAction()
                var
                    CSVBuffer: Record "CSV Buffer" temporary;
                    InS: InStream;
                    FileName: Text;
                    UploadMsg: Label 'Please choose the CSV file';
                    CsvFileFilter: Label 'CSV files (*.csv)|*.csv';
                    CAImportDefinitionManagement: Codeunit CAImportDefinitionManagement;
                begin
                    CAImportDefinitionManagement.CheckIfProjectExists(Rec."Project No.", 'importing columns');

                    CSVBuffer.Reset();
                    CSVBuffer.DeleteAll();
                    if UploadIntoStream(UploadMsg, '', CsvFileFilter, FileName, InS) then begin
                        CAImportDefinitionManagement.ValidateCSVFileName(FileName);
                        CSVBuffer.LoadDataFromStream(InS, ',');
                        CAImportDefinitionManagement.ImportDefinitionColumns(Rec."Project No.", CSVBuffer);
                    end;
                end;
            }
            action(CopyFromExistingDefinition)
            {
                Caption = 'Copy From Existing Definition';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Copy;
                trigger OnAction()
                var
                    CAImportDefinition: Record CAImportDefinitions;
                    CAImportDefinitionList: Page CAImportDefinitions;
                    CAImportDefinitionManagement: Codeunit CAImportDefinitionManagement;
                begin
                    CAImportDefinitionManagement.CheckIfProjectExists(Rec."Project No.", 'copying from existing definition');
                    CAImportDefinition.Reset();
                    CAImportDefinitionList.SetTableView(CAImportDefinition);
                    CAImportDefinitionList.LookupMode(true);
                    if CAImportDefinitionList.RunModal() = Action::LookupOK then begin
                        CAImportDefinitionList.GetRecord(CAImportDefinition);
                        CAImportDefinitionManagement.CopyFromExistingDefinition(Rec."Project No.", CAImportDefinition."Project No.");
                    end;
                end;
            }
        }
    }

    var
        CADimensionManagement: Codeunit CADimensionManagement;
}
