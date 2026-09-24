page 51002 "BNS BAI2 Import List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BNS BAI2 Import Header";
    Caption = 'BNS BAI2 Imports';
    CardPageId = "BNS BAI2 Statement";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }

                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                }

                field("BC Bank Account No."; Rec."BC Bank Account No.")
                {
                    ApplicationArea = All;
                }

                field("Statement Date"; Rec."Statement Date")
                {
                    ApplicationArea = All;
                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }

                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = All;
                }

                field("Receiver ID"; Rec."Receiver ID")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

                field("File Control Total"; Rec."File Control Total")
                {
                    ApplicationArea = All;
                }

                field("File Record Count"; Rec."File Record Count")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewStatement)
            {
                ApplicationArea = All;
                Caption = 'View Statement';
                Image = View;

                RunObject = page "BNS BAI2 Statement";
                RunPageLink = "Entry No." = field("Entry No.");
            }

            action("Import BNS .225")
            {
                ApplicationArea = All;
                Caption = 'Import BNS .225';
                Image = Import;

                trigger OnAction()
                var
                    BNSImport: Codeunit "BNS BAI2 Bank Import";
                    InStream: InStream;
                    FileName: Text;
                    UploadSuccessful: Boolean;
                begin
                    UploadSuccessful :=
                        UploadIntoStream(
                          'Select Scotiabank BAI2 Statement File', '*.*', 'All Files (*.*)|*.*', FileName, InStream);

                    if not UploadSuccessful then
                        exit;

                    BNSImport.ImportFile(
                        FileName,
                        InStream);

                    Message(
                        'BNS .225 file %1 imported successfully for Bank Account %2.',
                        FileName);
                end;
            }

        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Import BNS .225_Promoted"; "Import BNS .225")
                {
                }
            }
        }
    }
    trigger OnDeleteRecord(): Boolean
    var
        ImportedLines: Record "BNS BAI2 Import Line";
    begin
        if ImportedLines.Get(Rec."Entry No.") then ImportedLines.DeleteAll();
    end;
}