@echo off
CHCP 1252
title Acesso Remoto ao SIE - N�o fechar essa janela!
cls
rem vers�o1.1 (05/08/2025) Ajustes no caminho do instalador com espa�o
rem =========================================================================================================
rem ================================ DEFINI��O DE VARI�VEIS E PAR�METROS ====================================
rem =========================================================================================================
set "versao=1.1"
if exist "%ProgramFiles%\Palo Alto Networks\GlobalProtect\PanGPA.exe" (
    set vpnApp="%ProgramFiles%\Palo Alto Networks\GlobalProtect\PanGPA.exe"
	set "vpnDir=%ProgramFiles%\Palo Alto Networks\GlobalProtect"
) else if exist "%ProgramFiles(x86)%\Palo Alto Networks\GlobalProtect\PanGPA.exe" (
    set vpnApp="%ProgramFiles(x86)%\Palo Alto Networks\GlobalProtect\PanGPA.exe"
	set "vpnDir=%ProgramFiles(x86)%\Palo Alto Networks\GlobalProtect"
)
set rdpShortcut="%~dp0SIE.rdp"
set server=mts60.si.ufsm.br
set "VPN=FALSE" rem Quando conectada muda para "TRUE"
set "GP_USER=" rem inicia a vari�vel
rem =========================================================================================================
rem ================================================ SCRIPT =================================================
rem =========================================================================================================
call :VerificaInstalador
Rem Verifica se o instalador est� presente e remove

call :VerificaVpnApp
Rem Verifica se o GlobalProtect est� instalado

call :VerificaAtalhoRdp
rem Verifica se o atalho para RDP est� dispon�vel

echo *** AGUARDE! Verificando status da VPN ***

call :VerificaVPN
rem Verifica se o GlobalProtect est� conectado. Retorna: VPN==(TRUE / FALSE)

call :ConecteSe
Rem Quando a VPN estiver desconectada: Limpa a tela, abre a janela da VPN e mostra instru��es de conex�o para usu�rio 

call :VerificaServidor
rem verifica se o servidor est� dispon�vel antes de conectar

call :SieRemoto
rem Limpa a tela, abre o atalho da conex�o RDP, mostra instru��es e aguarda o usu�rio fechar

call :DesconecteSe
Rem Quando a VPN est� conectada: Limpa a tela, abre a janela da VPN e mostra instru��es de desconex�o para usu�rio

exit
rem =========================================================================================================
rem ========================================= DEFINI��O DE FUN��ES ==========================================
rem =========================================================================================================
:VerificaInstalador
rem Verifica se o instalador est� presente e remove
setlocal enabledelayedexpansion
for /f "tokens=3,*" %%A in ('reg query "HKLM\Software\SIE_Remoto_UFSM" /v InstallerPath 2^>nul') do (
    set "inst=%%A %%B"
)
if defined inst (
    if exist "!inst!" (
        del /f "!inst!"
    )
)
endlocal
goto :eof

:VerificaVpnApp
Rem verifica se o GlobalProtect est� instalado
if not exist %vpnApp% (
    cls
	echo %vpnApp%
    powershell -Command "Write-Host 'VPN da UFSM (GlobalProtect) ausente ou desatualizada!' -BackgroundColor Red -ForegroundColor White"
    powershell -Command "Write-Host ' ******** REINSTALE o acesso remoto ao SIE ********* ' -BackgroundColor Red -ForegroundColor White"
    start https://www.ufsm.br/unidades-universitarias/cachoeira-do-sul/nucleo-de-tecnologia-da-informacao/tutoriais-nti
    echo.
    echo ! Tutorial do NTI aberto�no�navegador.
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit
)
goto :eof

:VerificaAtalhoRdp
rem Verifica se o atalho para RDP est� dispon�vel. Se o atalho n�o estiver dispon�vel � necess�rio reinstalar
if not exist %rdpShortcut% (
    cls
    powershell -Command "Write-Host 'SIE Remoto ausente ou desatualizado!' -BackgroundColor Red -ForegroundColor White"
    powershell -Command "Write-Host '* REINSTALE o acesso remoto ao SIE *' -BackgroundColor Red -ForegroundColor White"
    start https://www.ufsm.br/unidades-universitarias/cachoeira-do-sul/nucleo-de-tecnologia-da-informacao/tutoriais-nti
    echo.
    echo P�gina do NTI aberta para execu��o do tutorial de instala��o do SIE Remoto.
    echo.
    echo ! Tutorial do NTI aberto�no�navegador.
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit
)
goto :eof

:VerificaVPN
rem Verifica se o GlobalProtect est� conectado. Retorna: VPN==(TRUE / FALSE)
powershell -NoProfile -Command "if ((Get-Content '%vpnDir%\PanGPS.log' -Tail 50) -match 'Found virtual interface IP route entry') { exit 0 } else { exit 1 }"
IF %ERRORLEVEL% EQU 0 (
    set "VPN=TRUE"
) else (
    set "VPN=FALSE"
)
goto :eof

:ConecteSe
Rem Quando a VPN estiver desconectada limpa a tela, abre a janela da VPN e mostra instru��es de conex�o para usu�rio 
if %VPN%==TRUE goto :eof
cls
echo Conecte-se � VPN da UFSM:
echo.

rem Garante que o servi�o PanGPS est� rodando
sc query PanGPS | find "RUNNING" >nul
if errorlevel 1 (
	net start PanGPS >nul 2>&1
)

rem Tenta ler username
for /f "tokens=3" %%A in ('reg query "HKCU\Software\Palo Alto Networks\GlobalProtect\Settings" /v username 2^>nul ^| find "username"') do (
	set "GP_USER=%%A"
)

rem Agora testa se est� realmente preenchida
if "%GP_USER%" NEQ "" (
	rem Caso o usu�rio j� tenha feito login antes
	powershell -Command "Write-Host '*** CLIQUE em ""Connect""" na janela """"GlobalProtect"""" no canto inferior direito da sua tela! ***' -BackgroundColor Blue -ForegroundColor White"
) else (
	rem Primeira vez - deve digitar usuario e senha
	powershell -Command "Write-Host '*** CLIQUE em ""Connect / Sign In""" na janela """"GlobalProtect"""" no canto inferior direito da sua tela! ***' -BackgroundColor Blue -ForegroundColor White"
	echo.
	echo Usuario: CPF
	echo Senha: Mesma dos portais
)
echo.
start "" %vpnApp% --showui
echo Aguardando conex�o...
call :loopConecta
rem Enquanto a VPN estiver desconectada n�o sai do loop
goto :eof

:loopConecta
rem enquanto a VPN estiver desconectada n�o sai do loop
call :VerificaVPN
if %VPN%==FALSE (
	timeout /t 1 /nobreak >nul
	goto loopConecta
)
goto :eof

:VerificaServidor
rem verifica se o servidor est� dispon�vel antes de conectar
ping -n 1 %server% >nul
if errorlevel 1 (
	cls
	echo ! Servidor remoto indispon�vel no momento. Tente novamente mais tarde!
	echo.
	echo Se o problema persistir, por favor, abra um ticket�de�suporte.
	echo.
	echo Pressione qualquer tecla para sair...
	pause >nul
	exit
) else (
	rem Conex�o estabelecida!
	goto :eof
)

:SieRemoto
rem Limpa a tela, abre o atalho da conex�o RDP, mostra instru��es e aguarda o usu�rio fechar
cls
echo VPN conectada com sucesso!
echo.
echo Mantenha esta janela aberta enquanto utiliza�o�SIE�remoto.
echo.
call :logoNti
%rdpShortcut%
goto :eof

:DesconecteSe
Rem Quando a VPN estiver conectada: Limpa a tela, abre a janela da VPN e mostra instru��es de desconex�o para usu�rio
if %VPN%==TRUE (
	cls
	echo Voc� fechou a conex�o remota com o SIE.
	echo.
	echo Agora desconecte a VPN:
	echo.
	powershell -Command "Write-Host '*** CLIQUE em ""Disconnect""" na janela """"GlobalProtect"""" no canto inferior direito da sua tela! ***' -BackgroundColor Red -ForegroundColor White"
	echo.
	start "" %vpnApp%
	echo Aguardando desconex�o...
	call :loopDesconecta rem enquanto a VPN estiver conectada n�o sai do loop
)
goto :eof

:loopDesconecta
call :VerificaVPN
rem enquanto a VPN estiver conectada n�o sai do loop
if %VPN%==TRUE (
	timeout /t 1 /nobreak >nul
	goto loopDesconecta
)
goto :eof

:logoNti
rem Logo do NTI CS em ASCII
echo NNNNNNNN        NNNNNNNN TTTTTTTTTTTTTTTTTTTTTTT IIIIIIIIII
echo N:::::::N       N::::::N T:::::::::::::::::::::T I::::::::I
echo N::::::::N      N::::::N T:::::::::::::::::::::T I::::::::I
echo N:::::::::N     N::::::N T:::::TT:::::::TT:::::T II::::::II
echo N::::::::::N    N::::::N TTTTTT  T:::::T  TTTTTT   I::::I  
echo N:::::::::::N   N::::::N         T:::::T           I::::I  
echo N:::::::N::::N  N::::::N         T:::::T           I::::I  
echo N::::::N N::::N N::::::N         T:::::T           I::::I  
echo N::::::N  N::::N:::::::N         T:::::T           I::::I  
echo N::::::N   N:::::::::::N         T:::::T           I::::I  
echo N::::::N    N::::::::::N         T:::::T           I::::I  
echo N::::::N     N:::::::::N         T:::::T           I::::I  
echo N::::::N      N::::::::N       TT:::::::TT       II::::::II
echo N::::::N       N:::::::N       T:::::::::T       I::::::::I
echo N::::::N        N::::::N       T:::::::::T       I::::::::I
echo NNNNNNNN         NNNNNNN       TTTTTTTTTTT       IIIIIIIIII
echo. 
echo ��    �� ������� ������� ���    ���        �������  �������
echo ��    �� ��      ��      ����  ����        ��       ��     
echo ��    �� �����   ������� �� ���� ��  ����  ��       �������
echo ��    �� ��           �� ��  ��  ��        ��            ��
echo  ������  ��      ������� ��      ��        �������  �������
goto :eof