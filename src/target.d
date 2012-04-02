import std.file : dirEntries, SpanMode, isDir;
import std.array : endsWith;
import std.string : format, strip;
import std.path;
import std.conv;
import std.stdio;
import std.process : shell, ErrnoException;

import dependency;
import settings;
import compilebuilder;

/*****************************************************************
 * Builds a D package.
 */

class Target : Dependency {
    TargetType type;

    /** The files to include in this target.
     *
     * Can be either one of these:
     * - a directory with a trailing "/" (uses all *.d files in this directory
     *   and all recursive subdirectories), e.g. "path/to/sources/"
     * - a single filepath, e.g. "path/to/file.d"
     * - a list of filenames, e.g. "fileA.d fileB.d file\ with\ spaces.D"
     */
    string[] inputFiles;

    string outputFile;
    string documentRoot;

    void _prepare() {
        CompileBuilder comp = new CompileBuilder();
        comp.targetType = type;
        foreach(d; dependencies) {
            comp.addDependency(d);
        }
        comp.outputFile = outputFile;
        comp.inputFiles = inputFiles;

        writefln("Building %s target %s.", type == TargetType.Executable ? "executable" : "library", name);
        writefln("$ %s", comp.command);
        string s = shell(comp.command);
        writeln(s);
    }

    this(string name, string files = "", string documentRoot = "", TargetType type = TargetType.Executable, Dependency[] dependencies = []) {
        this.type = type;
        this.documentRoot = documentRoot;

        if(isDir(files)) {
            if(documentRoot == "")
                this.documentRoot = files;

            // directory
            if(name == "") {
                name = to!string(pathSplitter(files).back);
            }

            foreach(string s; dirEntries(files, SpanMode.breadth)) {
                if(extension(s) == ".d") {
                    inputFiles ~= s;
                }
            }

        } else {
            assert(documentRoot != "", "You have to specify a document root if the input is a list of files.");

            foreach(s; std.regex.split(files, std.regex.regex("(?<!\\)\\s+")))
                inputFiles ~= s;

            if(name == "") {
                name = baseName(inputFiles[0], ".d");
            }
        }

        if(type == TargetType.Executable) {
            outputFile = Settings.ExecutablePath ~ format(BinaryFilenameFormat, name);
        } else if(type == TargetType.StaticLibrary) {
            outputFile = Settings.LibraryPath ~ format(StaticLibraryFilenameFormat, name);
        } else if(type == TargetType.SharedLibrary) {
            outputFile = Settings.LibraryPath ~ format(SharedLibraryFilenameFormat, name);
        } else {
            assert(false, format("Illegal target type for BuildTarget %s.", name));
        }

        super(name, [name], [Settings.LibraryPath], [this.documentRoot], dependencies);
    }
}

