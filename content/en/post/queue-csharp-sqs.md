
---
title: "Implementing an SQS Publisher and Consumer Using .NET"
date: 2023-02-22T07:19:25-03:00
draft: false
tags: ["queue","dotnet"]
---

In a previous post, I introduced the concept of queues and their usage. Now, I will explain how to implement an SQS consumer and publisher using C# and .NET.

## SQS
SQS (Simple Queue Service) is an Amazon Web Services offering that enables the sending, storing, and receiving of messages between software components at any volume, ensuring no message loss and eliminating the need for immediate availability of other services.

One of the best features of SQS is its cost-effectiveness; it's free for up to 1 million requests per month, after which Amazon starts billing for the service.

To begin, you need to create an account on [AWS](https://aws.amazon.com/) and navigate to the [AWS Management Console](https://console.aws.amazon.com).

In the console, search for SQS and select the first option, Simple Queue Service. Click on "Create queue", name your queue, and proceed to the end of the page to click "Create queue". Default settings are sufficient for starting, but feel free to adjust as necessary.

### AWS Command Line Interface

The AWS Command Line Interface (CLI) enables making changes directly from the terminal, bypassing the need to use the AWS Management Console. For instance, to list all S3 buckets, you can use the following command:

```shell
aws s3api list-buckets
```

To be able to do that we need to install the cli, the tutorial for Windows, Linux, and macOS is [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

After the installation, it's necessary to authenticate your machine against aws.

In aws console, click in your name and go to Security Credentials, there, you need to create an Access Key.

In your console you gonna type:
```shell
aws configure
```

Then pass your access key and token when requested.

> Important, in the aws console you have a region, mine is us-east-1, you can see yours by checking on url: https://***us-east-1***.console.aws.amazon.com/

That region needs to be passed during aws configuration, to be able to access aws features locally.

After the configuration, you're gonna able to execute the list buckets. 
```shell
aws s3api list-buckets
```
<br/>

## Publisher
What is a Publisher?

A publisher is a service that detects changes or events and sends a message to a queue. In the context of the example discussed in the previous post about queues, the publisher resides within an API. For instance, after creating a new user, the publisher sends a message to the queue to notify other parts of the system about this event.

Now that we have our setup ready, let's proceed to create the publisher.

For simplicity, this example will focus solely on the publisher component. You can later integrate this implementation into your API as needed.

We will use a Console Application for this demonstration.

Open your terminal or command prompt and run the following command to create a new folder named `publisher`:

Create a new folder:
```shell
mkdir publisher
```
Go inside the folder:
```shell
cd publisher
```
Create the project:
```shell
dotnet new console
```

It's necessary a model:
```csharp
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

And install the [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```shell
dotnet add package AWSSDK.SQS --version 3.7.100.78
``` 

After that, in the Program we need to create a request and send it:

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

> In the sqsCLient.GetQueueUrlAsync("customers") I used "customers" cuz that is the name of my queue

<br/>

## Consumer
What is a Consumer?

A consumer is a service designed to listen to the queue. It waits for messages to arrive in the queue and processes them according to the defined business logic.

For this part of the implementation, we will also use a Console Application to demonstrate how a consumer can be set up to listen to and process messages from the queue.

Create a new folder:
```shell
mkdir consumer
```
Go inside the folder:
```shell
cd consumer
```
Create the project:
```shell
dotnet new console
```

It's necessary a model:
```csharp
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

And install the [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```shell
dotnet add package AWSSDK.SQS --version 3.7.100.78
```

After that, in the Program we need to receive the request:

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

Now that both the publisher and the consumer have been created, you have the option to pull messages directly from the AWS console. However, by simply running the publisher and the consumer, you will be able to observe the process of sending and receiving messages in action.
___

I create this post for my studying purpose, the learnings I posted here were driven by the [Cloud Fundamentals: AWS Services for C# Developers course](https://nickchapsas.com/p/cloud-fundamentals-aws-services-for-c-developers).

