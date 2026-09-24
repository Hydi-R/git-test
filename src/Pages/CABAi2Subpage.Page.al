page 51003 "BNS BAI2 Statement Subpage"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "BNS BAI2 Import Line";
    Caption = 'BAI2 Transactions';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }

                field("BAI2 Account No."; Rec."BAI2 Account No.")
                {
                    ApplicationArea = All;
                }

                field("Account Currency"; Rec."Account Currency")
                {
                    ApplicationArea = All;
                }

                field("Closing Balance"; Rec."Closing Balance")
                {
                    ApplicationArea = All;
                }

                field("Total Credits"; Rec."Total Credits")
                {
                    ApplicationArea = All;
                }

                field("Credit Count"; Rec."Credit Count")
                {
                    ApplicationArea = All;
                }

                field("Total Debits"; Rec."Total Debits")
                {
                    ApplicationArea = All;
                }

                field("Debit Count"; Rec."Debit Count")
                {
                    ApplicationArea = All;
                }

                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = All;
                }

                field("Transaction Amount"; Rec."Transaction Amount")
                {
                    ApplicationArea = All;
                }

                field("Financial Effect"; Rec."Financial Effect")
                {
                    ApplicationArea = All;
                }

                field("Funds Type"; Rec."Funds Type")
                {
                    ApplicationArea = All;
                }

                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                }

                // field("Payment Method Type"; Rec.payme)
                // {
                //     ApplicationArea = All;
                // }

                field("Cheque No."; Rec."Cheque No.")
                {
                    ApplicationArea = All;
                }

                field("Transaction Text"; Rec."Transaction Text")
                {
                    ApplicationArea = All;
                }

                field(Matched; Rec.Matched)
                {
                    ApplicationArea = All;
                }

                field("Matched Entry No."; Rec."Matched Entry No.")
                {
                    ApplicationArea = All;
                }

                field(Processed; Rec.Processed)
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
}