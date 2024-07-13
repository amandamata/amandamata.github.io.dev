---
title: "Colchetes em uma nova linha no vscode"
date: 2023-02-18T06:12:47-03:00
draft: false
tags: ["vscode","dotnet"]
---

Nesta última semana, dediquei minhas manhãs a um único objetivo: configurar o Visual Studio Code para inserir automaticamente uma nova linha antes dos colchetes `{}`.

Como estava:
```csharp
if (true){
  // do something
}
```

Como gostaria que estivesse:
```csharp
if (true)
{
  // do something
}
```

A tarefa se mostrou mais desafiadora do que eu esperava.
Encontrei muitas discussões sobre o mesmo problema em fóruns e no Stack Overflow, mas nenhuma solução definitiva. Então estou aqui para compartilhar a solução que descobri.

Antes de tudo, você precisará de:
1. Extensão C#;
2. Arquivo `omnisharp.json`;
3. Alterações aplicadas no `settings.json`.

## Configurando o Omnisharp

A localização do seu Omnisharp pode ser encontrada em `%USERPROFILE%/.omnisharp/` 
O meu omnisharp está em `/home/amanda/.omnisharp/omnisharp.json`

Essa é a minha configuração do omnisharp:

```json
{
    "FormattingOptions": {
        "newLine": "\n",
        "useTabs": false,
        "tabSize": 4,
        "indentationSize": 4,

        "NewLinesForBracesInTypes": true,
        "NewLinesForBracesInMethods": true,
        "NewLinesForBracesInProperties": true,
        "NewLinesForBracesInAccessors": true,
        "NewLinesForBracesInAnonymousMethods": true,
        "NewLinesForBracesInControlBlocks": true,
        "NewLinesForBracesInAnonymousTypes": true,
        "NewLinesForBracesInObjectCollectionArrayInitializers": true,
        "NewLinesForBracesInLambdaExpressionBody": true,

        "NewLineForElse": true,
        "NewLineForCatch": true,
        "NewLineForFinally": true,
        "NewLineForMembersInObjectInit": true,
        "NewLineForMembersInAnonymousTypes": true,
        "NewLineForClausesInQuery": true,
    }
}
```
Configurações retiradas [desse comentário](https://github.com/OmniSharp/omnisharp-vscode/issues/1506#issuecomment-303390666)

## Atualizando as configurações do VSCode

Você pode encontrar o arquivo `settings.json` em `~/.config/Code/User`
O meu arquivo está em `/home/amanda/.config/Code/User/settings.json`

Eu inseri essas linhas a mais no `settings.json`:

```json
    "omnisharp.json": "/home/amanda/.omnisharp",
    "omnisharp.enableEditorConfigSupport": false,
    "omnisharp.useEditorFormattingSettings": true,
    "omnisharp.path": "latest",
    "editor.formatOnType": true,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "editor.defaultFormatter": "ms-dotnettools.csharp",
    "[csharp]": {"editor.defaultFormatter": "ms-dotnettools.csharp"}
```
Para essas configurações funcionarem, é necessário ter a extensão C# instalada e habilitada, e depois de tudo isso, reiniciar o omnisharp.

Essa é a extensão:
![brace1](/img/brace1.png)

Restart omnisharp
`Ctrl+Shift+P`
![brace2](/img/brace2.png)

## Tudo funcionando MAS
Depois de todas essas alterações, você pode começar a utilizar o visual studio code e aproveitar os colchetes sendo inseridos em uma nova linha...
MAS
A formatação automática durante a digitação não está funcionando, para funcionar é necessário utilizar a opção Format Document no Visual Studio Code.

![brace3](/img/brace3.png)

Eu não queria ficar utilizando essa opção toda vez, então, depois de muita busca, eu encontrei essas configurações para o editor:
- ***editor.formatOnSave***
- ***editor.formatOnPaste***
- ***editor.formatOnType***

Com essas configurações, quando salvar o arquivo e colar um código, a formatação será feita automaticamente.
MAS
A opção para formatar ao digitar ***formatOnType*** ainda não funciona.
Encontrei uma [issue no Github](https://github.com/microsoft/vscode-cpptools/issues/1419) falando sobre o problema. O ***formatOnType*** não funciona para o C#, porque essa feature funciona validando o `;` (mais usado no js). Eles possuem essa correção no roadmap, mas até a correção sair o ***formatOnSave*** vai fazer o trabalho.
