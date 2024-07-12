---
title: "An easy way to measure your method performance"
date: 2023-11-13T18:19:29-03:00
draft: false
tags: ["telemetry"]
---

#### Introduction
Measuring method execution time is essential for optimizing applications, whether for profiling, performance monitoring, or detecting degradation over time. Although there are many tools and libraries available for this purpose, we often seek straightforward and non-intrusive solutions.

#### The Solution: MethodTimer.Fody
One of the most efficient and cleanest ways to measure method performance in C# is by using the MethodTimer.Fody library. This tool automatically adds timers to the desired methods through a simple attribute, without modifying the existing code.

#### How it works
After installing the [MethodTimer](https://github.com/Fody/MethodTimer) library in your project, simply add the [Time] attribute above any method you want to monitor. See an example:

```csharp
public class MyClass
{
    [Time]
    public void MyMethod()
    {
        // Your code here
        Console.WriteLine("Hello");
    }
}
```

When you run your code, the library automatically injects the timing logic, and the debug output will show the method's execution time.

```csharp
public class MyClass
{
    public void MyMethod()
    {
        var stopwatch = Stopwatch.StartNew();
        try
        {
            // Your code here
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

Now, you might be wondering: "What can I do with this information, available only in the debug console?" Here's a suggestion: create a utility class like the one below.

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

Don't forget to add this to your Program class:

```csharp
var app = builder.Build();
MethodTimeLogger.Logger = app.Logger;
```

And update the appSettings to log in trace:

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

With everything configured, you can log and inject the information you want.


![telemetry](/img/telemetry.png)

####  Benefits
* Simplicity: No need to write additional timing code.
* Automation: Performance measurement is added at compile time, keeping your code clean.
* Ease of Use: Just add an attribute to the desired method.

#### Conclusion
MethodTimer.Fody is a powerful tool for developers looking for an efficient and uncomplicated way to measure the performance of their methods in C#. With easy integration and minimal impact on existing code, it is an excellent choice for any project.
