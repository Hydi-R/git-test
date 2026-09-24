// codeunit 51100 "Fraud Detection"
// {
//     Permissions = tabledata "Bank Account Ledger Entry" = rm;

//     procedure ChangeClaimID(
//         var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
//         FraudText: Code[20])
//     begin
//         if FraudText = '' then
//             Error('Claim ID cannot be empty.');

//         // BankAccountLedgerEntry.FraudText := FraudText;
//         BankAccountLedgerEntry.Modify(true);
//     end;
// }
// page 51101 "Change Fraud Status"
// {
//     PageType = StandardDialog;
//     Caption = 'Change Fraud Status';

//     layout
//     {
//         area(Content)
//         {
//             group(General)
//             {
//                 field(ChangeFraudStatus; ChangeFraudStatus)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Changed Status';
//                 }
//             }
//         }
//     }

//     var
//         ChangeFraudStatus: Code[20];

//     procedure GetNewstatus(): Code[20]
//     begin
//         exit(ChangeFraudStatus);
//     end;

//     procedure SetClaimID(FraudStatus: Code[20])
//     begin
//         ChangeFraudStatus := FraudStatus;
//     end;
// }
