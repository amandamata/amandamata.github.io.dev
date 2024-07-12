---
title: "Um jeito fácil de medir a performance do seu método"
date: 2023-11-13T18:19:29-03:00
draft: false
tags: ["telemetry","dotnet"]
---

## Introdução

Medir o tempo de execução de métodos é essencial para otimizar aplicações, seja para profiling, monitoramento de performance ou detecção de degradações ao longo do tempo. Embora existam várias ferramentas e bibliotecas disponíveis para essa finalidade, muitas vezes procuramos soluções que sejam diretas e não intrusivas.

## A Solução: MethodTimer

Uma das maneiras mais eficientes e limpas de medir a performance de métodos em C# é utilizando a biblioteca MethodTimer.Fody. Essa ferramenta permite adicionar automaticamente cronômetros aos métodos desejados através de um simples atributo, sem a necessidade de modificar o código existente.

## Como funciona

Após instalar a biblioteca [MethodTimer](https://github.com/Fody/MethodTimer) no seu projeto, basta adicionar o atributo `[Time]` acima de qualquer método que você deseja monitorar. Veja um exemplo:

```csharp
public class MyClass
{
    [Time]
    public void MyMethod()
    {
        // Seu código aqui
        Console.WriteLine("Executando método monitorado.");
    }
}
```

Quando você executa seu código, a biblioteca automaticamente injeta a lógica de cronometragem, e a saída de debug mostrará o tempo de execução do método.

```csharp
public class MyClass
{
    public void MyMethod()
    {
        var cronometro = Stopwatch.StartNew();
        try
        {
            // Seu código aqui
            Console.WriteLine("Executando método monitorado.");
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

## Benefícios
* Simplicidade: Não é necessário escrever código adicional de cronometragem.
* Automatização: A medição de performance é adicionada em tempo de compilação, mantendo seu código limpo.
* Facilidade de Uso: Basta adicionar um atributo ao método desejado.

## Conclusão
MethodTimer.Fody é uma ferramenta poderosa para desenvolvedores que buscam uma maneira eficiente e descomplicada de medir a performance de seus métodos em C#. Com a facilidade de integração e o mínimo impacto no código existente, é uma excelente escolha para qualquer projeto.
