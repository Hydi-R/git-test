/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///         - For Payment File Imported from OneDrive
/// 
/// Deloitte AK 06092026
///    <MOD> Modified the function call in the following triggers </MOD>
///         - OnAction trigger of FetchFromSharePoint action
/// </summary>
page 51009 CASharePointLogs
{
    PageType = List;
    SourceTable = CASharePointLogs;
    CardPageId = CASharePointLogsCard;
    ApplicationArea = All;
    UsageCategory = History;
    Caption = 'SharePoint Logs';

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

                field("Line Count"; Rec."Line Count")
                {
                    ApplicationArea = All;
                }
                field("File Size"; Rec."File Size")
                {
                    ApplicationArea = All;
                }
                field("Import Date"; Rec."Import Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                }
                // field("Payment Method"; Rec."Payment Method")
                // {
                //     ApplicationArea = All;
                // }
                field(Batch; Rec."Journal Batch")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
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
            action(FetchFromSharePoint)
            {
                ApplicationArea = All;
                Caption = 'Fetch from Sharepoint';
                Image = Import;

                trigger OnAction()
                var
                    CASharepointManagement: Codeunit CASharepointManagement;
                begin
                    CASharepointManagement.ProcessSharePointFiles(); // Deloitte AK 06092026
                    CurrPage.Update(false);
                end;
            }
            action(DownloadFile)
            {
                Caption = 'Download Attached File';
                ApplicationArea = All;
                Image = ExportFile;

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
                    if FileName = '' then
                        FileName := 'DownloadedFile.txt';

                    DownloadFromStream(InStr, '', '', '', FileName);
                end;
            }
            action(Setup)
            {
                ApplicationArea = All;
                Caption = 'Setup';
                Image = Setup;
                ToolTip = 'Setup.';

                trigger OnAction()
                var
                    CAIntegrationSetup: Record CAIntegrationSetup;
                begin
                    if not CAIntegrationSetup.Get() then begin
                        CAIntegrationSetup.Init();
                        CAIntegrationSetup.Insert();
                    end;

                    Page.Run(Page::CAIntegrationSetup, CAIntegrationSetup);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(Setup_Promoted; Setup)
                {
                }
                actionref(FetchFromSharePoint_Promoted; FetchFromSharePoint)
                {
                }
                actionref(DownloadFile_Promoted; DownloadFile)
                {
                }


            }
        }
    }

}
