# BindHub Backend

O backend do BindHub fica dentro da pasta do plugin, em `bindhub/backend/`, e esta separado por dominio.

## Estrutura

- `execute.py`
  Entry point fino para execucao imediata.
- `common/`
  Leitura de configuracao e utilitarios compartilhados.
- `actions/`
  Implementacoes dos tipos de acao.
- `macros/`
  Resolucao e execucao de macros.
- `hotkeys/`
  Resolucao de hotkeys e sincronizacao com o Niri.

## Papel

Esta camada nao cuida de UI.

Ela existe para executar comportamento real que a interface apenas configura:

- executar hotkeys salvas
- executar macros
- suportar tipos de acao como `runCommand`, `openUrl`, `notify`, `typeText` e `delay`
- preparar a futura camada de hotkeys globais pensada para Wayland

## Estado atual

Ja implementado:

- leitura de `settings.json`
- execucao de macro por id
- execucao de hotkey por id
- suporte a `typeText` usando `wtype`
- sincronizacao de hotkeys para `~/.config/niri/cfg/bindhub.kdl`
- reload automatico do Niri apos salvar

Ainda pendente:

- suporte a outros compositores alem do Niri
- snippets de expansao
- acoes mais profundas do Niri

## Exemplos

Executar uma macro:

```bash
python3 bindhub/backend/execute.py --settings bindhub/settings.json run-macro macro-123
```

Executar uma hotkey ja configurada:

```bash
python3 bindhub/backend/execute.py --settings bindhub/settings.json run-hotkey hotkey-123
```

Digitar texto no foco atual:

```bash
python3 bindhub/backend/execute.py --settings bindhub/settings.json type-text ";email"
```

Carregar o esqueleto do daemon de hotkeys:

```bash
python3 bindhub/backend/hotkeys/daemon.py --settings bindhub/settings.json --once
```

Sincronizar hotkeys com o Niri:

```bash
python3 bindhub/backend/execute.py --settings bindhub/settings.json sync-hotkeys
```
