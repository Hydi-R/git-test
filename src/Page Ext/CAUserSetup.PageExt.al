
pageextension 51013 UserSetupPageExt extends "User Setup"
{
    layout
    {
        addafter("User ID")
        {
            field("Share Point Folder Path"; Rec."Share Point Folder Path")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Share Point Folder Path field.', Comment = '%';
            }
        }
    }
}
