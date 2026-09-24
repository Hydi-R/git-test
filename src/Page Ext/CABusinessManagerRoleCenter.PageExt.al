/// <summary>
///  Deloitte AK 10082026
///     <ACT> Following actions added </ACT>
///         - Claim Id
///         - Claimant Name
/// </summary>
pageextension 51003 CABusinessManagerRoleCenter extends "Business Manager Role Center"
{
    actions
    {
        addafter(Action39)
        {
            group(Reports_)
            {
                Caption = 'Reports';
                action(ChangeLogEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Change Log Entries';
                    Image = ChangeLog;
                    RunObject = report "Change Log Entries";
                }
                action(BankReconciliation)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Reconciliation';
                    Image = Reconcile;
                    RunObject = report "Bank Acc. Recon. - Test";
                }
            }
        }
    }
}