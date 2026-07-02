# Copilot Instructions

## What this repo is
A minimal .NET 10 console app (`src/App`) that prints one random Dutch dad joke
per run. There is no solution file, no test project, and no CI workflow yet —
`src/App/App.csproj` is the only project.

## Build & run
```powershell
cd src\App
dotnet build      # build
dotnet run        # prints one random joke
```
There are no automated tests in this repo (no test project exists).

## Architecture
- `Program.cs` is top-level-statements style (no `Main` method, no classes).
- Jokes live in `src/App/jokes.json` (a flat JSON array of strings) and are
  compiled into the assembly as an **`EmbeddedResource`** (declared in
  `App.csproj`), not read from disk at runtime.
- At startup, `Program.cs` locates the embedded resource by matching the
  manifest resource name with `EndsWith("jokes.json")` rather than hardcoding
  `App.jokes.json`. Keep this lookup pattern if you rename the project or
  root namespace — a hardcoded name would break resource resolution.
- The joke array is deserialized with `System.Text.Json` (no third-party JSON
  dependency) and a joke is picked with `Random.Shared`.

## Conventions
- No external NuGet dependencies — prefer BCL APIs (`System.Text.Json`,
  `System.Reflection`) over adding packages.
- `jokes.json` must stay valid UTF-8 JSON; the app reads the embedded stream
  with `Encoding.UTF8` explicitly.
- If you regenerate `jokes.json` (e.g. by re-scraping), keep it as a plain
  `string[]` JSON array — no wrapping object — since `Program.cs` deserializes
  directly to `string[]`.

## Documentation
- Always use the `.github\skills\documentation-writer\` skill when writing or
  updating documentation for this repo.
- All generated documentation output must be placed in the `/docs` folder.
