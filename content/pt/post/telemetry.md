---
title: "Um jeito fácil de medir a performance do seu método"
date: 2023-11-13T18:19:29-03:00
draft: false
tags: ["telemetry"]
---

E se você quiser medir o tempo de execução de um método? 
Existem várias razões para isso, seja para login, profiling, medição de desempenho geral ou rastreamento de degradação ao longo do tempo. A coleta dessas métricas é um aspecto crucial de qualquer aplicação em produção.

Existem diversos métodos para fazer isso, incluindo diferentes bibliotecas que agregam dados de telemetria. Embora ofereçam insights abrangentes, às vezes você pode preferir uma abordagem mais direta. Uma maneira de fazer isso é usando um bloco try e finally em conjunto com um cronômetro (stopwatch).

No entanto, essa abordagem, apesar de mais limpa, ainda exige a adição de código de medição nos métodos que você deseja testar.

Aqui está uma solução mais simples: a biblioteca MethodTimer.Fody. Uma vez instalada, tudo o que você precisa fazer é adicionar o atributo [Time] acima do método que deseja mensurar o desempenho. Execute seu código, verifique a saída de debug e pronto.

Para entender como isso funciona, você pode explorar o repositório da biblioteca [aqui](https://github.com/Fody/MethodTimer).

A mágica está em como nosso código se transforma, refletindo a abordagem inicial. O código sob teste:

```csharp
public class MyClass
{
    [Time]
    public void MyMethod()
    {
        // Algum código sobre o qual você está curioso em termos de tempo de execução
        Console.WriteLine("Olá");
    }
}
```

Após a compilação, fica assim:

```csharp
public class MyClass
{
    public void MyMethod()
    {
        var cronometro = Stopwatch.StartNew();
        try
        {
            // Algum código sobre o qual você está curioso em termos de tempo de execução
            Console.WriteLine("Olá");
        }
        finally
        {
            cronometro.Stop();
            Trace.WriteLine("MyClass.MyMethod " + cronometro.ElapsedMilliseconds + "ms");
        }
    }
}
```

Agora, você pode estar se perguntando: "O que posso fazer com essas informações, disponíveis apenas no debug console?" Aqui está uma sugestão: crie uma classe utilitária como a abaixo.

```csharp
using System.Reflection;

namespace JokerCharge
{
    public static class MethodTimeLogger
    {
        public static ILogger Logger;
        public static void Log(MethodBase methodBase, TimeSpan elapsed, string message)
        {
            Logger.LogTrace("{Classe}.{Método} {Duração}", methodBase.DeclaringType!.Name, methodBase.Name, elapsed);
        }
    }
}
```

Não se esqueça de adicionar isso à sua classe Program:

```csharp
var app = builder.Build();
MethodTimeLogger.Logger = app.Logger;
```

E atualize o appSettings para registrar no trace:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Trace",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

Com tudo configurado, você pode logar e injetar as informações que desejar.

![telemetry](/img/telemetry.png)
