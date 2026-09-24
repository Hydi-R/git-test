/// <summary>
///  Deloitte AK 10082026
///     <NEW> New Object Created </NEW>
///         - Import Definitions List
/// </summary>
page 51006 CAImportDefinitions
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = CAImportDefinitions;
    Caption = 'Import Definitions';
    Editable = false;
    CardPageId = CAImportDefinition;

    layout
    {
        area(Content)
        {
            repeater(Projects)
            {
                field("Project No."; Rec."Project No.")
                {
                    ApplicationArea = All;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = All;
                }
                // field("Payment Method"; Rec."Payment Method")  // Payment Method Commented
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }
}
