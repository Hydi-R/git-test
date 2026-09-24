/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///         - For Integration Setup
/// </summary>
page 51008 CAIntegrationSetup
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = CAIntegrationSetup;
    Caption = 'Integration Setup';

    layout
    {
        area(Content)
        {
            group(CMT_Integration)
            {
                Caption = 'CMT Integration';
                // field("SharePoint Source Folder URL"; Rec."SharePoint Source Folder URL")
                // {
                //     ToolTip = 'Specify the OneDrive folder path or Microsoft Graph children URL where payment CSV files are located.';
                // }
                field("SharePoint Archive Folder"; Rec."SharePoint Archive Folder")
                {
                    ToolTip = 'Specify the OneDrive folder URL where files will be moved after processing';
                }
                field("SharePoint Error Folder"; Rec."SharePoint Error Folder")
                {
                    ToolTip = 'Specifies the SharePoint folder where files with validation errors are moved.', Comment = '%';
                }
                field("File Pattern"; Rec."File Pattern")
                {
                    ToolTip = 'Use wildcard patterns like Payment*.csv to filter files';
                }
                field("Payment Batch"; Rec."Payment Batch")
                {
                    ToolTip = 'Specifies the value of the Payment Batch field.', Comment = '%';
                }
                field("Payment Template"; Rec."Payment Template")
                {
                    ToolTip = 'Specifies the value of the Payment Template field.', Comment = '%';
                }
                field("Last Run DateTime"; Rec."Last Run DateTime")
                {

                }
                field("Last Run Status"; Rec."Last Run Status")
                {

                }
            }

            group("Bank Integration")
            {
                group("Generic")
                {
                    field("Msg ID No. Series"; Rec."Msg ID No. Series")
                    {
                        ToolTip = 'No. Series for CA Message ID.';
                    }
                    field("Sender Name"; Rec."Sender Name")
                    {
                        toolTip = 'Specifies the value of the Sender Name field.', Comment = '%';
                    }
                    field("Sender ID"; Rec."Sender ID")
                    {
                        toolTip = 'Specifies the value of the Sender ID field.', Comment = '%';
                    }
                    field("Currency Code"; Rec."Currency Code")
                    {
                        ToolTip = 'Specifies the value of the Currency field.', Comment = '%';
                    }
                }
                group(EFT)
                {
                    field("EFT Purpose Code"; Rec."EFT Purpose Code")
                    {
                        ToolTip = 'Specifies the value of the EFT Purpose Code field.', Comment = '%';
                    }
                    field("EFT Execution Offset Days"; Rec."EFT Execution Offset Days")
                    {
                        ToolTip = 'Specifies the value of the EFT Execution Offset Days field.', Comment = '%';
                    }
                    field("EFT Account No."; Rec."EFT Account No.")
                    {
                        ToolTip = 'Specifies the value of the EFT GL Account No. field.', Comment = '%';
                    }
                }
                group(EMT)
                {
                    field("EMT Execution Offset Days"; Rec."EMT Execution Offset Days")
                    {
                        ToolTip = 'Specifies the value of the EMT Execution Offset Days field.', Comment = '%';
                    }
                    field("EMT Account No."; Rec."EMT Account No.")
                    {
                        ToolTip = 'Specifies the value of the EMT GL Account No. field.', Comment = '%';
                    }
                }
                group(CHQ)
                {
                    field("CHQ Sender Title Line"; Rec."CHQ Sender Title Line")
                    {
                        ToolTip = 'Specifies the value of the CHQ Sender Title Line field.', Comment = '%';
                    }
                    field("CHQ Sender Address Line"; Rec."CHQ Sender Address Line")
                    {
                        ToolTip = 'Specifies the value of the CHQ Sender Address Line field.', Comment = '%';
                    }
                    field("CHQ Sender City"; Rec."CHQ Sender City")
                    {
                        ToolTip = 'Specifies the value of the CHQ Sender City field.', Comment = '%';
                    }
                    field("CHQ Sender Province"; Rec."CHQ Sender Province")
                    {
                        ToolTip = 'Specifies the value of the CHQ Sender Province field.', Comment = '%';
                    }
                    field("CHQ Sender Postal Code"; Rec."CHQ Sender Postal Code")
                    {
                        ToolTip = 'Specifies the value of the CHQ Sender Postal Code field.', Comment = '%';
                    }
                    field("CHQ Sender Country Code"; Rec."CHQ Sender Country Code")
                    {
                        ToolTip = 'Specifies the value of the CHQ Sender Country Code field.', Comment = '%';
                    }
                    field("CHQ Execution Offset Days"; Rec."CHQ Execution Offset Days")
                    {
                        ToolTip = 'Specifies the value of the CHQ Execution Offset Days field.', Comment = '%';
                    }
                    field("Cheque Account No."; Rec."Cheque Account No.")
                    {
                        ToolTip = 'Specifies the value of the Cheque GL Account No. field.', Comment = '%';
                    }
                }
                group(SharePoint)
                {
                    field("SharePoint Payment File Upload"; Rec."SharePoint Payment File Upload")
                    {
                        ToolTip = 'Specifies the value of the SharePoint Payment File Upload field.', Comment = '%';
                    }
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

}
