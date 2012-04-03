/*
 *  This file is part of the D Build System by Paul Bienkowski ("DBS").
 *
 *  DBS is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  DBS is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with DBS.  If not, see <http://www.gnu.org/licenses/>.
 */

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
import output;

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

        if(Settings.ForceBuild || isAnyFileNewer(inputFiles, [outputFile])) {
            writefln(sWrap(":: Building %s target %s", Color.White, Style.Bold), type == TargetType.Executable ? "executable" : "library", name);
            if(Settings.Verbose) writefln(sWrap("$ %s", Color.Yellow), comp.command);
            string s = shell(comp.command);
            write(s);
        } else {
            writefln(sWrap("-> Nothing to do for target %s", Color.Yellow), name);
        }
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

