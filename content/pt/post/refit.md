---
title: "Refit"
date: 2024-08-04T00:52:50-03:00
draft: false
tags: ["dotnet", "sdk", "refit"]
---
Recentemente eu pude testar uma ótima biblioteca C# que melhora muito o desenvolvimento de uma SDK.

Em experiências anteriores, desenvolver um projeto de SDK era algo realmente trabalhoso. Era necessário criar muitas classes e métodos para lidar com as requisições e respostas da API. Então, durante minhas pesquisas, encontrei o [Refit](https://github.com/reactiveui/refit).

Refit é uma biblioteca REST que ajuda muito durante o desenvolvimento de um SDK. Você só precisa criar as classes de contrato (se você já tiver em um projeto paralelo, é ainda mais fácil) e criar as interfaces para cada controller. Simples assim.

### Sem Refit x Com Refit

Sem Refit:
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

Com Refit:
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
1. Defina a Interface: Você começa definindo uma interface que representa sua API. Cada método na interface corresponde a um endpoint da API. Você usa atributos para especificar o método HTTP (por exemplo, GET, POST) e a rota.

2. Crie os Modelos de Dados: Defina os modelos de dados que representam as respostas JSON da API.

3. Gere a Implementação: O Refit gera a implementação da interface em tempo de execução. Você não precisa escrever nenhum código adicional para lidar com as requisições e respostas HTTP. Você cria uma instância do cliente da API usando RestService.For<T>().

4. Faça Chamadas à API: Agora você pode usar o cliente gerado para fazer chamadas à API. O Refit lida com a serialização e desserialização dos dados de requisição e resposta, tornando o código muito mais limpo e fácil de manter.

### Autorização
Simples assim:
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
Você pode encontrar mais exemplos de autorização no [repositório do projeto Refit](https://github.com/reactiveui/refit).

### Beneficios
* Simplicidade: O Refit abstrai o código boilerplate necessário para fazer requisições HTTP, permitindo que você se concentre em definir seus contratos de API.
* Manutenibilidade: Ao definir seus endpoints de API como interfaces, seu código se torna mais modular e fácil de manter.
* Segurança de Tipo: O Refit fornece verificação em tempo de compilação dos seus contratos de API, reduzindo a probabilidade de erros em tempo de execução.
* Integração: O Refit se integra perfeitamente com outras bibliotecas e frameworks .NET.
