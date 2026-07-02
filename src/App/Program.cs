using System.Reflection;
using System.Text;
using System.Text.Json;

var assembly = Assembly.GetExecutingAssembly();
var resourceName = assembly
    .GetManifestResourceNames()
    .FirstOrDefault(name => name.EndsWith("jokes.json", StringComparison.OrdinalIgnoreCase));

if (resourceName is null)
{
    Console.WriteLine("No jokes found.");
    return;
}

using var stream = assembly.GetManifestResourceStream(resourceName);

if (stream is null)
{
    Console.WriteLine("No jokes found.");
    return;
}

using var reader = new StreamReader(stream, Encoding.UTF8);
var json = reader.ReadToEnd();
var jokes = JsonSerializer.Deserialize<string[]>(json);

if (jokes is not { Length: > 0 })
{
    Console.WriteLine("No jokes found.");
    return;
}

Console.WriteLine(jokes[Random.Shared.Next(jokes.Length)]);
