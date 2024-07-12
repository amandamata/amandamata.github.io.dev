---
title: "Implementing Redis caching with dotnet"
date: 2023-04-25T07:42:55-03:00
tags: ["cache","dotnet"]
draft: false
---

I recently had to implement a cache in an application to avoid unnecessary database queries, and that was cool. I've worked with Redis in the past, but I think I've done it the wrong way because implementing a cache with Redis has never been so cool.
<br/>

#### Redis vs Mem cached
Redis is almost like a NoSql database, but it is even better because it stores data with key and values and with that, it is much easier to use it as a cache.
But the main point in this comparison is: it depends, it depends on how and how much data will be used in this cache. If you're not sure how to store session information, MemCache makes sense. But if we're talking about a lot of queries with bigger data, like the data we store in the database, Redis does a better job. This is because when using MemCache we are using the application's memory to save that information, since Redis is a distributed cache, it has nothing to do with the application's memory and it is possible to use more than one Redis database, scaling this service vertically according to demand grow up.

The first time it is necessary to use the cache, the information will not be there, so it is necessary to consult the database and save it in the cache, the second time it is no longer necessary to go to the database, as the information will be in the cache. And this makes the application take less time to respond to a request, as going to the bank takes much longer than going to Redis.

![redis](/img/redis.png)
<br/>

#### Why use
- Reduce response time
Improve the end-user experience with the application, making him wait less for each click or action.

- Raise availability
Since it is necessary to consume less computational resources, because it is already in the cache and I return it faster to the end user, it is then possible to have more users accessing the application simultaneously.

- Reduce computational costs
When we are talking about the cloud, we are reducing the consumption of lambdas and resources where the monthly bill can be cheaper.

The cost of a cache is high, so it has to be expensive on the server side to make this migration to the cache. For example, problems with the delay in response to the end customer can be costly, the end customer can simply give up using the application due to the delay, and many other problems that this delay can generate. To reduce both the cost of losing a customer and the cost of consulting the bank, the cache is then used to solve these problems.
<br/>
#### Problem
Suppose there is an application that makes many calls to the database, but always consulting the same information, when the application was developed the developers did not think it could grow so much, and a cache was not implemented to avoid these queries to the database.
The application is for car rental for companies, and the query is simple, with each request received at the rental endpoint, it is necessary to check whether the company (document) informed in the rental request is the same as the one in the bank.
We have the scenario, let's move on to implementation.
<br/>
#### Implementation
Explanation and problem presentations, let's implement!
For this implementation we will follow a pattern called Decorator, with this pattern it is possible to add a cache layer without adding more complexity to the repository layer, and we will follow the S principle of SOLID, [Single-responsibility principle](https:// g.co/kgs/phLumf).

Let's work with dotnet, and install the packages [Scrutor](https://www.nuget.org/packages/scrutor/) and [StackExchangeRedis](https://www.nuget.org/packages/Microsoft.Extensions.Caching.StackExchangeRedis/7.0.5)

```shell
dotnet add package Scrutor --version 4.2.2
```

```shell
dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis --version 7.0.5
```

Scrutor will help us during the implementation of the caching layer without taking the single responsibility away from the repository. And StackExchangeRedis is Microsoft's client package for using Redis with . NET.

Let's create a Service to handle everything related to Redis.
<br/>
Service:

```csharp
public class CacheService : ICacheService
{
    private readonly IDistributedCache _distributedCache;
    private readonly DistributedCacheEntryOptions _options;

    public CacheService(IDistributedCache distributedCache)
    {
        _distributedCache = distributedCache;
        _options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = 150
        };
    }

    public async Task<T> GetAsync<T>(string key)
    {
        try
        {
            var cached = await _distributedCache.GetStringAsync(key);
            if (cached is not null)
                return JsonConvert.DeserializeObject<T>(cached);
        }
        catch (Exception exception)
        { 
            // Log exception 
        }

        return default(T);
    }

    public async Task SetAsync<T>(string key, T value)
    {
        try
        {
            if (value is not null)
                await _distributedCache.SetStringAsync(key, JsonConvert.SerializeObject(value), _options);
        }
        catch (Exception exception)
        { 
            // Log exception
        }
    }

    public async Task RemoveAsync(string key)
    {
        try
        {
            await _distributedCache.RemoveAsync(key);
        }
        catch (Exception exception)
        {
            // Log exception
    	}
    }
}

```
Let's create a Repository to handle the query request to the database that will "intercept" and go first in Redis.
<br/>
Repository:

```csharp
public class CachedAlugatorRepository : IAlugatorRepository
{
    private readonly IAlugatorRepository _alugatorRepository;
    private readonly ICacheService _cache;

    public CachedAlugatorRepository(IAlugatorRepository alugatorRepository, ICacheService cache)
    {
        _alugatorRepository = alugatorRepository;
        _cache = cache;
    }

    public async Task<bool> DeleteAsync(string id)
    {
        var alugator = await _alugatorRepository.GetAsync(id);
        if (alugator is not null)
        {
 	    await _cache.RemoveAsync(alugator.documentId);
            return await _alugatorRepository.DeleteAsync(id);
        }

        return true;
    }

    public async Task<Alugator> GetAsync(string id)
    {
        var alugator = await _cache.GetAsync<Alugator>(id);
        if (alugator is not null)
            return alugator;

        alugator = await _alugatorRepository.GetAsync(id);

        await _cache.SetAsync<Alugator>(alugator);
        return alugator;
    }

    public async Task<bool> UpsertAsync(Alugator alugator)
    {
        await _cache.SetAsync(alugator.documentId, alugator);

        return await _alugatorRepository.UpsertAsync(alugator);
    }
}

```

The ace in the hole is in the way we are going to configure the Repository in the Program class:

```csharp
services.AddSingleton<IAlugatorRepository, AlugatorRepository>();
services.Decorate<IAlugatorRepository, CachedAlugatorRepository>();
```
This Decorate does the magic, because now when calling the AlugatorRepository the CachedAlugatorRepository will be "called" first, so every call to the repository will initially be made to the Cache Repository that contains the query logic to Redis through service. With that we keep the AlugatorRepository clean, we have a specific repository for the CachedAlugatorRepository cache and we don't hurt the Single Responsibility Principle.
