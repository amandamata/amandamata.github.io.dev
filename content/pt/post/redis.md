---
title: "Implementando Cache com Redis no .NET"
date: 2023-04-25T07:42:55-03:00
tags: ["cache", "dotnet"]
draft: false
---

## Introdução

Recentemente, precisei implementar um cache em uma aplicação para evitar consultas desnecessárias ao banco de dados. Já trabalhei com Redis no passado, e percebi que a implementação de um cache com Redis pode ser bastante direta e eficaz quando feita corretamente.

## Redis vs Memcached

Redis é quase como um banco de dados NoSQL, mas se destaca como um cache devido ao seu modelo de armazenamento em chave-valor. A escolha entre Redis e Memcached depende do caso de uso e do volume de dados. Se você precisa armazenar informações de sessão, Memcached é uma boa escolha. No entanto, para consultas extensas envolvendo conjuntos de dados maiores, o Redis é mais adequado. Memcached usa a memória da aplicação para armazenar dados, enquanto o Redis é um cache distribuído, independente da memória da aplicação, permitindo escalonamento vertical conforme a demanda cresce.

Quando um cache é usado pela primeira vez, a informação necessária não estará disponível, exigindo uma consulta ao banco de dados. Solicitações subsequentes podem recuperar dados diretamente do cache, reduzindo significativamente os tempos de resposta em comparação com as consultas ao banco de dados.

![redis](/img/redis.png)

## Por Que Usar Cache?

1. **Reduzir o Tempo de Resposta**: Melhore a experiência do usuário final minimizando os tempos de espera para ações ou cliques.
2. **Aumentar a Disponibilidade**: Reduza recursos computacionais aproveitando dados em cache, permitindo que mais usuários acessem a aplicação simultaneamente.
3. **Reduzir Custos Computacionais**: Diminua os custos de serviços na nuvem reduzindo a necessidade de consultas frequentes ao banco de dados e recursos do servidor.
4. **Gerenciar Picos de Carga**: Gerencie picos de carga de forma eficaz distribuindo a carga de processamento ao longo do tempo.

## Cenário de Problema

Considere uma aplicação que consulta frequentemente as mesmas informações do banco de dados. Originalmente, a aplicação não foi projetada para lidar com tal crescimento, resultando em problemas de desempenho. Por exemplo, uma aplicação de aluguel de carros precisa verificar se a empresa (identificada por um documento) na solicitação de aluguel existe no banco de dados. Cada solicitação envolve a consulta repetida dessa informação.

## Implementação

Para implementar o cache, usaremos o padrão Decorator. Isso nos permite adicionar uma camada de cache sem aumentar a complexidade na camada de repositório, aderindo ao Princípio da Responsabilidade Única do SOLID.

### Passo 1: Instalar Pacotes Necessários

Instale o Scrutor para injeção de dependência e o Microsoft.Extensions.Caching.StackExchangeRedis para suporte ao Redis.
Para essa implementação vamos seguir um padrão chamado Decorator, com esse padrão é possível adicionar uma camada de cache sem adicionar complexidade a mais na camada de repositório, e vamos seguir o principio S do SOLID, [Single-responsibility principle](https://g.co/kgs/phLumf).

Vamos trabalhar com dotnet, e instalar os pacotes [Scrutor](https://www.nuget.org/packages/scrutor/) e [StackExchangeRedis](https://www.nuget.org/packages/Microsoft.Extensions.Caching.StackExchangeRedis/7.0.5)

```shell
dotnet add package Scrutor --version 4.2.2
```

```shell
dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis --version 7.0.5
```

O Scrutor vai nos auxiliar durante a implementação da camada de cache sem tirar a responsabilidade única do repositório. E o StackExchangeRedis é o pacote client da Microsoft para fazermos o uso do redis com .NET.

### Passo 2: Criar um Serviço de Cache
Vamos criar um serviço para lidar com tudo relacionado ao Redis.
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
### Passo 3: Criar um Repositório em Cache

Vamos criar um repositório para lidar com a solicitação de consulta ao banco de dados que "interceptará" e consultará primeiro o Redis.
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
### Passo 4: Configurar o Repositório na Classe Program
Use o método Decorate para garantir que o CachedAlugatorRepository seja chamado antes do repositório original.
```csharp
services.AddSingleton<IAlugatorRepository, AlugatorRepository>();
services.Decorate<IAlugatorRepository, CachedAlugatorRepository>();
```
Essa configuração garante que toda chamada ao repositório passe primeiro pelo CachedAlugatorRepository, mantendo o AlugatorRepository original limpo e mantendo a adesão ao Princípio da Responsabilidade Única.

## Conclusão

Implementar cache com Redis no .NET usando o padrão Decorator permite uma solução eficiente, escalável e de fácil manutenção. Reduzindo os tempos de resposta, aumentando a disponibilidade e diminuindo os custos computacionais, o cache melhora o desempenho geral e a experiência do usuário da aplicação.
