# Instalador SIE Remoto UFSM (mts60)

Este repositório contém o instalador do **SIE Remoto UFSM (mts60)**, desenvolvido em **Inno Setup**, para facilitar o acesso externo ao sistema da UFSM.

## 📌 Funcionalidades

- Instala os arquivos do **SIE** e cria atalhos no sistema.
- Remove automaticamente atalhos antigos do SIE (`.rdp`) no desktop de todos os usuários.
- Instala a **VPN GlobalProtect** da UFSM de forma automática, conforme a arquitetura do Windows:
  - `GlobalProtect64.msi` para sistemas 64-bit
  - `GlobalProtect.msi` para sistemas 32-bit
- Remove a configuração de inicialização automática do GlobalProtect.
- Durante a **desinstalação**, permite ao usuário escolher se deseja também remover a VPN.
- Remove os arquivos do instalador após a primeira execução.

## 📂 Estrutura

- `sie.iss` → Script do Inno Setup que gera o instalador.
- `SIE\` → Arquivos necessários para execução do SIE.
- `GP\` → Instaladores do GlobalProtect (32 e 64 bits).

## 🖥️ Requisitos

- Windows 7 ou superior (x86/x64).
- Privilégios de administrador para instalação.
- Conexão de rede para uso via VPN.

## 🚀 Instalação

1. Baixe o instalador gerado:  
   **`Instalador-SIE-Remoto.exe`**
2. Execute o instalador como **Administrador**.
3. Aguarde a instalação do SIE e da VPN GlobalProtect.
4. Um atalho chamado **"SIE Remoto"** será criado no desktop.

## ❌ Desinstalação

1. Vá em **Painel de Controle → Programas e Recursos** e desinstale **SIE Remoto UFSM (mts60)**.  
2. Durante o processo, será perguntado se deseja também remover a VPN **GlobalProtect**.  
   - Escolha **Sim** para remover completamente a VPN.  
   - Escolha **Não** caso utilize a VPN para outros sistemas da UFSM.

## 👨‍💻 Autor

- **NTI UFSM-CS**  
  [🔗 Site oficial](https://www.ufsm.br/unidades-universitarias/cachoeira-do-sul/nucleo-de-tecnologia-da-informacao)

---

📢 Este instalador foi desenvolvido para uso interno da **UFSM**.
