# test-gaw-release-workflow

A minimal .NET 10 console app that prints one random Dutch dad joke per run.

## Build & run

```powershell
cd src\App
dotnet build      # build
dotnet run        # prints one random joke
```

## Project structure

- `src/App/Program.cs` — top-level-statements entry point that picks a random joke.
- `src/App/jokes.json` — flat JSON array of jokes, embedded into the assembly as a resource.

No test project or CI workflow exists yet.
