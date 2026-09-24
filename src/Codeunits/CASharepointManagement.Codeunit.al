///<summary>
///  Deloitte HR 06092026
///    <NEW> New object created </NEW>
///</summary>
namespace System.ExternalFileStorage;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Security.User;
using System.IO;

codeunit 51003 CASharepointManagement
{
    procedure ProcessSharePointFiles()
    var
        ExternalFileStorage: Codeunit "External File Storage";
        FilePaginationData: Codeunit "File Pagination Data";
        TempFileAccountContent: Record "File Account Content" temporary;
        PaymentFileImport: Record CASharePointLogs;
        CASetup: Record CAIntegrationSetup;
        Usersetup: Record "User Setup";
        HasFiles: Boolean;
    begin
        CASetup.Get();
        // CASetup.TestField("SharePoint Source Folder URL");
        Usersetup.get(UserId);
        ExternalFileStorage.Initialize(Enum::"File Scenario"::Default);

        ExternalFileStorage.ListFiles(
            Usersetup."Share Point Folder Path",
            FilePaginationData,
            TempFileAccountContent);

        if not TempFileAccountContent.FindSet() then begin
            Message('No payment file was found in the SharePoint upload folder.');
            exit;
        end;

        repeat
            if TempFileAccountContent.Type = TempFileAccountContent.Type::File then begin
                HasFiles := true;
                ProcessFile(ExternalFileStorage, Usersetup."Share Point Folder Path", TempFileAccountContent.Name, PaymentFileImport);
            end;
        until TempFileAccountContent.Next() = 0;

        if not HasFiles then
            Message('No payment file was found in the SharePoint upload folder.');
    end;

    local procedure ProcessFile(var ExternalFileStorage: Codeunit "External File Storage"; SourceFolder: Text; FileName: Text; var PaymentFileImport: Record CASharePointLogs)
    var
        FilePath: Text;
        InS: InStream;
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        CSVBuffer: Record "CSV Buffer" temporary;
    begin
        FilePath := ExternalFileStorage.CombinePath(SourceFolder, FileName);

        ExternalFileStorage.GetFile(FilePath, InS);

        TempBlob.CreateOutStream(OutS);
        CopyStream(OutS, InS);

        PaymentFileImport.Init();
        PaymentFileImport."File Name" := FileName;
        PaymentFileImport."Import Date" := CurrentDateTime();

        TempBlob.CreateInStream(InS);
        PaymentFileImport."File Content".CreateOutStream(OutS);
        CopyStream(OutS, InS);

        TempBlob.CreateInStream(InS);
        CSVBuffer.LoadDataFromStream(InS, ',');

        PaymentFileImport."Line Count" := CSVBuffer.GetNumberOfLines();
        PaymentFileImport."File Size" := TempBlob.Length() / 1024;
        PaymentFileImport.Status := PaymentFileImport.Status::Pending;
        PaymentFileImport.Insert(true);

        if not FetchAndStorePaymentInfoToGeneralLine(PaymentFileImport, CSVBuffer) then begin
            UpdateImportStatus(PaymentFileImport, PaymentFileImport.Status::Error);
            MoveErrorFile(ExternalFileStorage, SourceFolder, FileName);
            if PaymentFileImport."Error List" = '' then
                PaymentFileImport."Error List" := PaymentFileImport."Error Message";
            Message('File "%1" was moved to the error folder.\%2', FileName, PaymentFileImport."Error List");
            exit;
        end;

        UpdateImportStatus(PaymentFileImport, PaymentFileImport.Status::Imported);
        MoveProcessedFile(ExternalFileStorage, SourceFolder, FileName);
    end;

    local procedure FetchAndStorePaymentInfoToGeneralLine(var PaymentFileImport: Record CASharePointLogs; var CSVBuffer: Record "CSV Buffer" temporary): Boolean
    var
        ColNo: Integer;
        ProjectCol: Integer;
        Header: Text;
        CASetup: record CAIntegrationSetup;
        CAImportDefinitionManagement: Codeunit CAImportDefinitionManagement;
        AllRowsValid: Boolean;
        ErrorText: Text;
    begin
        CASetup.Get();
        if CASetup."Payment Template" = '' then begin
            PaymentFileImport."Error List" := 'Payment Template is not configured in Integration Setup.';
            PaymentFileImport."Error Message" := PaymentFileImport."Error List";
            PaymentFileImport.Modify();
            exit(false);
        end;
        if CASetup."Payment Batch" = '' then begin
            PaymentFileImport."Error List" := 'Payment Batch is not configured in Integration Setup.';
            PaymentFileImport."Error Message" := PaymentFileImport."Error List";
            PaymentFileImport.Modify();
            exit(false);
        end;
        for ColNo := 1 to CSVBuffer.GetNumberOfColumns() do begin
            Header := CAImportDefinitionManagement.GetValueAtCell(1, ColNo, CSVBuffer);
            case Header of
                'Project Name':
                    ProjectCol := ColNo;
            end;
        end;
        if ProjectCol = 0 then begin
            PaymentFileImport."Error List" := StrSubstNo('Project column not found in file "%1".', PaymentFileImport."File Name");
            PaymentFileImport."Error Message" := PaymentFileImport."Error List";
            PaymentFileImport.Modify();
            exit(false);
        end;
        PaymentFileImport."Project Code" := CAImportDefinitionManagement.GetValueAtCell(2, ProjectCol, CSVBuffer);
        PaymentFileImport."Journal Batch" := CASetup."Payment Batch";
        PaymentFileImport.Modify();
        AllRowsValid := CAImportDefinitionManagement.CreateImportLogs(
            PaymentFileImport."Entry No.", PaymentFileImport."File Name", PaymentFileImport."Project Code", PaymentFileImport."Journal Batch", CSVBuffer);
        if not AllRowsValid then
            exit(false);

        if not TryImportCSVToGeneralJournal(
            CAImportDefinitionManagement,
            PaymentFileImport."Project Code", CSVBuffer, CASetup."Payment Template", PaymentFileImport."Journal Batch", PaymentFileImport."File Name") then begin
            ErrorText := GetLastErrorText();
            PaymentFileImport."Error List" := CopyStr(ErrorText, 1, MaxStrLen(PaymentFileImport."Error List"));
            PaymentFileImport."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(PaymentFileImport."Error Message"));
            PaymentFileImport.Modify();
            UpdateImportLineErrors(PaymentFileImport."Entry No.", ErrorText);
            exit(false);
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure TryImportCSVToGeneralJournal(
        var CAImportDefinitionManagement: Codeunit CAImportDefinitionManagement;
        ProjectCode: Code[20];
        var CSVBuffer: Record "CSV Buffer" temporary;
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
        FileName: Text[250])
    begin
        CAImportDefinitionManagement.ImportCSVToGeneralJournal(
            ProjectCode, CSVBuffer, JournalTemplateName, JournalBatchName, FileName);
    end;

    local procedure UpdateImportLineErrors(EntryNo: Integer; ErrorText: Text)
    var
        PaymentFileImportLine: Record CASharePointLogsLine;
    begin
        PaymentFileImportLine.SetRange("Entry No.", EntryNo);
        if PaymentFileImportLine.FindSet(true) then
            repeat
                PaymentFileImportLine.Status := PaymentFileImportLine.Status::Error;
                PaymentFileImportLine."Error List" := CopyStr(
                    StrSubstNo('General Journal import failed: %1', ErrorText),
                    1,
                    MaxStrLen(PaymentFileImportLine."Error List"));
                PaymentFileImportLine.Modify();
            until PaymentFileImportLine.Next() = 0;
    end;

    local procedure UpdateImportStatus(var PaymentFileImport: Record CASharePointLogs; NewStatus: Option Pending,Imported,Processed,Error)
    begin
        PaymentFileImport.Status := NewStatus;
        PaymentFileImport."Processed Date" := CurrentDateTime();
        PaymentFileImport.Modify();
    end;

    local procedure MoveProcessedFile(var ExternalFileStorage: Codeunit "External File Storage"; SourceFolder: Text; FileName: Text)
    var
        TargetFolderPath: Text;
        SourcePath: Text;
        TargetPath: Text;
        CAIntSetup: Record CAIntegrationSetup;
    begin
        CAIntSetup.Get();
        CAIntSetup.TestField("SharePoint Archive Folder");
        SourcePath := ExternalFileStorage.CombinePath(SourceFolder, FileName);
        TargetFolderPath := CAIntSetup."SharePoint Archive Folder";
        if not ExternalFileStorage.DirectoryExists(TargetFolderPath) then
            ExternalFileStorage.CreateDirectory(TargetFolderPath);
        TargetPath := ExternalFileStorage.CombinePath(TargetFolderPath, FileName);
        ExternalFileStorage.MoveFile(SourcePath, TargetPath);
    end;

    local procedure MoveErrorFile(var ExternalFileStorage: Codeunit "External File Storage"; SourceFolder: Text; FileName: Text)
    var
        TargetFolderPath: Text;
        SourcePath: Text;
        TargetPath: Text;
        CAIntSetup: Record CAIntegrationSetup;
    begin
        CAIntSetup.Get();
        CAIntSetup.TestField("SharePoint Error Folder");
        SourcePath := ExternalFileStorage.CombinePath(SourceFolder, FileName);
        TargetFolderPath := CAIntSetup."SharePoint Error Folder";
        if not ExternalFileStorage.DirectoryExists(TargetFolderPath) then
            ExternalFileStorage.CreateDirectory(TargetFolderPath);
        TargetPath := ExternalFileStorage.CombinePath(TargetFolderPath, FileName);
        ExternalFileStorage.MoveFile(SourcePath, TargetPath);
    end;

    //RH 070926++
    procedure ImportManualFile(var TempBlob: Codeunit "Temp Blob"; FileName: Text)
    var
        ExternalFileStorage: Codeunit "External File Storage";
        InStream: InStream;
        FilePath: Text;
        CASetup: Record CAIntegrationSetup;
    begin
        CASetup.Get();
        CASetup.TestField("SharePoint Payment File Upload");
        TempBlob.CreateInStream(InStream);
        ExternalFileStorage.Initialize(Enum::"File Scenario"::Default);
        FilePath := ExternalFileStorage.CombinePath(CASetup."SharePoint Payment File Upload", FileName);
        ExternalFileStorage.CreateFile(FilePath, InStream);
        Message('File "%1" uploaded successfully.', FileName);
    end;
    //RH 050926--
}