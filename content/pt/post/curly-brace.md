---
title: "Colchetes em uma nova linha no vscode"
date: 2023-02-18T06:12:47-03:00
draft: false
tags: ["vscode","solved", "c#", "omnisharp"]
---

Essa última semana eu levantei cedo todos os dias, tentando fazer apenas uma coisa: fazer o Visual Studio Code inserir uma nova linha antes dos colchetes {}.

Eu tenho isso:
```
if (true){
  // do something
}
```

e quero formatar dessa forma:
```
if (true)
{
  // do something
}
```

Não foi tão facil como parece ser. 

A mesma questão foi encontrada em vários sites, e no stack overflow, e as pessoas desapontadas sem uma solução. Então hoje eu vou compartilhar o que eu encontrei.


Primeiro você vai precisar:
1. Visual Studio Code atualizado
2. C# Extension atualizada
3. Sistema operacional atualizado
4. arquivo omnisharp.json
5. alterações no settings.json

##### Omnisharp

Você pode encontrar a localização do seu omnisharp em %USERPROFILE%/.omnisharp/

O meu omnisharp está em /home/amanda/.omnisharp/omnisharp.json

Essa é a minha configuração do omnisharp:

```
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
Baseado [nesse comentário](https://github.com/OmniSharp/omnisharp-vscode/issues/1506#issuecomment-303390666)

##### VSCode Settings	

Você pode encontrar o arquivo settings.json em ~/.config/Code/User

O meu arquivo está em /home/amanda/.config/Code/User/settings.json

Eu inseri essas linhas a mais no settings.json:
```
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

Para essas configurações funcionarem, é necessário ter a extensão c# instalada e habilitada, e depois de tudo isso, reiniciar o omnisharp.


Extension

{{< imgAbs 
pathURL="img/brace1.png" 
alt="Extension" 
class="some-class" 
style="some-style" >}}
</br></br>
Restart omnisharp
Ctrl+Shift+p

{{< imgAbs 
pathURL="img/brace2.png" 
alt="Restart ominisharp" 
class="some-class" 
style="some-style" >}}
</br></br>
Depois de todas essas alterações, você pode começar a utilizar o visual studio code e aproveitar os colchetes sendo inseridos em uma nova linha. MAS

O que me deixou fora da cama pela manhã foi, a formatação automática durante a digitação não está funcionando. Então, provavelmente você fez todas essas alterações sozinho mas também não funcionou... Para funcionar você precisa utilizar a opção Format Document no Visual Studio Code.

{{< imgAbs 
pathURL="img/brace3.png" 
alt="Format Document" 
class="some-class" 
style="some-style" >}}
</br></br>

Mas eu não queria ficar utilizando essa opção toda vez, então, depois de muita busca, eu encontrei essas configurações para o editor
- ***editor.formatOnSave***
- ***editor.formatOnPaste***
- ***editor.formatOnType***

Com essas configurações, quando salvar o arquivo e colar um código, a formatação será feita automaticamente.

MAS

A opção para formatar ao digitar ***formatOnType*** ainda não funciona... Então eu encontrei uma [issue no Github](https://github.com/microsoft/vscode-cpptools/issues/1419) falando sobre o problema, que o ***formatOnType*** não funciona para o c#, porque essa feature funciona validando o `;` (mais usado no js). Eles possuem essa correção no roadmap, mas até a correção sair o **formatOnSave*** vai fazer o trabalho.

