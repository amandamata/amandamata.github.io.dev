---
title: "An easy way to measure your method performance"
date: 2023-11-13T18:19:29-03:00
draft: false
tags: ["telemetry"]
---

What if you wish to measure the execution time of a method? 
There are various reasons for this—be it for login, profiling, general performance measurement, or tracking degradation over time. The collection of such metrics is a crucial aspect of any production application.

Numerous methods exist for accomplishing this, including different libraries that aggregate telemetry data. While they offer comprehensive insights, sometimes you might prefer a more straightforward approach. One way to achieve this is by using a try and finally block in conjunction with a stopwatch.

However, this approach, despite being cleaner, still necessitates the addition of measurement code into the methods you wish to evaluate.

Here's a simpler solution: the MethodTimer.Fody library. Once installed, all you need to do is add the [Time] attribute above the method you want to assess for performance. Run your code, check the debug output, and voila—your measurements are right there.

To understand how it works, you can explore the library's repository [here](https://github.com/Fody/MethodTimer).

The magic lies in how our code transforms, mirroring the initial approach. The code under test:

```csharp
public class MyClass
{
    [Time]
    public void MyMethod()
    {
        // Some code you are curious about in terms of execution time
        Console.WriteLine("Hello");
    }
}
```

After compilation, it looks like this:

```csharp
public class MyClass
{
    public void MyMethod()
    {
        var stopwatch = Stopwatch.StartNew();
        try
        {
            // Some code you are curious about in terms of execution time
            Console.WriteLine("Hello");
        }
        finally
        {
            stopwatch.Stop();
            Trace.WriteLine("MyClass.MyMethod " + stopwatch.ElapsedMilliseconds + "ms");
        }
    }
}
```

Now, you might wonder, "What can I do with this information, available only in the debug console?" Here's a suggestion: create a utility class like the one below.

```csharp
using System.Reflection;

namespace JokerCharge
{
    public static class MethodTimeLogger
    {
        public static ILogger Logger;
        public static void Log(MethodBase methodBase, TimeSpan elapsed, string message)
        {
            Logger.LogTrace("{Class}.{Method} {Duration}", methodBase.DeclaringType!.Name, methodBase.Name, elapsed);
        }
    }
}
```

Don't forget to add this to your program class:

```csharp
var app = builder.Build();
MethodTimeLogger.Logger = app.Logger;
```

And update your app settings to log to trace:

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

With everything set up, you can log and inject whatever information you desire.

{{< imgAbs 
pathURL="img/telemetry.png" 
alt="Telemetry" 
class="some-class" 
style="some-style" >}}
