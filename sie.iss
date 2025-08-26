; Instalador SIE Remoto UFSM (mts60)
; 1.3 - Versão ajustada para github. Alterada estrutura de pastas apenas
; 1.2 - Remove instalador após instalação (na primeira execução)
; - Instala arquivos do SIE e configura atalhos
; - Exclui atalhos relacionados ao SIE (apenas .rdp) no desktop de todos os usuários
; - Instala a VPN GlobalProtect automaticamente conforme arquitetura
; - Permite ao usuário remover a VPN na desinstalação
[Setup]
AppName=SIE Remoto UFSM (mts60)
AppId=SIE_Remoto_UFSM
AppVersion=1.3
AppPublisher=NTI UFSM-CS
AppPublisherURL=https://www.ufsm.br/unidades-universitarias/cachoeira-do-sul/nucleo-de-tecnologia-da-informacao
DefaultDirName={autopf}\UFSM\CS\SIE_Remoto_mts60
DefaultGroupName=SIE Remoto UFSM
OutputDir=.
OutputBaseFilename=Instalador-SIE-Remoto
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x86 x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayName=SIE Remoto UFSM (mts60)
UninstallDisplayIcon={app}\sie.ico
SetupIconFile=Imagens\icon-install-nti1.ico
WizardImageFile=Imagens\WizardImageFileNTI.bmp
WizardSmallImageFile=Imagens\WizardSmallImageFileNTI.bmp

[Languages]
Name: "BrazilianPortuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Files]
; Arquivos comuns para ambas as arquiteturas
Source: "SIE\SIE.bat"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "SIE\sie.ico"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "SIE\SIE.rdp"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

; Arquivos para 64-bit (substitua pelo nome real do instalador)
Source: "GP\GlobalProtect64.msi"; DestDir: "{app}"; Check: Is64BitInstallMode;

; Arquivos para 32-bit (substitua pelo nome real do instalador)
Source: "GP\GlobalProtect.msi"; DestDir: "{app}"; Check: not Is64BitInstallMode;

[Icons]
; Atalho no Desktop para o .bat
Name: "{commondesktop}\SIE Remoto"; Filename: "{app}\SIE.bat"; IconFilename: "{app}\sie.ico"

; Atalho principal dentro da pasta "SIE Remoto UFSM"
Name: "{commonprograms}\SIE Remoto UFSM\SIE Remoto"; Filename: "{app}\SIE.bat"; IconFilename: "{app}\sie.ico"

; Atalho para desinstalar, também na mesma pasta
Name: "{commonprograms}\SIE Remoto UFSM\Desinstalar SIE Remoto UFSM"; Filename: "{uninstallexe}"; IconFilename: "{app}\sie.ico"


[Run]
; Instalação silenciosa + configuração do portal (64-bit)
Filename: "msiexec.exe"; Parameters: "/i ""{app}\GlobalProtect64.msi"" /qn /norestart PORTAL=vpn.ufsm.br"; \
    StatusMsg: "AGUARDE! Instalando a VPN da UFSM (GlobalProtect 64-bit)..."; Check: Is64BitInstallMode; Flags: waituntilterminated

; Instalação silenciosa + configuração do portal (32-bit)
Filename: "msiexec.exe"; Parameters: "/i ""{app}\GlobalProtect.msi"" /qn /norestart PORTAL=vpn.ufsm.br"; \
    StatusMsg: "AGUARDE! Instalando a VPN da UFSM (GlobalProtect 32-bit)..."; Check: not Is64BitInstallMode; Flags: waituntilterminated

; Remover GlobalProtect da inicialização
Filename: "cmd.exe"; Parameters: "/C reg delete ""HKLM\Software\Microsoft\Windows\CurrentVersion\Run"" /v GlobalProtect /f"; Flags: runhidden
Filename: "cmd.exe"; Parameters: "/C reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Run"" /v GlobalProtect /f"; Flags: runhidden

;[Registry]
; Remove a inicialização automática do GlobalProtect
;Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueName: "GlobalProtect"; Flags: deletevalue uninsdeletevalue

[Code]
var GlobalProtectUninstallConfirmed: Boolean;
var InstallerPath: string;

procedure InitializeWizard();
begin
  InstallerPath := ExpandConstant('{srcexe}');
end;


procedure DeleteMatchingRDPFilesOnPath(DesktopPath: string);
var
  SearchRec: TFindRec;
  FilePath: string;
begin
  if FindFirst(DesktopPath + '\*sie*.rdp', SearchRec) then
  begin
    try
      repeat
        FilePath := DesktopPath + '\' + SearchRec.Name;
        if not DeleteFile(FilePath) then
          Log('Falha ao excluir: ' + FilePath)
        else
          Log('Excluído: ' + FilePath);
      until not FindNext(SearchRec);
    finally
      FindClose(SearchRec);
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    DeleteMatchingRDPFilesOnPath(ExpandConstant('{userdesktop}'));
    DeleteMatchingRDPFilesOnPath(ExpandConstant('{commondesktop}'));
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\SIE_Remoto_UFSM', 'InstallerPath', InstallerPath);
  end;
end;

procedure AskUninstallGlobalProtect();
var
  UserChoice: Integer;
begin
  UserChoice := MsgBox('Deseja remover também a VPN da UFSM (GlobalProtect)?' + #13#10#13#10 + 'Essa VPN pode ser necessária para outros sistemas institucionais.' + #13#10 + 'Recomenda-se removê-la apenas se você tiver certeza que não irá utilizá-la.', mbConfirmation, MB_YESNO);
  GlobalProtectUninstallConfirmed := (UserChoice = IDYES);
end;

function ShouldUninstallGlobalProtect(): Boolean;
begin
  Result := GlobalProtectUninstallConfirmed;
end;

procedure UninstallGlobalProtect();
var
  ResultCode: Integer;
begin
  if ShouldUninstallGlobalProtect() then
  begin
    if Is64BitInstallMode then
    begin
      if FileExists(ExpandConstant('{app}\GlobalProtect64.msi')) then
      begin
        if ShellExec('', 'msiexec.exe', '/x "' + ExpandConstant('{app}\GlobalProtect64.msi') + '" /qn', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
          Log('GlobalProtect 64-bit desinstalado com sucesso.')
        else
          MsgBox('Erro ao desinstalar GlobalProtect 64-bit. Código: ' + IntToStr(ResultCode), mbError, MB_OK);
      end
      else
        MsgBox('Arquivo GlobalProtect64.msi não encontrado! Desinstale o GlobalProtect64 manualmente.', mbError, MB_OK);
    end
    else
    begin
      if FileExists(ExpandConstant('{app}\GlobalProtect.msi')) then
      begin
        if ShellExec('', 'msiexec.exe', '/x "' + ExpandConstant('{app}\GlobalProtect.msi') + '" /qn', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
          Log('GlobalProtect 32-bit desinstalado com sucesso.')
        else
          MsgBox('Erro ao desinstalar GlobalProtect 32-bit. Código: ' + IntToStr(ResultCode), mbError, MB_OK);
      end
      else
        MsgBox('Arquivo GlobalProtect.msi não encontrado! Desinstale o GlobalProtect manualmente.', mbError, MB_OK);
    end;
  end;
end;

procedure DeleteAppFolderIfEmpty();
begin
  // Tenta remover a pasta do programa (só funciona se estiver vazia)
  if DirExists(ExpandConstant('{app}')) then
    DelTree(ExpandConstant('{app}'), True, True, True);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    RegDeleteKeyIfEmpty(HKEY_LOCAL_MACHINE, 'Software\SIE_Remoto_UFSM');
    AskUninstallGlobalProtect();
    UninstallGlobalProtect();
    DeleteAppFolderIfEmpty();
  end;
end;