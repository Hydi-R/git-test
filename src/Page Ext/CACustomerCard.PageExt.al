pageextension 51025 CustomerCardPageExt extends "Customer Card"
{
    layout
    {
        // modify(General)
        // {
        //     Editable = IsEditable;
        // }
        // General Section RH 040926++
        modify("No.")
        {
            Editable = IsEditable;
        }
        modify("Name")
        {
            Editable = IsEditable;
        }
        modify("IC Partner Code")
        {
            Editable = IsEditable;
        }
        modify("Responsibility Center")
        {
            Editable = IsEditable;
        }
        modify("Salesperson Code")
        {
            Editable = IsEditable;
        }
        modify("Disable Search by Name")
        {
            Editable = IsEditable;
        }
        modify("Credit Limit (LCY)")
        {
            Editable = IsEditable;
        }
        modify("Document Sending Profile")
        {
            Editable = IsEditable;
        }
        modify(Blocked)
        {
            Editable = Rec."Approval Status" = Rec."Approval Status"::Approved;
        }
        // General Section RH 040926--
        modify("Address & Contact")
        {
            Editable = IsEditable;
        }
        modify(Invoicing)
        {
            Editable = IsEditable;
        }
        modify(Payments)
        {
            Editable = IsEditable;
        }
        modify(Shipping)
        {
            Editable = IsEditable;
        }
        modify(Statistics)
        {
            Editable = IsEditable;
        }
        addlast(General)
        {
            field("Approval Status"; Rec."Approval Status")
            {
                ApplicationArea = All;
                StyleExpr = StatusStyleTxt;
                ToolTip = 'Specifies the value of the Approval Status field.', Comment = '%';
            }
        }
    }
    actions
    {
        modify(SendApprovalRequest)
        {
            Enabled = Rec."Approval Status" = Rec."Approval Status"::Open;
            trigger OnBeforeAction()
            begin
                Rec."CA Sender ID" := UserId;
                Rec.Modify();
            end;

        }
        modify(CancelApprovalRequest)
        {
            Enabled = Rec."Approval Status" = Rec."Approval Status"::"Pending Approval";
            trigger OnAfterAction()
            begin
                CurrPage.Update(false);
            end;
        }
        addlast("Request Approval")
        {
            action(Reopen)
            {
                Image = ReOpen;
                ApplicationArea = All;
                Caption = 'Reopen';
                Enabled = Rec."Approval Status" = Rec."Approval Status"::Approved;
                trigger OnAction()
                var
                    WorkFlow: Codeunit CAWorkflow;
                begin
                    WorkFlow.PerformManualReopen(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        modify(Approve)
        {
            enabled = Rec."Approval Status" = Rec."Approval Status"::"Pending Approval";
            trigger OnAfterAction()
            begin
                CurrPage.Update(false);
            end;
        }
        addlast(Category_Category6)
        {
            actionref(Reopen_Promoted; Reopen)
            {
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetPageEditability();
    end;

    local procedure SetPageEditability()
    begin
        IsEditable := Rec."Approval Status" = Rec."Approval Status"::Open;
        if Rec."Approval Status" in [Rec."Approval Status"::Approved, Rec."Approval Status"::"Pending Approval"] then begin
            IsEditable := false;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        StatusStyleTxt := Rec.GetStatusStyleText();
        SetPageEditability;
    end;

    var
        StatusStyleTxt: Text;
        isCurrPageEditable: Boolean;
        IsEditable: Boolean;

}