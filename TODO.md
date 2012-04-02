# ToDo

- Error Handling, nice outputs

# Classes

## Dependency

- provides linkNames
- provides linkPaths
- provides includePaths
- has more dependencies
- can be prepared (prepares sub-dependencies)


## Target : Dependency

- can read files from a directory
- builds a list of D files into **one** binary (`Executable` or `SharedLibrary` or `StaticLibrary`)
  - provides `[name]` as `linkNames`
  - provides `[Settings.LibraryPath]` as `linkPaths`
  - provides `[documentRoot]` as `includePaths`

## External : Target

- runs a build command
- usually no dependencies

## SystemDependency

Is not required anymore, use Dependency with absolute paths.

# DBuildFile Format

    # Comment like this

    compiler: DMD
    libraryPath: "lib/"
    binaryPath: "bin/"

    Dependency {
        name: sfml

        # optional, if not provided, uses only `name`
        libraries: sfml-audio sfml-graphics sfml-network sfml-system sfml-window
    }

    External {
        name: delerict
        command: cd externals/Derelict3/build; rdmd derelict.d

        # optional, see `Dependency`
        libraries: DerelictAL DerelictFT DerelictGL3 DerelictGLFW3 DerelictIL DerelictUtil

        # can be space-seperated list
        libraryPath: externals/Derelict3/lib/

        # can be space-seperated list
        includePath: externals/Derelict3/import/
    }

    Target {
        name: derp

        # can be a directory or a list of files
        files: derp/

        # automatically generated from `files` if not provided and `files`
        # is a directory
        documentRoot: derp/

        # StaticLibrary|SharedLibrary|Executable
        type: StaticLibrary

        # If not found, a system library is assumed (a dependency object
        # will automatically be created)
        depends: luajit-5.1 dl curl luad orange delerict
    }
