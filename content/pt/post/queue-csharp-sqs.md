---
title: "Implementando um Publicador e Consumidor SQS Usando .NET"
date: 2023-02-22T07:19:25-03:00
draft: false
tags: ["queue","dotnet"]
---

Em um post anterior, introduzi o conceito de filas e seu uso. Agora, explicarei como implementar um Consumer (consumidor) e Publisher (publicador) SQS usando C# e .NET.

## SQS
SQS (Simple Queue Service) é um serviço da Amazon Web Services que permite enviar, armazenar e receber mensagens entre componentes de software em qualquer volume, garantindo que nenhuma mensagem seja perdida e eliminando a necessidade de disponibilidade imediata de outros serviços.

Uma das melhores características do SQS é sua relação custo-benefício; é gratuito para até 1 milhão de solicitações por mês, após o qual a Amazon começa a cobrar pelo serviço.

Para começar, você precisa criar uma conta na [AWS](https://aws.amazon.com/) e navegar até o [AWS Management Console](https://console.aws.amazon.com).

No console, procure por SQS e selecione a primeira opção, Simple Queue Service. Clique em "Create queue", nomeie sua fila e vá até o final da página para clicar em "Create queue". As configurações padrão são suficientes para começar, mas sinta-se à vontade para ajustá-las conforme necessário.

### AWS Command Line Interface

A AWS Command Line Interface (CLI) permite fazer alterações diretamente do terminal, sem a necessidade de usar o AWS Management Console. Por exemplo, para listar todos os buckets do S3, você pode usar o seguinte comando:
```shell
aws s3api list-buckets
```

Para poder fazer isso, precisamos instalar a CLI, o tutorial para Windows, Linux e macOS está [aqui](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

Após a instalação, é necessário autenticar sua máquina contra a AWS.

No console da AWS, clique no seu nome e vá para Credenciais de Segurança, lá, você precisa criar uma Chave de Acesso.

No seu console, digite:
```shell
aws configure
```

Em seguida, forneça sua chave de acesso e token quando solicitado.

Importante, no console da AWS você tem uma região, a minha é us-east-1, você pode ver a sua verificando a URL: https://***us-east-1***.console.aws.amazon.com/

Essa região precisa ser informada durante a configuração da AWS para poder acessar os recursos localmente.

Após a configuração, você poderá executar o comando de listar buckets:
```shell
aws s3api list-buckets
```
<br/>

## Publisher
O que é um publisher?

Um publisher é um serviço que detecta mudanças ou eventos e envia uma mensagem para uma fila. No contexto do exemplo discutido no post anterior sobre filas, o publisher reside dentro de uma API. Por exemplo, após criar um novo usuário, o publisher envia uma mensagem para a fila para notificar outras partes do sistema sobre este evento.

Agora que temos nossa configuração pronta, vamos criar o publisher.

Para simplicidade, este exemplo focará apenas no componente do publisher. Você pode integrar essa implementação à sua API conforme necessário.

Usaremos um aplicativo de console para esta demonstração.

Abra seu terminal ou prompt de comando e execute o seguinte comando para criar uma nova pasta chamada publisher:

Crie uma nova pasta:
```shell
mkdir publisher
```
Entre na pasta:
```shell
cd publisher
```
Crie o projeto:
```shell
dotnet new console
```

É necessário um model:
```csharp
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

E instale o [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```shell
dotnet add package AWSSDK.SQS --version 3.7.100.78
```

Então na classe Program precisamos criar o request e enviá-lo:

```csharp
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

## Consumer
O que é um Consumer?

Um consumer é um serviço projetado para ouvir a fila. Ele espera que as mensagens cheguem à fila e as processa de acordo com a lógica de negócios definida.
Para esta parte da implementação, também usaremos um aplicativo de console para demonstrar como um consumidor pode ser configurado para ouvir e processar mensagens da fila.

Crie uma nova pasta:
```shell
mkdir consumer
```
Entre na pasta:
```shell
cd consumer
```
Crie o projeto:
```shell
dotnet new console
```

É necessário um model:
```csharp
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

E instale o [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```shell
dotnet add package AWSSDK.SQS --version 3.7.100.78
```

Depois disso, no Program, precisamos receber a solicitação:
```csharp
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

Agora que tanto o publicador quanto o consumidor foram criados, você tem a opção de verificar as mensagens diretamente do console da AWS. No entanto, simplesmente executando o publicador e o consumidor, você poderá observar o processo de envio e recebimento de mensagens em ação.

___

Eu criei esse post para meus estudos, os aprendizados passados aqui foram obtidos através do curso [Cloud Fundamentals: AWS Services for C# Developers course](https://nickchapsas.com/p/cloud-fundamentals-aws-services-for-c-developers).
