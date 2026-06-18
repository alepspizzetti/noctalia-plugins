# Arquitetura do BindHub

## Organizacao atual

O `bindhub` esta organizado em camadas claras dentro da mesma pasta do plugin:

- `manifest.json`
  Contrato do plugin com o Noctalia.
- `Main.qml`
  Entrypoint principal e ponte entre o plugin e o backend.
- `ui/`
  Camada de interface.
- `backend/`
  Camada de execucao real.
- `docs/`
  Documentacao interna do plugin.
- `i18n/`
  Traducoes.
- `settings.json`
  Persistencia oficial das configuracoes do plugin. Este arquivo e usado pelo proprio `PluginService` do Noctalia.

## Separacao de responsabilidades

### UI

Arquivos:

- `ui/Settings.qml`
- `ui/Panel.qml`
- `ui/BarWidget.qml`

Responsabilidades:

- permitir CRUD de hotkeys e macros
- exibir estado atual
- salvar configuracao

A UI nao deve virar o motor de automacao.

### Ponte do plugin

Arquivo:

- `Main.qml`

Responsabilidades:

- expor IPC do plugin
- chamar o backend local
- servir como ponto unico de integracao entre Noctalia e executor

### Backend

Pasta:

- `backend/`

Responsabilidades:

- ler `settings.json`
- executar hotkeys e macros
- implementar tipos de acao
- encapsular chamadas externas como `wtype`, `xdg-open`, `notify-send` e futuros comandos do `niri msg`

Organizacao interna:

- `backend/common/`
  Leitura de configuracao e utilitarios compartilhados.
- `backend/actions/`
  Tipos de acao executaveis.
- `backend/macros/`
  Resolver e executar macros.
- `backend/hotkeys/`
  Resolver hotkeys e sincronizar o arquivo de binds do Niri.
- `backend/execute.py`
  Entry point fino que roteia para os modulos acima.

## Estado funcional

Ja implementado:

- persistencia local de hotkeys e macros
- executor local de macros e hotkeys por id
- tipo de acao `typeText` com `wtype`
- sincronizacao automatica de hotkeys para o Niri via arquivo gerado

Ainda pendente:

- suporte global a hotkeys fora do Niri
- snippets
- acoes avancadas do Niri

## Decisao importante

O registro global de hotkeys nao esta no `ui/Settings.qml` e nao deve ficar la.

No ambiente atual, a estrategia adotada e integracao com o proprio Niri:

- o BindHub gera `~/.config/niri/cfg/bindhub.kdl`
- garante o `include` no `config.kdl`
- valida a configuracao
- pede `load-config-file` ao Niri

O BindHub deve ser tratado como `Wayland-first`.

Nao faz sentido basear a arquitetura principal em X11 quando o ambiente alvo do plugin esta em Wayland.

Por isso, o backend fica dentro da pasta do plugin, mas separado da UI.
