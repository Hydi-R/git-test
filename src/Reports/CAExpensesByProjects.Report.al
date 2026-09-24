/// <summary>
/// Deloitte AK 17092026
///     <NEW>New object created </NEW>
/// </summary>
report 51003 CAExpensesByProjects
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Layouts/CAExpensesByProjects.Layout.rdl';
    AdditionalSearchTerms = 'expenses, Ledgers By Projects';
    ApplicationArea = Basic, Suite;
    Caption = 'Expenses By Projects';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = where("Account Type" = const(Posting));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Search Name", "Income/Balance", "Debit/Credit", "Date Filter";
            column(PeriodGLDtFilter; StrSubstNo(Text000, GLDateFilter))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ExcludeBalanceOnly; ExcludeBalanceOnly)
            {
            }
            column(PrintReversedEntries; PrintReversedEntries)
            {
            }
            column(PageGroupNo; PageGroupNo)
            {
            }
            column(PrintOnlyOnePerPage; PrintOnlyOnePerPage)
            {
            }
            column(PrintClosingEntries; PrintClosingEntries)
            {
            }
            column(PrintOnlyCorrections; PrintOnlyCorrections)
            {
            }
            column(GLAccTableCaption; TableCaption + ': ' + GLFilter)
            {
            }
            column(GLFilter; GLFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(No_GLAcc; "No.")
            {
            }
            column(ExpensesByProjects; ExpensesByProjectsLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(PeriodCaption; PeriodCaptionLbl)
            {
            }
            column(OnlyCorrectionsCaption; OnlyCorrectionsCaptionLbl)
            {
            }
            column(NetChangeCaption; NetChangeCaptionLbl)
            {
            }
            column(GLEntryDebitAmtCaption; GLEntryDebitAmtCaptionLbl)
            {
            }
            column(GLEntryCreditAmtCaption; GLEntryCreditAmtCaptionLbl)
            {
            }
            column(GLBalCaption; GLBalCaptionLbl)
            {
            }
            dataitem(PageCounter; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(Name_GLAcc; "G/L Account".Name)
                {
                }
                column(StartBalance; StartBalance)
                {
                    AutoFormatType = 1;
                }
                dataitem("G/L Entry"; "G/L Entry")
                {
                    DataItemLink = "G/L Account No." = field("No."), "Posting Date" = field("Date Filter"), "Global Dimension 1 Code" = field("Global Dimension 1 Filter"), "Global Dimension 2 Code" = field("Global Dimension 2 Filter"), "Business Unit Code" = field("Business Unit Filter"), "Dimension Set ID" = field("Dimension Set ID Filter");
                    DataItemLinkReference = "G/L Account";
                    DataItemTableView = sorting("G/L Account No.", "Posting Date");
                    column(VATAmount_GLEntry; "VAT Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(Amount; Amount)
                    {
                    }
                    column(DebitAmount_GLEntry; "Debit Amount")
                    {
                    }
                    column(CreditAmount_GLEntry; "Credit Amount")
                    {
                    }
                    column(PostingDate_GLEntry; Format("Posting Date"))
                    {
                    }
                    column(DocumentNo_GLEntry; "Document No.")
                    {
                    }
                    column(ExtDocNo_GLEntry; "External Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_GLEntry; Description)
                    {
                    }
                    column(GLBalance; GLBalance)
                    {
                        AutoFormatType = 1;
                    }
                    column(EntryNo_GLEntry; "Entry No.")
                    {
                    }
                    column(ClosingEntry; ClosingEntry)
                    {
                    }
                    column(Reversed_GLEntry; Reversed)
                    {
                    }
                    column(ProjectCode_GLEntry; "Global Dimension 1 Code")
                    {
                    }
                    column(Claim_ID; "Claim ID")
                    {
                    }
                    column(Claimant_Name; "Claimant Name")
                    {
                    }
                    column(Cheque_No_; "Cheque No.")
                    {
                    }
                    column(Payment_Batch_Number; "Payment Batch Number")
                    {
                    }
                    column(Stop_Payment_Date; "Stop Payment Date")
                    {
                    }
                    column(Reason_for_Stop_Payment; "Reason for Stop Payment")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if PrintOnlyCorrections then
                            if not (("Debit Amount" < 0) or ("Credit Amount" < 0)) then
                                CurrReport.Skip();
                        if not PrintReversedEntries and Reversed then
                            CurrReport.Skip();

                        GLBalance := GLBalance + Amount;
                        if ("Posting Date" = ClosingDate("Posting Date")) and
                           not PrintClosingEntries
                        then begin
                            "Debit Amount" := 0;
                            "Credit Amount" := 0;
                        end;

                        if "Posting Date" = ClosingDate("Posting Date") then
                            ClosingEntry := true
                        else
                            ClosingEntry := false;

                        NumberOfGLEntryLines += 1;
                    end;

                    trigger OnPreDataItem()
                    begin
                        GLBalance := StartBalance;

                        if ProjectFilter <> '' then
                            SetFilter("Global Dimension 1 Code", ProjectFilter)
                        else
                            if ExcludeEntriesWithoutProject then
                                SetFilter("Global Dimension 1 Code", '<>%1', '');
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.PrintOnlyIfDetail := ExcludeBalanceOnly or (StartBalance = 0);
                end;
            }

            trigger OnAfterGetRecord()
            var
                GLEntry: Record "G/L Entry";
                Date: Record Date;
            begin
                StartBalance := 0;
                if GLDateFilter <> '' then begin
                    Date.SetRange("Period Type", Date."Period Type"::Date);
                    Date.SetFilter("Period Start", GLDateFilter);
                    if Date.FindFirst() then begin
                        SetRange("Date Filter", 0D, ClosingDate(Date."Period Start" - 1));
                        CalcFields("Net Change");
                        StartBalance := "Net Change";
                        SetFilter("Date Filter", GLDateFilter);
                    end;
                end;

                if PrintOnlyOnePerPage then begin
                    GLEntry.Reset();
                    GLEntry.SetRange("G/L Account No.", "No.");
                    if CurrReport.PrintOnlyIfDetail and (not GLEntry.IsEmpty()) then
                        PageGroupNo := PageGroupNo + 1;
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Account Category", AccountCategoryFilter);
                PageGroupNo := 1;
            end;
        }
    }

    requestpage
    {
        // SaveValues = true;
        AboutTitle = 'About Expenses by Projects';
        AboutText = 'View bank account balances at the end of the period, including the opening balance, each transaction within the period, and the closing balance grouped by bank. View a running balance and reconciled entries.';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NewPageperGLAcc; PrintOnlyOnePerPage)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Page per G/L Acc.';
                        ToolTip = 'Specifies if each G/L account information is printed on a new page if you have chosen two or more G/L accounts to be included in the report.';
                    }
                    field(ExcludeGLAccsHaveBalanceOnly; ExcludeBalanceOnly)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Exclude G/L Accs. That Have a Balance Only';
                        MultiLine = true;
                        ToolTip = 'Specifies if you do not want the report to include entries for G/L accounts that have a balance but do not have a net change during the selected time period.';
                    }
                    field(InclClosingEntriesWithinPeriod; PrintClosingEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Closing Entries Within the Period';
                        MultiLine = true;
                        ToolTip = 'Specifies if you want the report to include closing entries. This is useful if the report covers an entire fiscal year. Closing entries are listed on a fictitious date between the last day of one fiscal year and the first day of the next one. They have a C before the date, such as C123194. If you do not select this field, no closing entries are shown.';
                    }
                    field(IncludeReversedEntries; PrintReversedEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Reversed Entries';
                        ToolTip = 'Specifies if you want to include reversed entries in the report.';
                    }
                    field(PrintCorrectionsOnly; PrintOnlyCorrections)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Corrections Only';
                        ToolTip = 'Specifies if you want the report to show only the entries that have been reversed and their matching correcting entries.';
                    }
                    field(ExcludeEntriesWithoutProject; ExcludeEntriesWithoutProject)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Exclude Entries Without Project';
                        ToolTip = 'Specifies whether to exclude G/L entries that do not have a Project dimension value.';
                        trigger OnValidate()
                        begin
                            if ExcludeEntriesWithoutProject then
                                ProjectFilter := '';
                        end;
                    }
                    field(AccountCategoryFilter; AccountCategoryFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Account Category';
                        Editable = false;
                        ToolTip = 'Specifies the account category to include in the report.';
                    }
                    field(ProjectFilter; ProjectFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Project';
                        ToolTip = 'Specifies the Project dimension values to include in the report.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            DimensionValueList: Page "Dimension Value List";
                            DimensionValue: Record "Dimension Value";
                            GLSetup: Record "General Ledger Setup";
                        begin
                            GLSetup.Get();

                            DimensionValue.Reset();
                            DimensionValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");

                            DimensionValueList.SetTableView(DimensionValue);
                            DimensionValueList.LookupMode(true);

                            if DimensionValueList.RunModal() = Action::LookupOK then begin
                                Text := DimensionValueList.GetSelectionFilter();
                                exit(true);
                            end;
                            exit(false);
                        end;

                        trigger OnValidate()
                        begin
                            if ProjectFilter <> '' then
                                ExcludeEntriesWithoutProject := false;
                        end;
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            AccountCategoryFilter := AccountCategoryFilter::Expense;
        end;
    }

    labels
    {
        PostingDateCaption = 'Posting Date';
        DocNoCaption = 'Document No.';
        DescCaption = 'Description';
        VATAmtCaption = 'VAT Amount';
        EntryNoCaption = 'Entry No.';
    }

    trigger OnPreReport()
    begin
        StartDateTime := CurrentDateTime();
        "G/L Account".SecurityFiltering(SecurityFilter::Filtered);
        "G/L Entry".SecurityFiltering(SecurityFilter::Filtered);
        GLFilter := "G/L Account".GetFilters();
        GLDateFilter := "G/L Account".GetFilter("Date Filter");
    end;

    trigger OnPostReport()
    begin
        FinishDateTime := CurrentDateTime();
        LogReportTelemetry(StartDateTime, FinishDateTime, NumberOfGLEntryLines);
    end;

    var
#pragma warning disable AA0074
#pragma warning disable AA0470
        Text000: Label 'Period: %1';
#pragma warning restore AA0470
#pragma warning restore AA0074
        GLDateFilter: Text;
        GLBalance: Decimal;
        StartBalance: Decimal;
        PrintOnlyOnePerPage: Boolean;
        ExcludeBalanceOnly: Boolean;
        PrintClosingEntries: Boolean;
        PrintOnlyCorrections: Boolean;
        PrintReversedEntries: Boolean;
        PageGroupNo: Integer;
        ClosingEntry: Boolean;
        ExpensesByProjectsLbl: Label 'Expenses by Projects';
        PageCaptionLbl: Label 'Page';
        BalanceCaptionLbl: Label 'This also includes general ledger accounts that only have a balance.';
        PeriodCaptionLbl: Label 'This report also includes closing entries within the period.';
        OnlyCorrectionsCaptionLbl: Label 'Only corrections are included.';
        NetChangeCaptionLbl: Label 'Net Change';
        GLEntryDebitAmtCaptionLbl: Label 'Debit';
        GLEntryCreditAmtCaptionLbl: Label 'Credit';
        GLBalCaptionLbl: Label 'Balance';
        TelemetryCategoryTxt: Label 'Report', Locked = true;
        ExpensesbyProjectsGeneratedTxt: Label 'Expenses by Projects report generated.', Locked = true;
        AccountCategoryFilter: Enum "G/L Account Category";
        ProjectFilter: Text[250];
        ExcludeEntriesWithoutProject: Boolean;

    protected var
        GLFilter: Text;
        NumberOfGLEntryLines: Integer;
        StartDateTime: DateTime;
        FinishDateTime: DateTime;

    /// <summary>
    /// Initializes report parameters for programmatic execution with detailed filtering and display options.
    /// Configures entry type filters, page break options, and transaction inclusion criteria for customized expenses generation.
    /// </summary>
    /// <param name="NewPrintOnlyOnePerPage">Whether to print only one account per page</param>
    /// <param name="NewExcludeBalanceOnly">Whether to exclude accounts with balance-only information</param>
    /// <param name="NewPrintClosingEntries">Whether to include closing entries in the report</param>
    /// <param name="NewPrintReversedEntries">Whether to include reversed entries in the report</param>
    /// <param name="NewPrintOnlyCorrections">Whether to print only correction entries</param>
    procedure InitializeRequest(NewPrintOnlyOnePerPage: Boolean; NewExcludeBalanceOnly: Boolean; NewPrintClosingEntries: Boolean; NewPrintReversedEntries: Boolean; NewPrintOnlyCorrections: Boolean)
    begin
        PrintOnlyOnePerPage := NewPrintOnlyOnePerPage;
        ExcludeBalanceOnly := NewExcludeBalanceOnly;
        PrintClosingEntries := NewPrintClosingEntries;
        PrintReversedEntries := NewPrintReversedEntries;
        PrintOnlyCorrections := NewPrintOnlyCorrections;
    end;

    local procedure LogReportTelemetry(StartDateTime: DateTime; FinishDateTime: DateTime; NumberOfLines: Integer)
    var
        Dimensions: Dictionary of [Text, Text];
        ReportDuration: BigInteger;
    begin
        ReportDuration := FinishDateTime - StartDateTime;
        Dimensions.Add('Category', TelemetryCategoryTxt);
        Dimensions.Add('ReportStartTime', Format(StartDateTime, 0, 9));
        Dimensions.Add('ReportFinishTime', Format(FinishDateTime, 0, 9));
        Dimensions.Add('ReportDuration', Format(ReportDuration));
        Dimensions.Add('NumberOfLines', Format(NumberOfLines));
        Session.LogMessage('0000FJL', ExpensesbyProjectsGeneratedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
    end;
}

