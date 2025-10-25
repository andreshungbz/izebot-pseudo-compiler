# izebot-pseudo-compiler

Program 2. A meta-language pseudo-compiler written in Xtend.

## Running the Program

### Eclipse IDE

Setting up Eclipse IDE with Xtend and getting the project up and running is more cumbersome, but the general steps are outlined below:

1. Install Eclipse IDE and install the Xtend plugin.
2. Clone this repository and open it as an Eclipse project.
3. Add the `Java` and `Xtend` natures to the project.
4. Set up a run configuration to execute `src/main/App.xtend` as a Java application.

### Docker

The `Dockerfile` provided will retrieve the following archives from the latest release or pre-release on this repository:

- `izebot-pseudo-compiler.zip` (contains the binary Java class files from Xtend compilation)
- `runtime.zip` (contains the Xtend runtime dependencies)

To run the program as a Docker container, use the following commands from the root directory of the repository:

```bash
docker build -t izebot-pseudo-compiler .
docker run -it --rm izebot-pseudo-compiler
```
