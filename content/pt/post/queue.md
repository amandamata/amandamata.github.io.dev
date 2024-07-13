---
title: "Usos para uma fila"
date: 2023-02-08
draft: false
tags: ["queue"]
---

## O que é uma fila?
Uma fila é uma estrutura de dados dinâmica que admite remoção de elementos e inserção de novos objetos. Mais especificamente, uma fila (= queue) é uma estrutura sujeita à seguinte regra de operação: sempre que houver uma remoção, o elemento removido é o que está na estrutura há mais tempo.
As filas seguem o princípio FIFO (First In, First Out), onde o primeiro elemento adicionado é o primeiro a ser removido. Isso é útil para muitas aplicações em sistemas distribuídos, onde a ordem das operações é importante.

## Caso de uso
Imagine que temos uma API de usuários.

Com essa API, podemos criar usuários, atualiza-lós, deletá-los e receber uma resposta dessas operações, enviar um email para o usuário e fazer uma requisição para outra API.
Nesse cenário, se ao enviar um um e-mail ocorrer uma falha, toda a requisição falhará, e para obter uma resposta de sucesso será necessário enviar outro request.

![queue1](/img/queue1.png)

No entanto, isso não precisa ser assim. Enviar um e-mail e fazer a solicitação para outra API nesse fluxo não é crucial e pode ser feito de forma assíncrona posteriormente.

## Introduzindo o conceito de fila
Aqui entra o conceito de fila. Em vez de fazer todas essas operações de forma síncrona, podemos fazer apenas as operações cruciais de forma síncrona e as demais de forma assíncrona, adicionando na fila o que pode ser feito depois.

Para que isso funcione, é necessário ter um serviço consumidor que ficará ouvindo a fila e fará algo com as informações nela contidas, como enviar um e-mail.

![queue2](/img/queue2.png)

Isso torna seu sistema mais resiliente. Se algo falhar no processamento, a mensagem volta para a fila e será reprocessada posteriormente.

## Benefícios de usar filas
1. Resiliência: Se um componente do sistema falhar, a mensagem pode ser reprocessada.
2. Escalabilidade: Publisher e Consumers podem ser escalados independentemente.
3. Desacoplamento: Reduz a dependência direta entre componentes do sistema, permitindo maior flexibilidade e manutenção.
4. Gerenciamento de picos de carga: Filas permitem que o sistema lide com picos de carga distribuindo o processamento ao longo do tempo.
5. Prioridade: Mensagens podem ser priorizadas para garantir que as mais importantes sejam processadas primeiro.

## Ferramentas
### AWS SQS (Simple Queue Service)
AWS SQS é um serviço totalmente gerenciado de filas de mensagens que permite desacoplar e escalar microserviços, sistemas distribuídos e aplicativos sem servidor. Com SQS, você pode enviar, armazenar e receber mensagens entre componentes de software.

### RabbitMQ
RabbitMQ é um dos mensageiros mais amplamente implantados na nuvem e on-premises. É um middleware de mensagens confiável que pode ser usado para filas de mensagens, roteamento de mensagens, balanceamento de carga e muito mais.

### Apache Kafka
Apache Kafka é uma plataforma distribuída de streaming de eventos. É usada para criar pipelines de dados em tempo real e aplicativos de streaming, oferecendo alta taxa de transferência, baixa latência e durabilidade de mensagens.

## Conclusão
O uso de filas pode tornar seu sistema mais robusto e eficiente, permitindo que tarefas não cruciais sejam processadas de forma assíncrona. Isso melhora a resiliência e escalabilidade do sistema, garantindo que falhas em operações secundárias não afetem a experiência do usuário. Além disso, com ferramentas como AWS SQS, RabbitMQ e Apache Kafka, a implementação de filas é acessível e poderosa.
