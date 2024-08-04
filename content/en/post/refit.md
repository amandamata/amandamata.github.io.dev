---
title: "Refit"
date: 2024-08-04T00:52:50-03:00
draft: false
tags: ["dotnet", "sdk", "refit"]
---

Recently, I had the opportunity to test a great C# library that significantly improves the development of an SDK.

In later experiences develop an sdk project was something really honorous, wee need to create a lot of classes and methods to handle with the api request and response. Then, during my researchs I found [Refit](https://github.com/reactiveui/refit).

Refit is an rest library that helps a lot during an sdk develpment, you just need to create the contract classes (if you already has in an side project is even easyer), and create the interfaces for each controller. Simple as that.

### Without Refit x With Refit

Without Refit:
```csharp
using System;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;

public class ApiClient
{
    private readonly HttpClient _httpClient;

    public ApiClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<User> GetUserAsync(int userId)
    {
        var response = await _httpClient.GetAsync($"https://api.example.com/users/{userId}");
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        return JsonConvert.DeserializeObject<User>(content);
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
}
```

With Refit:
```csharp
using System;
using System.Threading.Tasks;
using Refit;

public interface IApiClient
{
    [Get("/users/{userId}")]
    Task<User> GetUserAsync(int userId);
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
}

public class Program
{
    public static async Task Main(string[] args)
    {
        var apiClient = RestService.For<IApiClient>("https://api.example.com");
        var user = await apiClient.GetUserAsync(1);
        Console.WriteLine($"Name: {user.Name}, Email: {user.Email}");
    }
}
```

1. Define the Interface: You start by defining an interface that represents your API. Each method in the interface corresponds to an API endpoint. You use attributes to specify the HTTP method (e.g., GET, POST) and the route.

2. Create the Data Models: Define the data models that represent the JSON responses from the API.

3. Generate the Implementation: Refit generates the implementation of the interface at runtime. You don't need to write any additional code to handle the HTTP requests and responses. You create an instance of the API client using RestService.For<T>().

4. Make API Calls: You can now use the generated client to make API calls. Refit handles the serialization and deserialization of the request and response data, making the code much cleaner and easier to maintain.

### Authorization
Simple as that:
```csharp
using Refit;
using System.Threading.Tasks;

public interface IApiClient
{
    [Headers("Authorization: Bearer")]
    [Get("/users/{userId}")]
    Task<User> GetUserAsync(int userId);
}
```
You can find more examples of authorization in the [Refit repository](https://github.com/reactiveui/refit).

### Benefits
* Simplicity: Refit abstracts away the boilerplate code required for making HTTP requests, allowing you to focus on defining your API contracts.
* Maintainability: By defining your API endpoints as interfaces, your code becomes more modular and easier to maintain.
* Type Safety: Refit provides compile-time checking of your API contracts, reducing the likelihood of runtime errors.
* Integration: Refit integrates seamlessly with other .NET libraries and frameworks, making it a versatile choice for .NET developers.
