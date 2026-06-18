# BindHub

## PT-BR

O BindHub e um plugin de automacao para o Noctalia focado em hotkeys, macros e sincronizacao de hotkeys com o Niri.

### Estado Atual

Esta pasta contem um plugin instalavel com configuracao local, execucao de macros e sincronizacao de hotkeys com o Niri.

Incluido hoje:

- manifesto do plugin
- entry point de widget da barra
- entry point de painel
- entry point de configuracoes
- preview placeholder
- persistencia local de hotkeys e macros
- backend de execucao de macros e hotkeys
- sincronizacao de hotkeys globais para o Niri

Ainda nao implementado:

- suporte a outros compositores alem do Niri
- runner de acoes do Niri
- importacao e exportacao

### Escopo Planejado

A direcao de produto esta documentada em [docs/PLANNING.md](./docs/PLANNING.md).

O escopo atual prioriza:

- hotkeys
- macros
- integracao com Niri

### Desenvolvimento

Comando IPC util:

```bash
qs -c noctalia-shell ipc call plugin:bindhub toggle
```

### Arquitetura

A organizacao atual do plugin esta documentada em [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md).

## EN

BindHub is a Noctalia automation plugin focused on hotkeys, macros, and Niri hotkey synchronization.

### Current Status

This directory contains an installable plugin with local configuration, macro execution, and Niri hotkey synchronization.

Included today:

- plugin manifest
- bar widget entry point
- panel entry point
- settings entry point
- placeholder preview
- local persistence for hotkeys and macros
- backend execution for macros and hotkeys
- global hotkey sync for Niri

Not implemented yet:

- support for compositors other than Niri
- Niri action runner
- import/export

### Planned Scope

The product direction is documented in [docs/PLANNING.md](./docs/PLANNING.md).

The current scope prioritizes:

- hotkeys
- macros
- Niri integration

### Development

Useful IPC command:

```bash
qs -c noctalia-shell ipc call plugin:bindhub toggle
```

### Architecture

The current plugin structure is documented in [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md).
