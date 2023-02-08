---
title: "Fila"
date: 2023-02-08
publishdate: 2023-02-08
lastmod: 2023-02-08
draft: false
tags: ["aws", "sqs", "fila"]
---


<code><a href="https://amandamata.github.io/queue">en</a></code>

O que é uma fila?
Uma fila é uma estrutura de dados dinâmica que admite remoção de elementos e inserção de novos objetos. Mais especificamente, uma fila (= queue) é uma estrutura sujeita à seguinte regra de operação: sempre que houver uma remoção, o elemento removido é o que está na estrutura há mais tempo.



Imagine que temos uma api de usuários

{{< imgAbs 
pathURL="img/queue1.png" 
alt="Some description" 
class="some-class" 
style="some-style" >}}

Com essa API, podemos criar usuários no sistema e receber uma resposta dessa criação, talvez até atualizar ou deletar o usuário, enviar um email para o usuário e fazer uma requisição para outra API.
Nesse cenário, se enviarmos um email, e nessa etapa falhar, a requisição inteira não vai estar completa, e para obter uma resposta de sucesso será necessário enviar outro request.

{{< imgAbs 
pathURL="img/queue2.png" 
alt="Some description" 
class="some-class" 
style="some-style" >}}

Mas não precisa ser dessa forma, porque enviar um email e fazer a requisição para outra API, para esse fluxo não é tão importante quanto salvar no banco as informações. E podem ser feitos depois, de maneira assíncrona.



É nesse momento que o conceito de fila vai nos ajudar.

Ao invés de fazer todas essas coisas sincronamente, podemos fazer apenas o crucial de forma síncrona, e o restante de forma assíncrona apenas adicionando em uma fila o que pode ser feito depois.
Para que isso aconteça será necessário que tenhamos um consumer service, que vai ficar escutando o que tem na fila e fazer algo com a informação da fila,como enviar o email.

{{< imgAbs 
pathURL="img/queue3.png" 
alt="Some description" 
class="some-class" 
style="some-style" >}}

Isso faz com que seu sistema seja mais resiliente, e se algo falhar, vai voltar para a fila e será processado novamente depois.


Para continuar estudando: SQS Simple Queue Service, AWS

