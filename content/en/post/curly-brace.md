---
title: "Curly braces on new line in vscode"
date: 2023-02-18T06:13:07-03:00
draft: false
tags: ["vscode","dotnet"]
---

This past week, I dedicated my mornings to a single goal: configuring Visual Studio Code to automatically insert a new line before braces {}.

How it was:
```shell
if (true){
  // do something
}
```

How I wanted it to be:
```shell
if (true)
{
  // do something
}
```

The task proved to be more challenging than I expected. I found many discussions about the same issue in forums and on Stack  Overflow, but no definitive solution. So I'm here to share the solution I discovered.

First of all, you will need:

1. C# Extension;
2. `omnisharp.json` file;
3. Changes applied to `settings.json`.


## Configuring Omnisharp

You can find the location of your Omnisharp in `%USERPROFILE%/.omnisharp/`.
My Omnisharp is at `/home/amanda/.omnisharp/omnisharp.json`.

This is my Omnisharp configuration:
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
Configuration taken from [this comment](https://github.com/OmniSharp/omnisharp-vscode/issues/1506#issuecomment-303390666).

## Updating VSCode settings

You can find the `settings.json` file in `~/.config/Code/User`.
My file is at `/home/amanda/.config/Code/User/settings.json`.

I added these lines to the settings.json:
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
For these settings to work, you need to have the C# extension installed and enabled, and after all this, restart Omnisharp.

Here is the extension:
![brace1](/img/brace1.png)

Ctrl+Shift+P: Restart Omnisharp
![brace2](/img/brace2.png)


## Everything working BUT
After all these changes, you can start using Visual Studio Code and enjoy having braces inserted on a new line... BUT automatic formatting while typing is not working. To work, you need to use the Format Document option in Visual Studio Code.

![brace3](/img/brace3.png)

I didn't want to keep using this option every time, so after a lot of searching, I found these settings for the editor:
- ***editor.formatOnSave***
- ***editor.formatOnPaste***
- ***editor.formatOnType***

With these settings, when saving the file and pasting code, the formatting will be done automatically. 
BUT the option to format while typing ***formatOnType*** still doesn't work. 
I found a Github [issue](https://github.com/microsoft/vscode-cpptools/issues/1419) discussing the problem. 
The ***formatOnType*** does not work for C# because this feature validates the ; (more used in js). 
They have this fix on the roadmap, but until the fix is released, the ***formatOnSave*** will do the job.

