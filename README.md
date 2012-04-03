# DBS - D Build System

## What is this?

This is a build system for the [D Programming Language](http://dlang.org). It is very simple and probably will never compete with the bigger ones, like [DSSS](www.dsource.org/projects/dsss). I just wrote it for fun and as a learning effort.

## License

DBS is free software: you can redistribute it and/or modify
it under the terms of the **GNU General Public License** as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

DBS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with DBS.  If not, see <http://www.gnu.org/licenses/>.

## Installation

Compile it with 

    dmd *.d -ofdbs

Then copy the executable `dbs` to your path or call it from your project root. 

## Usage

Configure the targets in `DBuildFile` (see [DBuildFile Format](#readme-dbuildfile)). Then call `dbs` from your project root. For more usage information, run `dbs --help`.

<a name="readme-dbuildfile" />
## DBuildFile Format

    # Comments look like this

    compiler: DMD
    libraryPath: "lib/"
    binaryPath: "bin/"
    default: derp

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

