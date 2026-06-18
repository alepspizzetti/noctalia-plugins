# Planejamento do BindHub

## Objetivo

Construir um plugin do Noctalia que cubra as partes mais úteis de um fluxo no estilo AutoHotkey para Linux, com forte foco na integração com o Niri e na automação cotidiana do desktop.

O BindHub deve resolver a lacuna prática de "sinto falta do AutoHotkey no Linux" sem tentar clonar o próprio AutoHotkey.

## Definição do Produto

O BindHub será um plugin de automação pessoal para o Noctalia com cinco áreas centrais:

- hotkeys (v1)
- macros (v1)
- snippets de texto (v2)
- ações de janela do Niri (v3)
- perfis (v4)

O produto deve priorizar:

- configuração simples
- comportamento previsível
- baixo fator de surpresa
- depuração fácil

Ele não deve começar com uma linguagem de script completa.

## O Que Estamos Construindo

### 1. Hotkeys

O usuário define um gatilho e uma ação.

Na definição do gatilho, o plugin deve pedir para o usuário pressionar a combinação desejada e identificar automaticamente quais teclas estão sendo usadas.

Após essa identificação, o usuário vincula o que deseja executar, seja uma macro salva ou um comando no terminal.

Exemplos:

- `Super+Shift+T` -> abrir terminal
- `Super+Shift+G` -> abrir GitHub
- `Super+Alt+1` -> focar workspace
- `Super+Alt+F` -> alternar floating na janela focada

### 2. Macros

O usuário define um gatilho e múltiplas ações ordenadas.

Aqui teremos um gerenciador (CRUD) de macros, no qual será possível definir o nome, o comando da macro e um botão para teste.

Exemplos:

1. abrir terminal
2. abrir Rider
3. abrir navegador
4. focar workspace 2

### 3. Snippets de Texto

O usuário define entradas de expansão para conteúdos repetitivos. A ideia é parecida com macros, mas aqui o foco é apenas texto, em uma experiência semelhante ao `Super+V` do plugin de clipboard.

Exemplos:

- `;email`
- `;passwd`
- `;addr`
- `;pix`

Essas entradas devem se expandir para textos predefinidos.

## Plataforma-Alvo

O MVP será Noctalia-first.

## Papel do Plugin vs Papel do Backend

### Papel do Plugin

O plugin do Noctalia deve fornecer:

- UI de configurações integrada com o noctalia-shell

### Papel do Backend

Um processo auxiliar ou daemon deve cuidar da execução real:

- estratégia de registro de gatilhos globais
- execução de comandos
- expansão de texto
- interação com `niri msg`
- sequenciamento
- delays
- logging

O QML não deve virar o motor de execução de tudo.

## Escopo do MVP

O escopo funcional será evolutivo. No curto prazo, o v1 deve priorizar hotkeys e macros. Em seguida, o produto pode evoluir para snippets e, depois, para ações de janela mais profundas.

Como modelo geral de ações suportadas pelo BindHub, o sistema deve considerar os seguintes tipos:

- `runCommand`
- `openUrl`
- `notify`
- `focusWindow`
- `moveWindowToWorkspace`
- `moveWindowToMonitor`
- `toggleFloating`
- `centerWindow`
- `resizeFloatingWindow`
- `typeText`
- `delay`

Isso já é suficiente para tornar o plugin útil sem exagerar no escopo.

## Experiência do Usuário

A primeira versão deve parecer um painel prático de automação, não um ambiente de programação.

O fluxo do usuário deve ser:

1. criar um binding
2. escolher um gatilho
3. escolher uma ação ou uma macro
4. testar
5. salvar

Para snippets:

1. criar o texto de gatilho
2. definir o texto de saída
3. habilitar

## Modelo de Configuração Sugerido

O plugin deve usar um modelo de configuração estruturado desde o início.

Seções de topo sugeridas:

- `enabled`
- `hotkeys`
- `snippets`
- `macros`

Cada hotkey deve referenciar:

- uma ação
- uma macro

Cada macro deve conter:

- lista ordenada de ações
- etapas opcionais de delay entre comandos

Cada snippet deve conter:

- trigger
- replacement
- flag de habilitado

## Integração com o Niri

O BindHub deve se integrar bem ao ambiente do Noctalia e parecer o mais nativo possível.

Ações centrais que devem ser bem suportadas:

- focar por id
- focar por correspondência de app id
- alternar floating
