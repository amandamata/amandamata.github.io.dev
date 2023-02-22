---
title: "Implementando um publisher e consumer SQS usando dotnet"
date: 2023-02-22T07:19:25-03:00
draft: false
tags: ["queue","sqs","dotnet","aws"]
---

Nesse [post](/pt-pt/queue), eu passei a introdução de uma fila e como utilizá-la. Agora, eu vou explicar como implementar um consumer e sqs publisher usando c# dotnet.
<br/><br/>
##### SQS

O que é SQS?

SQS (Simple Queue Service) é um serviço da Amazon que permite que você envie, salve, e receba mensagens entre aplicações, sem que você perca essas mensagens caso o serviço esteja indisponível.

A melhor parte de tudo isso é que, para você pagar por esse serviço, você teria que enviar mais de um milhão de requisições por mês, para que a amazon te envie uma cobrança.

Para começar pe necessário criar uma conta na [aws](https://aws.amazon.com/) e então ir para o [console](https://console.aws.amazon.com).

Na área do console, digite SQS no campo de busca e entre na primeira opção, Simple Queue Service.

Clique em Create queue, e adicione o nome para a fila, e então vá para o final da página e clique em Create queue. Você pode alterar os valores que vem por padrão, mas para esse exemplos o padrão já está de acordo.
<br/><br/>
##### AWS Command Line Interface
A AWS Command Line Interface permite que façamos mudanças e requisições diretamente pelo console localmente, sem a necessidade de acessar o AWS console no navegador.

Se por exemplo quisermos listar os buckets:
```
aws s3api list-buckets
```

Para conseguirmos fazer isso, é necessário instalar o cli, o tutorial para Windows, Linux e macOs está [aqui](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

Depois da instalação, é necessário autenticar sua máquina na aws.

Na aws console, clique em seu nome e vá até Security Credentials, lá você precisa criar uma Access Key.

Então em seu console você vai digitar:
```
aws configure
```

Então coloque a sua access key e token quando solicitado.

> Importante, no console da aws você possui uma região, a minha é us-east-1, você pode ver a sua consultando a url: https://***us-east-1***.console.aws.amazon.com/

Essa região deve ser passada durante a configuração aws no console, para que consiga utilizar completamente as features via console localmente.

Depois da configuração finalizada, você poderá executar a listagem de buckets. 
```
aws s3api list-buckets
```
<br/>

##### Publisher
O que é um publisher?

Um publisher é um serviço que vai pegar uma informação que algo mudou por exemplo e enviar essa informação para a fila.
No exemplo que utilizei no post sobre a fila, o publisher estava dentro da API, e quando um novo usuário era criado a informação era enviada para a fila.

Então com tudo configurado, agora vamos criar o publisher.

Para deixar simples, o exemplo aqui vai ser apenas o publisher, então você pode pegar a implementação e aplicar na sua API.

Vamos utilizar o Console App

Crie uma nova pasta:
```
mkdir publisher
```
Entre na pasta:
```
cd publisher
```
Crie o projeto:
```
dotnet new console
```

Um modelo é necessário:
```
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

E instale o [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```
dotnet add package AWSSDK.SQS --version 3.7.100.78
```

Então na classe Program precisamos criar o request e enviá-lo:

```
using System.Text.Json;
using Amazon.SQS;
using Amazon.SQS.Model;

var sqsCLient = new AmazonSQSClient();

var customer = new CustomerCreated
{
  Id = Guid.NewGuid(),
  FullName = "Amanda Mata",
  Email = "email@email.com",
  DateOfBirth = new DateTime(1996, 06, 18)
};

var queueUrlResponse = await sqsCLient.GetQueueUrlAsync("customers");

var sendMessageRequest = new SendMessageRequest
{
  QueueUrl = queueUrlResponse.QueueUrl, 
  MessageBody = JsonSerializer.Serialize(customer),
  MessageAttributes = new Dictionary<string, MessageAttributeValue>
  {
      {
          "MessageType", new MessageAttributeValue
          {
              DataType = "String", 
              StringValue = nameof(CustomerCreated)
          }
      }
  }
};

var response = await sqsCLient.SendMessageAsync(sendMessageRequest);

Console.WriteLine();
```

> No sqsCLient.GetQueueUrlAsync("customers") eu utilizei "customers" porque esse é o nome da minha fila

<br/>

##### Consumer
O que é um consumer? 

Um consumer é o serviço que irá escutar a fila.

Vamos utilizar o Console App

Crie uma nova pasta:
```
mkdir consumer
```
Entre na pasta:
```
cd consumer
```
Crie o projeto:
```
dotnet new console
```

Um modelo é necessário:
```
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

E instale o [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```
dotnet add package AWSSDK.SQS --version 3.7.100.78
```

Então na classe Program precisamos receber a requisição:

```
using Amazon.SQS;
using Amazon.SQS.Model;
	 
var cts = new CancellationTokenSource();
var sqsCLient = new AmazonSQSClient();
var queueUrlResponse = await sqsCLient.GetQueueUrlAsync("customers");
var receiveMessageRequest = new ReceiveMessageRequest
{
  QueueUrl = queueUrlResponse.QueueUrl,
  AttributeNames = new List<string>{ "All" },
  MessageAttributeNames = new List<string>{ "All" }
};
	 
while(!cts.IsCancellationRequested)
{
  var response = await sqsCLient.ReceiveMessageAsync(receiveMessageRequest, cts.Token);
  response.Messages.ForEach(async message => {
    Console.WriteLine($"Message Id: { message.MessageId }");
    Console.WriteLine($"Message Body: { message.Body }");
    await sqsCLient.DeleteMessageAsync(queueUrlResponse.QueueUrl, message.ReceiptHandle);
  });

  await Task.Delay(3000);
}

Console.WriteLine();
```
<br/>

Agora o publisher e o consumer estão criados, você pode verificar as mensagens no aws console, mas apenas executando o publisher e o consumer você vai conseguir ver as mensagens sendo enviadas e sendo recebidas.

___

Eu criei esse post para meus estudos, os aprendizados passados aqui foram obtidos através do curso [Cloud Fundamentals: AWS Services for C# Developers course](https://nickchapsas.com/p/cloud-fundamentals-aws-services-for-c-developers).
