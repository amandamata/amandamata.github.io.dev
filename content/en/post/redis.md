
---
title: "Implementing a redis cache in dotnet"
date: 2023-04-25T07:42:55-03:00
draft: true
tags: ["cache", "redis", "dotnet"]
---

I recently had to implement a cache in an application to avoid unnecessary database queries, and that was cool. I've worked with Redis in the past, but I think I've done it the wrong way because implementing a cache with Redis has never been so cool.
<br/><br/>

##### Redis vs Mem cached
Redis is almost like a NoSql database, but it is even better because it stores data with key and value and with that, it is much easier to use it as a cache.
But the main point in this comparison is: it depends, it depends on how and how much data will be used in this cache. If you're not sure how to store session information, MemCache makes sense. But if we're talking about a lot of queries with bigger data, like the data we store in the database, Redis does a better job. This is because when using MemCache we are using the application's memory to save that information, since Redis is a distributed cache, it has nothing to do with the application's memory and it is possible to use more than one Redis database, scaling this service vertically according to demand grow up.

The first time it is necessary to use the cache the information will not be there, so it is necessary to consult the database and save it in the cache, the second time it is no longer necessary to go to the database, because the information will be in the cache. And this makes the application take less time to respond to a request, as going to the bank takes much longer than going to Redis.

{{< imgAbs
pathURL="img/redis.png"
alt="Redis"
class="some-class"
style="some-style" >}}
<br/><br/>

##### Implementation

Explanation given let's implement!
For this implementation we will follow a pattern called Decorator, with this pattern it is possible to add a cache layer without adding more complexity to the repository layer.
