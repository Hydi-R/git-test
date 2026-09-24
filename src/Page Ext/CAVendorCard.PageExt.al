/// <summary>
/// Deloitte AK 02092026
///     <NEW> New Object Created </NEW>
/// </summary>
pageextension 51012 CAVendorCard extends "Vendor Card"
{
    layout
    {
        modify(Blocked)
        {
            Editable = false;
            Enabled = false;
        }
        addlast(General)
        {
            field("Approval Status"; Rec."Approval Status")
            {
                ApplicationArea = All;
                styleExpr = StatusStyleTxt;
                ToolTip = 'Specifies the value of the Approval Status field.', Comment = '%';
            }
        }
        modify(General)
        {
            Editable = IsEnabled;
            Enabled = IsEnabled;
        }
        modify("Address & Contact")
        {
            Editable = IsEnabled;
            Enabled = IsEnabled;
        }
        modify(Invoicing)
        {
            Editable = IsEnabled;
            Enabled = IsEnabled;
        }
        modify(Payments)
        {
            Editable = IsEnabled;
            Enabled = IsEnabled;
        }
        modify(Receiving)
        {
            Editable = IsEnabled;
            Enabled = IsEnabled;
        }
    }
    actions
    {
        modify(SendApprovalRequest)
        {
            trigger OnBeforeAction()
            begin
                If Rec."Approval Status" = Rec."Approval Status"::Approved then
                    Error(VendorAlreadyApprovedMsg);
                If Rec."Approval Status" = Rec."Approval Status"::"Pending Approval" then
                    Error(VendorPendingApprovalMsg);
                Rec."CA Sender ID" := UserId;
                Rec.Modify();
            end;
        }
        addlast("Request Approval")
        {
            action(Reopen)
            {
                Caption = 'Reopen';
                Image = ReOpen;
                ApplicationArea = All;
                Enabled = ToBeReopened;
                trigger OnAction()
                begin
                    If Rec."Approval Status" = Rec."Approval Status"::Approved then begin
                        Rec."Approval Status" := Rec."Approval Status"::Open;
                        Rec.Blocked := Rec.Blocked::All;
                        Rec.Modify();
                    end;
                end;
            }
        }
        addlast(Category_Category5)
        {
            actionref(Reopen_Promoted; Reopen)
            {
            }
        }
    }
    trigger OnOpenPage()
    begin
        IsEnabled := Not (Rec."Approval Status" in [Rec."Approval Status"::Approved, Rec."Approval Status"::"Pending Approval"]) ? true : false;
        ToBeReopened := Rec."Approval Status" = Rec."Approval Status"::Approved ? true : false;
    end;

    trigger OnAfterGetRecord()
    begin
        IsEnabled := Not (Rec."Approval Status" in [Rec."Approval Status"::Approved, Rec."Approval Status"::"Pending Approval"]) ? true : false;
        ToBeReopened := Rec."Approval Status" = Rec."Approval Status"::Approved ? true : false;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        StatusStyleTxt := Rec.GetStatusStyleText();
    end;

    var
        StatusStyleTxt: Text;
        IsEnabled: Boolean;
        ToBeReopened: Boolean;
        VendorAlreadyApprovedMsg: Label 'Vendor is already approved. Cannot send approval request.';
        VendorPendingApprovalMsg: Label 'Vendor is in Pending Approval. Cannot send approval request.';
}