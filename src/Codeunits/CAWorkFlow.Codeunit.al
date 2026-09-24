/// <summary>
/// Deloitte AK 02092026
///     <NEW> New Object Created </NEW>
/// </summary>
codeunit 51004 CAWorkflow
{
    Permissions = tabledata 454 = rimd;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertVendor(var Rec: Record Vendor; RunTrigger: Boolean)
    begin
        If RunTrigger then
            Rec.Blocked := Rec.Blocked::All;
    end;
    //RH 040926++
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        If RunTrigger then
            Rec.Blocked := Rec.Blocked::All;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSendVendorForApproval, '', false, false)]
    local procedure OnSendVendorForApproval(var Vendor: Record Vendor)
    begin
        if Vendor."Approval Status" = Vendor."Approval Status"::Open then begin
            Vendor."Approval Status" := Vendor."Approval Status"::"Pending Approval";
            // Vendor.Modify();
        end;
    end;

    //RH 040926++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnCancelVendorApprovalRequest, '', false, false)]
    local procedure OnCancelVendorApprovalRequest(var Vendor: Record Vendor)
    begin
        if (Vendor."Approval Status" = Vendor."Approval Status"::Approved) then
            exit;
        Vendor."Approval Status" := Vendor."Approval Status"::Open;
        Vendor.Blocked := Vendor.Blocked::All;
        Vendor.Modify();
    end;
    //RH 040926++    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnCancelCustomerApprovalRequest, '', false, false)]
    local procedure OnCancelCustomerApprovalRequest(var Customer: Record Customer)
    begin
        if (Customer."Approval Status" = Customer."Approval Status"::Approved) then
            exit;
        Customer."Approval Status" := Customer."Approval Status"::Open;
        Customer.Blocked := Customer.Blocked::All;
        Customer.Modify();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnBeforeApproveSelectedApprovalRequest, '', false, false)]
    local procedure OnBeforeApproveSelectedApprovalRequest(var ApprovalEntry: Record "Approval Entry"; var IsHandled: Boolean)
    var
        RecApprovalEntry: Record "Approval Entry";
        SameSequenceNoAlreadyApprovedError: Label 'Another user on the same level has already Approved this request. Your request will be auto-approved once final request in the Workflow is Approved.';
        SameUserApprovalError: Label 'The person who prepared the Customer cannot approve the same request. Please have another authorized approver approve the request.';

    begin
        RecApprovalEntry.Reset();
        RecApprovalEntry.SetRange("Document Type", ApprovalEntry."Document Type");
        RecApprovalEntry.SetRange("Document No.", ApprovalEntry."Document No.");
        RecApprovalEntry.SetFilter("Sequence No.", '>%1', ApprovalEntry."Sequence No.");
        RecApprovalEntry.SetFilter(Status, '<>%1', RecApprovalEntry.Status::Created);
        RecApprovalEntry.SetRange("Workflow Step Instance ID", ApprovalEntry."Workflow Step Instance ID");
        if not RecApprovalEntry.IsEmpty then
            Error(SameSequenceNoAlreadyApprovedError);

        // Case ApprovalEntry."Table ID" of
        //     database::Customer:
        //         begin
        //             RecCustomer.Get(ApprovalEntry."Record ID to Approve");
        //             if ApprovalEntry."Sender ID" = ApprovalEntry."Approver ID" then Error(SameUserApprovalError);

        //         end;
        // end;
    end;
    //RH 040926++
    procedure PerformManualReopen(var Customer: Record Customer)
    begin
        CheckReopenStatus(Customer);
        Reopen(Customer);
    end;
    //RH 040926++
    local procedure CheckReopenStatus(Customer: Record Customer)
    var
        Text003: Label 'The approval process must be cancelled or completed to reopen this document.';
    begin
        if Customer."Approval Status" = Customer."Approval Status"::"Pending Approval" then
            Error(Text003);
    end;
    //RH 040926++
    procedure Reopen(var Customer: Record Customer)
    var
    begin
        if Customer."Approval Status" = Customer."Approval Status"::Open then
            exit;
        Customer."Approval Status" := Customer."Approval Status"::Open;
        Customer.Modify(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnApproveApprovalRequest, '', false, false)]
    local procedure OnApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        RecCustomer: Record Customer;
        RecVendor: Record Vendor;
        SequenceNo: Integer;
    begin
        if (CheckIfApprovedApprovalEntrywithSeqIDExist(ApprovalEntry."Record ID to Approve", ApprovalEntry."Sequence No.")) and
            not (CheckIfApprovalEntryExistForNextSeqNo(ApprovalEntry."Record ID to Approve", ApprovalEntry."Sequence No." + 1)) then begin
            if RecVendor.Get(ApprovalEntry."Record ID to Approve") then begin
                RecVendor."Approval Status" := RecVendor."Approval Status"::Approved;
                RecVendor.Blocked := RecVendor.Blocked::" ";
                RecVendor.Modify();
            end;
        end;
        //RH 040926++
        case ApprovalEntry."Table ID" of
            database::Customer:
                begin
                    if RecCustomer.Get(ApprovalEntry."Record ID to Approve") then begin
                        RecCustomer."Approval Status" := Enum::CAMasterApprovalStatus::Approved;
                        RecCustomer.Blocked := RecCustomer.Blocked::" ";
                        RecCustomer.Modify();
                    end;
                end;
        end;
    end;
    //RH 040926++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        RecCustomer: Record Customer;
    begin
        case RecRef.Number of
            Database::Customer:
                begin
                    RecRef.SetTable(RecCustomer);
                    RecCustomer.Validate("Approval Status", RecCustomer."Approval Status"::Open);
                    RecCustomer.Blocked := RecCustomer.Blocked::All;
                    RecCustomer.Modify(true);
                    Handled := true;
                end;
        end;
    end;
    //RH 040926++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        RecCustomer: Record Customer;
    begin
        case RecRef.Number of
            Database::Customer:
                begin
                    RecRef.SetTable(RecCustomer);
                    RecCustomer.Validate("Approval Status", RecCustomer."Approval Status"::"Pending Approval");
                    RecCustomer.Blocked := RecCustomer.Blocked::All;
                    RecCustomer.Modify(true);
                    IsHandled := true;
                end;
        end;
    end;
    //RH 040926++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RecCustomer: Record Customer;
    begin
        case RecRef.Number of
            Database::Customer:
                begin
                    RecRef.SetTable(RecCustomer);
                    ApprovalEntryArgument."Document No." := RecCustomer."No.";
                end;
        end;
    end;

    local procedure CheckIfApprovedApprovalEntrywithSeqIDExist(RecordID: RecordId; SeqID: Integer): Boolean
    var
        RecApprovalEntry: Record "Approval Entry";
    begin
        RecApprovalEntry.Reset();
        RecApprovalEntry.SetRange("Record ID to Approve", RecordID);
        RecApprovalEntry.SetRange("Sequence No.", SeqID);
        RecApprovalEntry.SetFilter(Status, '%1', RecApprovalEntry.Status::Approved);
        if RecApprovalEntry.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    local procedure CheckIfApprovalEntryExistForNextSeqNo(RecordID: RecordId; SeqID: Integer): Boolean
    var
        RecApprovalEntry: Record "Approval Entry";
    begin
        RecApprovalEntry.Reset();
        RecApprovalEntry.SetRange("Record ID to Approve", RecordID);
        RecApprovalEntry.SetRange("Sequence No.", SeqID);
        RecApprovalEntry.SetFilter(Status, '%1', RecApprovalEntry.Status::Open);
        if RecApprovalEntry.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnRejectApprovalRequest, '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        RecRef: RecordRef;
        RecVendor: Record Vendor;
        RecCustomer: Record Customer;
        FieldValue: Code[20];
    begin
        if not RecRef.Get(ApprovalEntry."Record ID to Approve") then
            exit;
        RecRef.SetRecFilter();
        RecRef := ApprovalEntry."Record ID to Approve".GetRecord();
        FieldValue := Format(RecRef.Field(1).Value);

        if RecVendor.Get(FieldValue) then begin
            RecVendor."Approval Status" := RecVendor."Approval Status"::Open;
            RecVendor.Blocked := RecVendor.Blocked::All;
            RecVendor.Modify();
        end;
        //RH 040926++
        Case ApprovalEntry."Table ID" of
            database::Customer:
                begin
                    RecCustomer.Get(ApprovalEntry."Record ID to Approve");
                    RecCustomer."Approval Status" := Enum::CAMasterApprovalStatus::Open;
                    RecCustomer.Blocked := RecCustomer.Blocked::All;
                    RecCustomer.Modify();
                end;
        end;
    end;



    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifyVendorBankAccount(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        RecVendor: Record Vendor;
    begin
        if GuiAllowed and RunTrigger and (RecVendor.Get(Rec."Vendor No.")) and (RecVendor."Approval Status" <> RecVendor."Approval Status"::Open) then
            Error('Vendor Bank Account %1 can only be modified when the approval status of the Vendor %2 is Open', Rec.Code, Rec."Vendor No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertVendorBankAccount(var Rec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        RecVendor: Record Vendor;
    begin
        if RunTrigger and (RecVendor.Get(Rec."Vendor No.")) then begin
            RecVendor."Approval Status" := RecVendor."Approval Status"::Open;
            RecVendor.Blocked := RecVendor.Blocked::All;
            RecVendor.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsertVendorBankAccount(var Rec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        RecVendor: Record Vendor;
    begin
        if GuiAllowed and RunTrigger and (RecVendor.Get(Rec."Vendor No.")) and (RecVendor."Approval Status" <> RecVendor."Approval Status"::Open) then
            Error('Cannot create Vendor Bank Account. Vendor %1 is currently %2; status must be Open.', RecVendor."No.", RecVendor."Approval Status");
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteVendor(var Rec: Record Vendor; RunTrigger: Boolean)
    begin
        if GuiAllowed and RunTrigger and (Rec."Approval Status" <> Rec."Approval Status"::Open) then
            Error('Vendor %1 can only be deleted when the approval status is Open', Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteVendorBankAccount(var Rec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        RecVendor: Record Vendor;
    begin
        if GuiAllowed and RunTrigger and (RecVendor.Get(Rec."Vendor No.")) and (RecVendor."Approval Status" <> RecVendor."Approval Status"::Open) then
            Error('Vendor Bank Account %1 can only be deleted when the approval status of the Vendor %2 is Open', Rec.Code, Rec."Vendor No.");
    end;
}
