/// <summary>
/// Payment file import header and row-level audit details.
/// </summary>
page 51030 CASharePointLogsCard
{
    PageType = Card;
    SourceTable = CASharePointLogs;
    ApplicationArea = All;
    Caption = 'SharePoint Log';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Import Date"; Rec."Import Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Batch; Rec."Journal Batch")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line Count"; Rec."Line Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("File Size"; Rec."File Size")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    Editable = false;
                }
            }
            part(Lines; CASharePointLogsSubform)
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowErrors)
            {
                ApplicationArea = All;
                Caption = 'Show Errors';
                Image = Error;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PaymentFileImportLine: Record CASharePointLogsLine;
                    ErrorText: Text;
                begin
                    PaymentFileImportLine.SetRange("Entry No.", Rec."Entry No.");
                    if PaymentFileImportLine.FindSet() then
                        repeat
                            if PaymentFileImportLine."Error List" <> '' then
                                ErrorText += StrSubstNo('Line %1: %2\', PaymentFileImportLine."Source Line No.", PaymentFileImportLine."Error List");
                        until PaymentFileImportLine.Next() = 0;
                    if ErrorText = '' then
                        Message('No errors exist for the selected payment import.')
                    else
                        Message(ErrorText);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = All;
                Caption = 'Download Attached File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    InStr: InStream;
                    FileName: Text;
                begin
                    Rec.CalcFields("File Content");
                    if not Rec."File Content".HasValue() then
                        Error('No file content exists for the selected record.');
                    Rec."File Content".CreateInStream(InStr);
                    FileName := Rec."File Name";
                    DownloadFromStream(InStr, '', '', '', FileName);
                end;
            }
        }
    }
}
