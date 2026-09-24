/// <summary>
///  Deloitte AK 10082026
///     <FLD> Following fields added </FLD>
///         - Claim Id
///         - Claimant Name
/// </summary>
pageextension 51001 CABankAccLedgerEntry extends "Bank Account Ledger Entries"
{

    layout
    {
        addafter("Amount")
        {
            field("Claim ID"; Rec."Claim ID")
            {
                ApplicationArea = All;
            }
            field("Claimant Name"; Rec."Claimant Name")
            {
                ApplicationArea = All;
            }
            field("Transaction Ref. No."; Rec."Transaction Ref. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Transaction Ref. No. field.', Comment = '%';

            }
            field("Claimant Institution No."; Rec."Claimant Institution No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Claimant Institution No. field.', Comment = '%';
            }
            field("Claimant Transit No."; Rec."Claimant Transit No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Claimant Transit No. field.', Comment = '%';
            }
            field("Claimant Account No."; Rec."Claimant Account No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Claimant Account No. field.', Comment = '%';
            }
            field("Cheque No."; Rec."Cheque No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Cheque No. field.', Comment = '%';
            }
        }
    }
    // actions
    // {
    //     addafter("Check Ledger E&ntries")
    //     {
    //         action(GenerateClaim)
    //         {
    //             ApplicationArea = All;
    //             Caption = 'Generate Claim';
    //             Image = Generate;

    //             trigger OnAction()
    //             var
    //                 GenClaim: Codeunit "Generate Claim";
    //                 ChangeClaimID: Page "Change Claim ID";
    //                 NewClaimID: Code[20];
    //             begin
    //                 ChangeClaimID.SetClaimID(Rec."Cheque No.");

    //                 if ChangeClaimID.RunModal() = Action::OK then begin
    //                     NewClaimID := ChangeClaimID.GetNewClaimID();

    //                     GenClaim.ChangeClaimID(Rec, NewClaimID);

    //                     CurrPage.Update(false);
    //                 end;
    //             end;
    //         }
    //     }
    // }
}
