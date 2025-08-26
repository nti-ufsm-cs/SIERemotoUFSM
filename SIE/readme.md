# Acesso Remoto ao SIE

Esta pasta contém os arquivos necessários para acesso remoto ao **SIE** da UFSM:

- `sie.bat` – Script de execução do acesso remoto, responsável por verificar a VPN, servidor e iniciar a conexão RDP.
- `sie.rdp` – Atalho para conexão remota via RDP.
- `sie.ico` – Ícone utilizado pelo atalho/script.

---

## Funcionalidades do `sie.bat`

O script automatiza o processo de acesso remoto, realizando:

1. Verificação do instalador do SIE e remoção de versões antigas.
2. Verificação da instalação do **GlobalProtect (VPN da UFSM)**.
3. Checagem do atalho RDP (`sie.rdp`).
4. Verificação da conexão VPN e instruções para o usuário se necessário.
5. Teste de disponibilidade do servidor remoto.
6. Abertura da sessão remota via RDP.
7. Instruções de desconexão segura da VPN após encerrar a sessão.

---

## Pré-requisitos

- **Windows**.
- **GlobalProtect** instalado (VPN da UFSM).
- Arquivo `sie.rdp` presente na mesma pasta que o script `sie.bat`.

> Caso a VPN ou o atalho RDP estejam ausentes ou desatualizados, o script abrirá automaticamente a página de tutoriais do NTI para reinstalação.

---

## Como usar

1. Coloque todos os arquivos (`sie.bat`, `sie.rdp`, `sie.ico`) na mesma pasta.
2. Execute `sie.bat` clicando duas vezes.
3. Siga as instruções exibidas na tela para conexão VPN e acesso ao SIE.
4. Mantenha a janela do `sie.bat` aberta enquanto utiliza o SIE remoto.
5. Ao finalizar a sessão, siga as instruções do script para desconectar a VPN corretamente.

---

## Versão

- **Versão do script:** 1.1  
- **Data:** 05/08/2025  
- Ajustes no caminho do instalador com espaços.
