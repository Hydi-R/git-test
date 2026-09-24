page 51001 "BNS BAI2 Statement"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "BNS BAI2 Import Header";
    Caption = 'BNS BAI2 Statement';

    layout
    {
        area(Content)
        {
            group(FileInformation)
            {
                Caption = 'File Information';

                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Receiver ID"; Rec."Receiver ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("File Creation Date"; Rec."File Creation Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("File Creation Time"; Rec."File Creation Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("File Version"; Rec."File Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(StatementInformation)
            {
                Caption = 'Statement Information';

                field("BC Bank Account No."; Rec."BC Bank Account No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BAI2 Account No."; Rec."BAI2 Account No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Statement Date"; Rec."Statement Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Group Receiver ID"; Rec."Group Receiver ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Bank ID"; Rec."Bank ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Group Status"; Rec."Group Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("As Of Mode"; Rec."As Of Mode")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            part(Lines; "BNS BAI2 Statement Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }

            group(AccountControlInformation)
            {
                Caption = 'Account Control Information';

                field("Closing Balance"; Rec."Closing Balance")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Total Credits"; Rec."Total Credits")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Credit Count"; Rec."Credit Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Total Debits"; Rec."Total Debits")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Debit Count"; Rec."Debit Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Account Control Total"; Rec."Account Control Total")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Account Control Count"; Rec."Account Control Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(ControlInformation)
            {
                Caption = 'BAI2 File Control Information';

                field("Group Control Total"; Rec."Group Control Total")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Group Control Count"; Rec."Group Control Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Group Account Count"; Rec."Group Account Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("File Control Total"; Rec."File Control Total")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("File Group Count"; Rec."File Group Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("File Record Count"; Rec."File Record Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}