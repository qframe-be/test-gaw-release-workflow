# How-To Guides

Practical recipes for common tasks with the Dutch dad joke console app.

## How to build and run the app

**Goal:** Compile and run the app to print a random joke.

1. Open a terminal and navigate to the project folder:
   ```powershell
   cd src\App
   ```
2. Build the project:
   ```powershell
   dotnet build
   ```
3. Run the app:
   ```powershell
   dotnet run
   ```
   Each run prints one random Dutch dad joke to the console.

## How to add or edit jokes

**Goal:** Add a new joke or fix an existing one.

1. Open `src\App\jokes.json`.
2. The file is a flat JSON array of strings — no wrapping object:
   ```json
   [
     "Existing joke 1",
     "Existing joke 2",
     "Your new joke here"
   ]
   ```
3. Add your joke as a new string in the array (or edit an existing one). Keep the file valid UTF-8 JSON, since the app reads it explicitly as UTF-8.
4. Save the file and rebuild:
   ```powershell
   dotnet build
   ```
   `jokes.json` is compiled into the assembly as an embedded resource (see `App.csproj`), so changes only take effect after a rebuild — not just by editing the file.
5. Run `dotnet run` a few times to confirm your joke appears.

## How to publish a standalone executable

**Goal:** Produce a distributable build of the app that doesn't require running `dotnet run` from source.

1. From `src\App`, publish the project:
   ```powershell
   dotnet publish -c Release -o .\publish
   ```
2. The compiled output, including the embedded `jokes.json`, will be in `.\publish`.
3. Run the published executable directly:
   ```powershell
   .\publish\App.exe
   ```

## How to safely rename the project or root namespace

**Goal:** Rename the project (e.g., `App` → `MyJokes`) without breaking joke loading at runtime.

1. Rename the project file, folder, and/or root namespace as needed.
2. Do **not** hardcode the embedded resource name (e.g., `App.jokes.json`) anywhere in code.
3. Confirm `Program.cs` still locates the resource by suffix match:
   ```csharp
   .FirstOrDefault(name => name.EndsWith("jokes.json", StringComparison.OrdinalIgnoreCase));
   ```
   This lookup is resilient to namespace/assembly name changes — keep this pattern intact.
4. Rebuild and run to verify jokes still load:
   ```powershell
   dotnet build
   dotnet run
   ```

## How to troubleshoot "No jokes found"

**Goal:** Diagnose why the app prints `No jokes found.` instead of a joke.

This message appears in three cases — check them in order:

1. **Embedded resource missing.** Confirm `App.csproj` still contains:
   ```xml
   <ItemGroup>
     <EmbeddedResource Include="jokes.json" />
   </ItemGroup>
   ```
   If this was removed, the resource lookup by name suffix will fail.
2. **Stale build.** If you edited `jokes.json` but didn't rebuild, the old embedded copy is still in use. Run `dotnet build` again.
3. **Empty or invalid array.** Open `jokes.json` and confirm it's valid JSON and contains at least one string. An empty array (`[]`) or malformed JSON will also trigger this message.
