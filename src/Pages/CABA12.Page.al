page 51000 "BNS BAI2 Import Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BNS BAI2 Import Line";
    Caption = 'BNS BAI2 Import Lines';

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

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }

                field("Account No."; Rec."Account No.")
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

                field("Transaction Text"; Rec."Transaction Text")
                {
                    ApplicationArea = All;
                }

                field("Cheque No."; Rec."Cheque No.")
                {
                    ApplicationArea = All;
                }

                field("Matched"; Rec."Matched")
                {
                    ApplicationArea = All;
                }

                field("Processed"; Rec."Processed")
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