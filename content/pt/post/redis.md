
---
title: "Implementando um cache Redis com dotnet"
date: 2023-04-25T07:42:55-03:00
draft: true
tags: ["cache", "redis", "dotnet"]
---

Recentemente tive que implementar um cache em uma aplicação para evitar consultas desnecessárias ao banco de dados, e isso foi muito legal. Já trabalhei com Redis no passado, mas acho que fiz da maneira errada porque implementar um cache com Redis nunca foi tão legal.
<br/><br/>

##### Redis x Mem cached
O Redis é quase como um banco noSql, mas ele é ainda melhor pois armazena os dados com chave e valor e com isso fica muito mais facil de utilizar ele como um cache.
Mas o ponto principal nessa comparação é: depende, depende de como e quanto dado será utilizado nesse cache. Se for pouco dado como guardar informações de uma sessão, o MemCache faz sentido. Mas se estamos falando de muitas consultas com dados maiores, como os dados que armazenamos no banco, o Redis faz um melhor trabalho. Isso porque ao utilizar o MemCache estamos utilizando da memória da aplicação pra salvar aquelas informações, já o Redis é um cache distribuido, não tem relação nenhuma com a memória da aplicação e é possivel utilizar mais de um Redis database escalando verticalmente esse serviço conforme a demanda cresce.

A primeira vez que for necessário usar o cache a informação não vai estar lá, então é necessário consultar no banco e salvar no cache, a segunda vez já não é necessário ir ao banco, pois a informação estará no cache.  

{{< imgAbs 
pathURL="img/redis.jpg" 
alt="Redis" 
class="some-class" 
style="some-style" >}}

Continua
