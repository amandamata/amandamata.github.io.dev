---
title: "Removendo dados sensíveis do histórico de commits"
date: 2023-05-30T14:01:29-03:00
draft: false
tags: ["git"]
---

Hoje aprendi algo extremamente útil: como remover informações sensíveis do histórico de commits de forma eficiente.

Em algum momento, muitos de nós cometemos o erro de enviar acidentalmente informações sensíveis para um repositório no GitHub. Simplesmente apagar a informação do repositório atual não resolve o problema, pois o histórico de commits ainda mostrará a versão anterior com essas informações.

Para solucionar essa questão, muitos recorrem ao `git-filter-branch`. No entanto, quero apresentar uma alternativa ainda melhor: o BFG.

O BFG é uma ferramenta poderosa e fácil de usar que permite remover informações confidenciais do histórico de commits do seu repositório de forma segura. Ele oferece uma solução mais rápida e eficiente em comparação com o `git-filter-branch`.

#### Cenário

Temos o repositório [how-to-use-bfg](https://github.com/amandamata/how-to-use-bfg).

Nesse repositório existia um `appsettings.json` com informações sensíveis.

![bfg1](/img/bfg1.png)

Eu excluí essa informação sensível, fiz o commit e push, mas no histórico essa informação sensível ainda aparece.

![bfg2](/img/bfg2.png)

#### Pré-requisitos

- Git instalado na sua máquina.
- Java Runtime Environment (JRE) instalado para executar o arquivo `.jar` do BFG.

#### Como utilizar

O tutorial no site do BFG é bastante direto, mas aqui está uma descrição mais detalhada para facilitar o processo:

1. Baixe o arquivo `.jar` do BFG do site oficial: [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/).
   
2. Faça um clone do repositório usando o comando:
```shell
git clone git@github.com:amandamata/how-to-use-bfg.git --mirror
```
1. Crie um arquivo de referência contendo o valor que você deseja remover do histórico de commits. Por exemplo:
```shell
echo *VyieIqbij35MYV5&bIakKmq1Z > auth.txt
```
1. Execute o BFG, passando o valor de referência, usando o seguinte comando:
```shell
java -jar ~/Downloads/bfg-1.14.0.jar --replace-text auth.txt how-to-use-bfg.git
```
1. Acesse o diretório do repositório clonado:
```shell
cd how-to-use-bfg.git
```
1. Execute o seguinte comando:
```shell
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```
1. Faça o push das alterações:
```shell
git push
```
Após seguir esses passos, o histórico de commit do seu repositório será atualizado e os dados sensiveis serão removidos.

![bfg3](/img/bfg3.png)

#### Conclusão

Remover informações sensíveis do histórico de commits é crucial para manter a segurança e privacidade do seu projeto. O BFG Repo-Cleaner oferece uma maneira eficiente e rápida de fazer isso. Se você tiver alguma dúvida ou quiser compartilhar sua experiência usando o BFG, sinta-se à vontade para deixar um comentário abaixo.

Espero que este guia tenha sido útil. Boa sorte com a limpeza do seu repositório!