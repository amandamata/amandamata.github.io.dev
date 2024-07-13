---
title: "Implementing Redis Caching with .NET"
date: 2023-04-25T07:42:55-03:00
tags: ["cache", "dotnet"]
draft: false
---

## Introduction
Recently, I had to implement a cache in an application to avoid unnecessary database queries. Having worked with Redis in the past, I realized that implementing a cache with Redis can be quite straightforward and effective when done correctly.

## Redis vs Memcached
Redis is almost like a NoSQL database but excels as a cache due to its key-value storage model. The choice between Redis and Memcached depends on the use case and data volume. If you need to store session information, Memcached is a good choice. However, for extensive queries involving larger data sets, Redis is more suitable. Memcached uses the application's memory to store data, while Redis is a distributed cache, independent of the application's memory, allowing it to scale vertically as demand grows.

When a cache is first used, the required information won't be available, necessitating a database query. Subsequent requests can retrieve data directly from the cache, significantly reducing response times compared to database queries.

![redis](/img/redis.png)

## Why Use Caching?
1. **Reduce Response Time**: Improve the end-user experience by minimizing wait times for actions or clicks.
2. **Increase Availability**: Reduce computational resources by leveraging cached data, allowing more users to access the application simultaneously.
3. **Reduce Computational Costs**: Lower cloud service costs by reducing the need for frequent database queries and server resources.
4. **Handle Load Peaks**: Manage load spikes effectively by distributing the processing load over time.

## Problem Scenario
Consider an application that frequently queries the same information from the database. Originally, the application was not designed to handle such growth, resulting in performance issues. For example, a car rental application needs to verify if the company (identified by a document) in the rental request exists in the database. Each request involves querying this information repeatedly.

## Implementation
To implement caching, we'll use the Decorator pattern. This allows us to add a cache layer without increasing complexity in the repository layer, adhering to the Single Responsibility Principle of SOLID.

### Step 1: Install Required Packages
Install Scrutor for dependency injection and Microsoft.Extensions.Caching.StackExchangeRedis for Redis support.

Let's work with dotnet, and install the packages [Scrutor](https://www.nuget.org/packages/scrutor/) and [StackExchangeRedis](https://www.nuget.org/packages/Microsoft.Extensions.Caching.StackExchangeRedis/7.0.5)

```shell
dotnet add package Scrutor --version 4.2.2
```

```shell
dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis --version 7.0.5
```

Scrutor will help us during the implementation of the caching layer without taking the single responsibility away from the repository. And StackExchangeRedis is Microsoft's client package for using Redis with . NET.

### Step 2: Create a Cache Service
Let's create a Service to handle everything related to Redis.
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
### Step 3: Create a Cached Repository
Let's create a Repository to handle the query request to the database that will "intercept" and go first in Redis.
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
### Step 4: Configure the Repository in Program Class
Use the Decorate method to ensure the CachedAlugatorRepository is called before the original repository.
```csharp
services.AddSingleton<IAlugatorRepository, AlugatorRepository>();
services.Decorate<IAlugatorRepository, CachedAlugatorRepository>();
```
This configuration ensures that every call to the repository will first go through the CachedAlugatorRepository, keeping the original AlugatorRepository clean and maintaining adherence to the Single Responsibility Principle.

### Conclusion
Implementing Redis caching with .NET using the Decorator pattern allows for an efficient, scalable, and maintainable solution. By reducing response times, increasing availability, and lowering computational costs, caching enhances the overall performance and user experience of the application.