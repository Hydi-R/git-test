/// <summary>
///  Deloitte AK 10082026
///     <COD> Code changes on Triggers </COD>
///         - Dimension Code - OnAfterValidate
///         - Dimension Value Code - OnLookup
/// </summary>
pageextension 51005 "Default Dimensions Ext" extends "Default Dimensions"
{
    layout
    {
        modify("Dimension Code")
        {
            trigger OnAfterValidate()
            var
                DefaultDimension: Record "Default Dimension";
            begin
                if not GLSetup.Get() then
                    exit;

                // Allow global dimension 1/project to be created anytime.
                if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                    exit;

                // Check if global dimension 1/project already exists for this record.
                DefaultDimension.Reset();
                DefaultDimension.SetRange("Table ID", Rec."Table ID");
                DefaultDimension.SetRange("No.", Rec."No.");
                DefaultDimension.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");

                if not DefaultDimension.FindFirst() then
                    Error(
                        'Please create the %1 dimension first before adding %2.',
                        GLSetup."Global Dimension 1 Code",
                        Rec."Dimension Code");
            end;
        }
        modify("Dimension Value Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                DimValue: Record "Dimension Value";
                DefaultDimension: Record "Default Dimension";
                ProjectCode: Code[20];
            begin
                if not GLSetup.Get() then
                    exit(false);

                // Allow standard lookup except for global dimension 2/class.
                if Rec."Dimension Code" <> GLSetup."Global Dimension 2 Code" then begin
                    DimValue.Reset();
                    DimValue.SetRange("Dimension Code", Rec."Dimension Code");
                    if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                        Rec.Validate("Dimension Value Code", DimValue.Code);
                        // CurrPage.Update(False);
                        Text := DimValue.Code;
                        exit(true);
                    end;
                end else begin
                    DefaultDimension.Reset();
                    DefaultDimension.SetRange("Table ID", Rec."Table ID");
                    DefaultDimension.SetRange("No.", Rec."No.");
                    DefaultDimension.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");

                    if DefaultDimension.FindFirst() then
                        ProjectCode := DefaultDimension."Dimension Value Code";

                    DimValue.Reset();
                    DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                    DimValue.SetRange("Project Dimension", ProjectCode);
                    if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                        Rec.Validate("Dimension Value Code", DimValue.Code);
                        // CurrPage.Update(False);
                        Text := DimValue.Code;
                        exit(true);
                    end;
                end;
            end;
        }
    }
    //RH 040926++
    trigger OnOpenPage()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
    begin
        if Rec."Table ID" in [Database::Customer, Database::Vendor]
        then begin
            case Rec."Table ID" of
                Database::Customer:
                    begin
                        if Customer.Get(Rec."No.") then
                            if Customer."Approval Status" <> Customer."Approval Status"::Open then
                                CurrPage.Editable := false;
                    end;
                Database::Vendor:
                    begin
                        if Vendor.Get(Rec."No.") then
                            if Vendor."Approval Status" <> Vendor."Approval Status"::Open then
                                CurrPage.Editable := false;
                    end;

            end;
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";
}

