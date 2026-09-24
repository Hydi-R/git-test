report 51001 "Outstanding Cheque"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Layouts/OutstandingCheque.Rdlc';

    dataset
    {
        dataitem(BankLedgerEntry; "Bank Account Ledger Entry")
        {
            DataItemTableView = where(Open = const(true), "Cheque No." = filter(<> ''));
            // RequestFilterFields = "Posting Date";
            column(ReportTitle; 'Outstanding Cheque Ageing')
            {
            }
            column(CompanyTitle; CompanyInfo.Name)
            {
            }
            column(ChequeNo; "Cheque No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(ClaimID; "Claim ID")
            {
            }
            column(ClaimantName_BankLedgerEntry; "Claimant Name")
            {
            }
            column(Amount; ABs(Amount))
            {
            }
            column(Age0To30; Age0To30)
            {
            }

            column(Age31To60; Age31To60)
            {
            }

            column(Age61To90; Age61To90)
            {
            }

            column(Age91To180; Age91To180)
            {
            }

            column(AgeOver180; AgeOver180)
            {
            }
            column(AsOnDateColumn; Format('As on Date - ') + Format(AsOnDate, 0, '<Day,2>/<Month,2>/<Year4>'))
            {
            }

            trigger OnAfterGetRecord()
            begin
                Clear(Age0To30);
                Clear(Age31To60);
                Clear(Age61To90);
                Clear(Age91To180);
                Clear(AgeOver180);

                DaysOutstanding := AsOnDate - "Posting Date";
                case true of
                    (DaysOutstanding >= 0) and (DaysOutstanding <= 30):
                        Age0To30 := Abs(Amount);

                    (DaysOutstanding > 30) and (DaysOutstanding <= 60):
                        Age31To60 := Abs(Amount);

                    (DaysOutstanding > 60) and (DaysOutstanding <= 90):
                        Age61To90 := Abs(Amount);

                    (DaysOutstanding > 90) and (DaysOutstanding <= 180):
                        Age91To180 := Abs(Amount);

                    DaysOutstanding > 180:
                        AgeOver180 := Abs(Amount);
                end;
                // Accumulate all records
                AgeAmounts[1] += Age0To30;
                AgeAmounts[2] += Age31To60;
                AgeAmounts[3] += Age61To90;
                AgeAmounts[4] += Age91To180;
                AgeAmounts[5] += AgeOver180;
                CalcPercents(TotalOutstanding, AgeAmounts);
            end;
        }
        dataitem(PercentageSummary; "Integer")
        {
            DataItemTableView = where(Number = const(1));
            column(ReportInteger; Number)
            {
            }
            column(PercentString_1_; PercentString[1])
            {
            }

            column(PercentString_2_; PercentString[2])
            {
            }

            column(PercentString_3_; PercentString[3])
            {
            }

            column(PercentString_4_; PercentString[4])
            {
            }

            column(PercentString_5_; PercentString[5])
            {
            }

            column(TotalOutstanding; TotalOutstanding)
            {
            }

            trigger OnAfterGetRecord()
            begin
                TotalOutstanding :=
                    AgeAmounts[1] +
                    AgeAmounts[2] +
                    AgeAmounts[3] +
                    AgeAmounts[4] +
                    AgeAmounts[5];

                CalcPercents(TotalOutstanding, AgeAmounts);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Report Filter';
                    field(AsOnDateControl; AsOnDate)
                    {
                        ApplicationArea = All;
                        Caption = 'As on Date';
                        ToolTip = 'Specifies the date used to calculate the outstanding cheque ageing.';
                        trigger OnValidate()
                        begin
                            if AsOnDate = 0D then AsOnDate := WorkDate();
                        end;
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            if AsOnDate = 0D then AsOnDate := WorkDate();
        end;
    }
    procedure CalcPercents(Total: Decimal; Amounts: array[5] of Decimal)
    var
        i: Integer;
        k: Integer;
    begin
        Clear(PercentString);
        if Total <> 0 then
            for i := 1 to 5 do begin
                Percent := Amounts[i] / Total * 100.0;
                if StrLen(Format(Round(Percent))) + 4 > MaxStrLen(PercentString[1]) then
                    PercentString[i] := PadStr(PercentString[i], MaxStrLen(PercentString[i]), '*')
                else begin
                    PercentString[i] := Format(Round(Percent));
                    k := StrPos(PercentString[i], '.');
                    if k = 0 then
                        PercentString[i] := PercentString[i] + '.00'
                    else
                        if k = StrLen(PercentString[i]) - 1 then
                            PercentString[i] := PercentString[i] + '0';
                    PercentString[i] := PercentString[i] + '%';
                end;
            end;
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.get;
    end;

    var
        DaysOutstanding: Integer;
        Age0To30: Decimal;
        Age31To60: Decimal;
        Age61To90: Decimal;
        Age91To180: Decimal;
        AgeOver180: Decimal;
        CompanyInfo: Record "Company Information";
        PercentString: array[5] of Text[20];
        TotalOutstanding: Decimal;
        AgeAmounts: array[5] of Decimal;
        Percent: Decimal;
        AsOnDate: Date;

}