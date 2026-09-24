pageextension 51011 CAGenJournalBatch extends "General Journal Batches"
{
    layout
    {
        addafter("No. Series")
        {
            field("Claimant Batch"; Rec."Claimant Batch")
            {
                ApplicationArea = All;
            }
        }
    }
}