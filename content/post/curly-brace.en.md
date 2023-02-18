---
title: "Curly braces on new line in vscode"
date: 2023-02-18T06:13:07-03:00
draft: false
tags: ["vscode","solved", "c#", "omnisharp"]
---
<code><a href="/curly-brace">en</a></code>
<code><a href="/pt-pt/curly-brace">pt-pt</a></code>

This pass week I wake up early every day trying to do only one thing: make Visual Studio Code insert a new line before a curly bracket, braces {}.

I have this:
```
if (true){
  // do something
}
```

and I want to format it like this:
```
if (true)
{
  // do something
}
```

Was not as easy thing as may seem.
Many sites and stack overflow have the same question, with many disappointing people without a resolution. So today I gonna share what I found.

First things first, you gonna need:
1. Latest Visual Studio Code
2. Latest C# Extension
3. Updated OS
4. omnisharp.json file 
5. settings.json modifications

##### Omnisharp

You can find your omnisharp location by checking on %USERPROFILE%/.omnisharp/

Mine is in /home/amanda/.omnisharp/omnisharp.json

This is my omnisharp config:

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
Based on [this comment](https://github.com/OmniSharp/omnisharp-vscode/issues/1506#issuecomment-303390666)

##### VSCode Settings	

You can find your settings.json location by checking on ~/.config/Code/User

Mine is in /home/amanda/.config/Code/User/settings.json

I've inserted these lines in my settings.json:
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

For this config work it's necessary to have the c# extension installed and enable and after these changes, restart omnisharp.


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
After all of these changes, you can start using your visual studio code and enjoy braces in the new line. BUT

The thing that takes me out of bed is, the auto format on type it's not working. So probably you make all of these changes by yourself, and still not working... is because to work you need to use Format Document in Visual Studio Code.

{{< imgAbs 
pathURL="img/brace3.png" 
alt="Format Document" 
class="some-class" 
style="some-style" >}}
</br></br>
But I don't want to use this option all the time.

After a lot of searching, I've found this editor settings
- ***editor.formatOnSave***
- ***editor.formatOnPaste***
- ***editor.formatOnType***

With this settings, when save and on past the format will be done automatically.

BUT

Format on type still not working... Then I've found an [issue in Github](https://github.com/microsoft/vscode-cpptools/issues/1419) on vscode saying that ***formatOnType*** was not working for c#, because this feature work by checking `;` (most used in js). They have this fix in roadmap, but until they fix, format on save will do the job.

