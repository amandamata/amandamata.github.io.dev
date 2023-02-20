---
title: "Application of queue"
date: 2023-02-08
draft: false
tags: ["aws", "sqs", "queue"]
---

What is a queue?
A queue is a collection of entities that are maintained in a sequence and can be modified by the addition of entities at one end of the sequence and the removal of entities from the other end of sequence. Wikipedia

Imagine that we have a user's API.

{{< imgAbs 
pathURL="img/queue2.png" 
alt="Some description" 
class="some-class" 
style="some-style" >}}


We can create users in the system and then retrieve them back, maybe update and maybe delete them, send an email to the user, and also make a request to another API.
In this scenario, if when sending an email and that email fails, that entire request fails and it's necessary to make another request to have the entire process done.

{{< imgAbs 
pathURL="img/queue1.png" 
alt="Some description" 
class="some-class" 
style="some-style" >}}


But that does not need to be like this, cuz sending an email and making the request to another API for this flow it's not crucial and could be done later async.


Here enter the queue concept.
We could instead of making all those things sync, make only the crucial sync and the rest async by adding in a queue what could be done later.

To get this done it's necessary to have a consumer service, that will be listening to the queue and do something with the information in the queue, like sending an email.

{{< imgAbs 
pathURL="img/queue3.png" 
alt="Some description" 
class="some-class" 
style="some-style" >}}

That makes your system more resilient if something fails to process, it's going back to the queue and then will be reprocessed later.


To continue studying: SQS Simple Queue Service, AWS

