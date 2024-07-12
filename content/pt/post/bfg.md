---
title: "Como apagar uma informação sensível do histórico de commits"
date: 2023-05-30T14:01:29-03:00
draft: false
tags: ["git"]
---

Hoje aprendi algo extremamente útil: como remover informações sensíveis do histórico de commits de forma eficiente.

Acredito que em algum momento todos nós cometemos o erro de enviar acidentalmente informações sensíveis para um repositório no GitHub, e simplesmente apagar a informação não resolve o problema, uma vez que o histórico de commits ainda mostrará a versão anterior com essas informações.

Para solucionar essa questão, as pessoas costumam utilizar o git-filter-branch. No entanto, gostaria de apresentar uma alternativa ainda melhor: o BFG.

O BFG é uma ferramenta poderosa e fácil de usar que permite remover informações confidenciais do histórico de commits do seu repositório de forma segura. Ele oferece uma solução mais rápida e eficiente em comparação com o git-filter-branch.</br></br>

##### Cenário
Temos o repositório [how-to-use-bfg](https://github.com/amandamata/how-to-use-bfg)

Nesse repositório existia um appsettings.json com informações sensiveis

![bfg1](/img/bfg1.png)

Eu exclui essa informação sensivel, fiz o commit e push, mas no histórico essa informação sensivel ainda aparece

![bfg2](/img/bfg2.png)

</br></br>

##### Como utilizar
O tutorial no site do BFG não é difícil, mas vou descrever aqui de forma mais detalhada para tornar o processo mais compreensível e simples de seguir.

Para utilizar o BFG, siga estes passos:
1. Baixe o arquivo .jar do site do [BFG](https://rtyley.github.io/bfg-repo-cleaner/).
2. Faça um clone do repositório atual usando o comando:
	```
	git clone git@github.com:amandamata/how-to-use-bfg.git --mirror
	```
3. Crie um arquivo de referência contendo o valor que deseja remover do histórico de commits. Por exemplo:
	```
	echo *VyieIqbij35MYV5&bIakKmq1Z > auth.txt
	```
4. Execute o BFG, passando o valor de referência, usando o seguinte comando:
	```
	java -jar ~/Downloads/bfg-1.14.0.jar --replace-text auth.txt how-to-use-bfg.git
	```
5. Acesse o diretório do repositório clonado:
	```
	cd how-to-use-bfg.git
	```
6. Execute o seguinte comando:
	```
	git reflog expire --expire=now --all && git gc --prune=now --aggressive
	```
7. Faça o push das alterações:
	```
	git push
	```
	
Após seguir esses passos, o histórico de commits do seu repositório será atualizado e as informações sensíveis serão removidas.

![bfg3](/img/bfg3.png)


Experimente o BFG e garanta que suas informações confidenciais estejam protegidas no histórico de commits.
