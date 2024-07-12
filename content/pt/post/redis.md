---
title: "Implementando cache Redis com dotnet"
date: 2023-04-25T07:42:55-03:00
tags: ["cache", "dotnet"]
draft: false
---

Recentemente tive que implementar um cache em uma aplicação para evitar consultas desnecessárias ao banco de dados, e isso foi muito legal. Já trabalhei com Redis no passado, mas acho que fiz da maneira errada porque implementar um cache com Redis nunca foi tão legal.
<br/>

#### Redis x Mem cached
O Redis é quase como um banco noSql, mas ele é ainda melhor pois armazena os dados com chave e valor e com isso fica muito mais fácil de utilizar ele como um cache.
Mas o ponto principal nessa comparação é: depende, depende de como e quanto dado será utilizado nesse cache. Se for pouco dado como guardar informações de uma sessão, o MemCache faz sentido. Mas se estamos falando de muitas consultas com dados maiores, como os dados que armazenamos no banco, o Redis faz um melhor trabalho. Isso porque ao utilizar o MemCache estamos utilizando da memória da aplicação pra salvar aquelas informações, já o Redis é um cache distribuído, não tem relação nenhuma com a memória da aplicação e é possível utilizar mais de um Redis database escalando verticalmente esse serviço conforme a demanda cresce.

A primeira vez que for necessário usar o cache a informação não vai estar lá, então é necessário consultar no banco e salvar no cache, a segunda vez já não é necessário ir ao banco, pois a informação estará no cache. E isso faz com que a aplicação demore menos tempo para responder uma requisição, pois a ida ao banco demora muito mais que a ida ao redis.

![redis](/img/redis.png)

<br/>

#### Porque utilizar
- Reduzir o tempo de resposta
Melhorar a experiência do usuário final com a aplicação, fazendo ele esperar menos em cada clique ou ação.

- Elevar a disponibilidade
Uma vez que é preciso consumir menos recursos computacionais, porque já está no cache e devolvo mais rápido para o usuário final, é possível então ter mais usuários acessando simultaneamente a aplicação.

- Reduzir custos computacionais
Quando estamos falando de cloud, estamos reduzindo o consumo de lambdas e recursos onde a fatura mensal pode ser mais barata.

O custo de um cache é alto, portanto, tem que estar custando caro no server side pra fazer essa migração para o cache. Por exemplo, problemas com demora de resposta para o cliente final podem custar caro, o cliente final pode simplesmente desistir de utilizar a aplicação pela demora, e muitos outros problemas que essa demora pode gerar. Para reduzir tanto esse custo de perda de cliente quanto o custo de consulta ao banco, utiliza-se então o cache para resolver esses problemas.
<br/>
#### Problema
Suponhamos que existe uma aplicação que faz muitas idas ao banco, mas sempre consultando as mesmas informações, quando a aplicação foi desenvolvida os desenvolvedores não achavam que ela poderia crescer tanto, e não foi implementado um cache para evitar essas consultas ao banco. 
A aplicação é de aluguel de carro para empresas, e a consulta é simples, a cada requisição recebida no endpoint aluguél é necessário consultar se a empresa(cnpj) informada na solicitação de aluguel é a mesma que existe no banco.
Temos o cenário, vamos para a implementação.
<br/>
#### Implementação
Explicação  e problema apresentações, vamos a implementação!
Para essa implementação vamos seguir um padrão chamado Decorator, com esse padrão é possível adicionar uma camada de cache sem adicionar complexidade a mais na camada de repositório, e vamos seguir o principio S do SOLID, [Single-responsibility principle](https://g.co/kgs/phLumf).

Vamos trabalhar com dotnet, e instalar os pacotes [Scrutor](https://www.nuget.org/packages/scrutor/) e [StackExchangeRedis](https://www.nuget.org/packages/Microsoft.Extensions.Caching.StackExchangeRedis/7.0.5)

```shell
dotnet add package Scrutor --version 4.2.2
```

```shell
dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis --version 7.0.5
```

O Scrutor vai nos auxiliar durante a implementação da camada de cache sem tirar a responsabilidade única do repositório. E o StackExchangeRedis é o pacote client da Microsoft para fazermos o uso do redis com .NET.

Vamos criar uma Service para lidar com tudo referente ao Redis.
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
Vamos criar um Repository para lidar com a requisição de consulta ao banco que irá "interceptar" e ir primeiro no redis.
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

O pulo do gato está na forma como iremos configurar o Repository na classe Program:

```csharp
services.AddSingleton<IAlugatorRepository, AlugatorRepository>();
services.Decorate<IAlugatorRepository, CachedAlugatorRepository>();
```
Esse Decorate faz a mágica, pois, agora ao chamar a AlugatorRepository a CachedAlugatorRepository será "chamado" primeiro, então, toda chamada ao repositório será feita inicialmente para o Repositório de cache que contém a lógica da consulta ao Redis através da service. Com isso mantemos a AlugatorRepository limpa, temos uma repository específica para o cache CachedAlugatorRepository e não ferimos o Single Responsability Principle.










