/// <summary>
/// Deloitte AK 18092026
///     <NEW>New object created </NEW>
/// </summary>
report 51004 CAStatementOfOperations
{
    AccessByPermission = TableData "G/L Account" = R;
    ApplicationArea = Basic, Suite;
    Caption = 'Statement of Operations';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = false;

    dataset
    {
    }

    requestpage
    {
        AboutTitle = 'About Statement of Operations';
        AboutText = 'The **Statement of Operations** report is a key finance report with data and layout based on a financial report definition. You can change the financial report definition used for the report on the *General Ledger Setup* page under the *Reporting* section.';

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        GLAccountCategoryMgt.GetGLSetup(GeneralLedgerSetup);
        GLAccountCategoryMgt.RunAccountScheduleReport(GeneralLedgerSetup."Statement of Operations Report");


    end;
}