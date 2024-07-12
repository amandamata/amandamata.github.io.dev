---
title: "Implementing a sqs publisher and consumer using dotnet"
date: 2023-02-22T07:19:25-03:00
draft: false
tags: ["queue","sqs","dotnet","aws"]
---

In this [post](/queue), I pass an introduction to a queue and how to use it. Now I gonna explain how to implement an sqs consumer and publisher using c# dotnet.
<br/>
#### SQS

What is SQS?

SQS (Simple Queue Service) is an Amazon service that lets you send, store, and receive messages between software components at any volume, without losing messages or requiring other services to be available.

The best part is free, actually to pay for this service you gonna need to send over 1 million requests per month then amazon is going to bill you.

To start, it's necessary to create an account in [aws](https://aws.amazon.com/) and go to [console](https://console.aws.amazon.com).

In the console area, type SQS in search and enter the first option Simple Queue Service.
Click on Create queue, add a name to the queue and go to the end of the page and click Create queue. You can change the default values, but for now, all the settings are ok.
<br/>
#### AWS Command Line Interface

The AWS Command Line Interface allows us to make changes directly from the console without the need to access the AWS console.
For example, if we need to list the buckets:
```
aws s3api list-buckets
```

To be able to do that we need to install the cli, the tutorial for Windows, Linux, and macOS is [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

After the installation, it's necessary to authenticate your machine against aws.

In aws console, click in your name and go to Security Credentials, there, you need to create an Access Key.

In your console you gonna type:
```
aws configure
```

Then pass your access key and token when requested.

> Important, in the aws console you have a region, mine is us-east-1, you can see yours by checking on url: https://***us-east-1***.console.aws.amazon.com/

That region needs to be passed during aws configuration, to be able to access aws features locally.

After the configuration, you're gonna able to execute the list buckets. 
```
aws s3api list-buckets
```
<br/>

#### Publisher
What is a publisher?

A publisher it's a service that gonna get the information that something changes and sends to the queue a request.
In the example used in the queue post, the publisher is inside the API, and after a new user was created the request was sent to the queue.

So with everything configured, it's time to create the publisher.

In order to simplify, the example here it's gonna be only the publisher, then you can take the implementation and use it in your API.

We're gonna use a Console App

Create a new folder:
```
mkdir publisher
```
Go inside the folder:
```
cd publisher
```
Create the project:
```
dotnet new console
```

It's necessary a model:
```
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

And install the [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```
dotnet add package AWSSDK.SQS --version 3.7.100.78
``` 

After that, in the Program we need to create a request and send it:

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

> In the sqsCLient.GetQueueUrlAsync("customers") I used "customers" cuz that is the name of my queue

<br/>

#### Consumer
What it's a consumer? 

A consumer it's the service that will be listening the queue.

We're gonna use a Console App

Create a new folder:
```
mkdir consumer
```
Go inside the folder:
```
cd consumer
```
Create the project:
```
dotnet new console
```

It's necessary a model:
```
public class CustomerCreated
{
  public Guid Id { get; init; }
  public string FullName { get; init; }
  public string Email { get; init; }
  public DateTime DateOfBirth { get; init; }
}
```

And install the [AWS SDK](https://www.nuget.org/packages/AWSSDK.SQS)
```
dotnet add package AWSSDK.SQS --version 3.7.100.78
```

After that, in the Program we need to receive the request:

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

Now the publisher and the consumer It's created, you can pull for messages inside the aws console, but just running the publisher and the consumer you're gonna be able to see the sending and receiving messages.
___

I create this post for my studying purpose, the learnings I posted here were driven by the [Cloud Fundamentals: AWS Services for C# Developers course](https://nickchapsas.com/p/cloud-fundamentals-aws-services-for-c-developers).

