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

module dbs.target;

import std.algorithm;
import std.file;
import std.array;
import std.string;
import std.path;
import std.conv;
import std.stdio;
import std.math;
import std.regex;
import std.parallelism;

import dbs.dependency;
import dbs.settings;
import dbs.compilebuilder;
import dbs.output;
import dbs.dmodule;

/**
 * Builds a D package into a binary/library file.
 */
class DTarget : Dependency {
private:
    bool performedCompilation = false;

public:
    TargetType type;
    DModule[] modules;

    string objectFileDirectory;
    bool forceCompilation = false;

    CompileBuilder builder;
    string flags;

    this(string name, TargetType type = TargetType.Executable) {
        super(name);
        this.type = type;
        if(type != TargetType.Executable) {
            this.linkNames = [name];
            this.linkPaths = [Settings.LibraryPath];
        }
        this.builder = new CompileBuilder(this);
        this.objectFileDirectory = buildNormalizedPath(absolutePath(Settings.ObjectFilePath), name);
        this.forceCompilation = Settings.ForceTargets || Settings.ForceAll;
    }

    /**
     * Adds a module for each D source file in the directory and it's subdirectories.
     *
     * The directory is considered the root directory of a package, containing
     * modules and possibly subpackages. For each file inside this directory, take
     * the relative path from this directory's parent to the file, and use that as
     * the module path.
     *
     * Examples:
     *      For directory = "/home/user/src/dbs/" take "dbs/all.d" as the module file,
     *      and "/home/user/src/" as the module path.
     *
     * ToDo:
     *      Read "module ...;" statement from files and properly determine per-file include path.
     */
    void createModulesFromDirectory(string directory) {
        // better work with absolute paths
        directory = absolutePath(directory);

        // parent directory = include directory (assumption, see docstring)
        string includePath = buildNormalizedPath(directory, "..");

        // get all the files in the directory
        string[] files;
        foreach(string s; dirEntries(directory, SpanMode.breadth)) {
            if(extension(s) == ".d") {
                files ~= s;
            }
        }

        createModulesFromFileList(files, includePath);
    }

    /**
     * Adds a module for each file in the list.
     *
     * See addModule(string, string) for details on how relative file paths are treated.
     */
    void createModulesFromFileList(string[] files, string includePath = "") {
        includePath = absolutePath(includePath);

        foreach(f; files) {
            addModule(f, includePath);
        }
    }

    /**
     * Returns whether this target has to be built.
     */
    bool requiresBuilding() {
        return forceCompilation || (requiresCompilation() || requiresLinking());
    }

    /**
     * Compiles this target, if required, and (re-)links it, if required.
     *
     * Returns: true if successfully built, otherwise false.
     */
    bool performBuild() {
        writefln(sWrap(":: Building target %s", Color.White, Style.Bold), name);
        preBuild();
        if(requiresCompilation() && !compile())
            return false;
        if(requiresLinking() && !link())
            return false;
        return true;
    }

    /**
     * Prepares the build process.
     */
    void preBuild() {
        foreach(d; dependencies) {
            builder.addDependency(d);
        }
    }

    /**
     * Compiles all modules that require compilation.
     *
     * This method uses parallelism to build several modules in threads. The number of threads is determined
     * by Settings.Jobs.
     */
    bool compile() {
        DModule[] buildModules;

        foreach(m; modules) {
            if(m.requiresCompilation() || forceCompilation) {
                buildModules ~= m;
            }
        }

        // Settings.Jobs: 0 means <number of cores - 1>, -1 means <number of modules = one for each module = "infinite">
        TaskPool pool;
        if(Settings.Jobs == -1)  {
            pool = new TaskPool();
        } else if(Settings.Jobs < -1) {
            pool = new TaskPool(buildModules.length);
        } else {
            // writeln(Settings.Jobs, " workers");
            pool = new TaskPool(Settings.Jobs);
        }

        bool failure = false;
        foreach(i, mod; pool.parallel(buildModules)) {
            if(!failure) {
                writefln(sWrap(" [%3s%%] Building %s", Color.Green),
                    round(100.0 * (i + 1) / buildModules.length),
                    mod.sourceFile);

                if(!mod.compile()) {
                    writeln("That is bad!");
                    failure = true;
                }
            }
        }
        pool.finish();

        performedCompilation = buildModules.length > 0;
        return !failure;
    }

    /**
     * Links all object files into the target binary.
     */
    bool link() {
        writefln(sWrap("==> Linking %s", Color.Purple, Style.Bold), name);
        return runCommand(builder.linkObjectsCommand(modules));
    }

    /**
     * Returns whether any of the modules has to be compiled.
     */
    bool requiresCompilation() {
        foreach(m; modules) {
            if(m.requiresCompilation())
                return true;
        }
        return forceCompilation;
    }

    /**
     * Returns whether this target has to be (re-)linked.
     */
    bool requiresLinking() {
        if(performedCompilation)
            return true;

        // if any dependency is newer than the last build -> relink
        foreach(d; dependencies) {
            if(d.requiresBuilding()) {
                return true;
            }

            // if it is newer, relink
            // if(d.modificationDate > modificationDate)
            //    return true;
        }

        // if we have to / had to build any of the modules -> relink
        if(requiresCompilation()) {
            return true;
        }

        // if there is no target file
        if(!exists(outputFilePath)) {
            return true;
        }

        // if the target file is newer than any of the object files
        string[] objectFiles;
        foreach(m; modules) {
            objectFiles ~= m.objectFilePath;
        }
        if(isAnyFileNewer(objectFiles, [outputFilePath])) {
            return true;
        }

        return false;
    }

    /**
     * The path to the output binary file.
     */
    @property string outputFilePath() {
        switch(this.type) {
            case TargetType.Executable:
                return buildPath(Settings.ExecutablePath, format(BinaryFilenameFormat, this.name));
            case TargetType.SharedLibrary:
                return buildPath(Settings.LibraryPath, format(SharedLibraryFilenameFormat, this.name));
            case TargetType.StaticLibrary:
                return buildPath(Settings.LibraryPath, format(StaticLibraryFilenameFormat, this.name));
            default:
                assert(false, "Unknown target type.");
        }
    }

    /**
     * Adds a module to this target.
     */
    void addModule(DModule mod) {
        modules ~= mod;
        mod.target = this;
        if(!includePaths.canFind(mod.includePath))
            includePaths ~= mod.includePath;
    }

    /**
     * Adds a file as a module.
     *
     * Relative file paths will be tried to locate from the includePath. If no
     * file exists at that path, it will be searched for this file relative to the
     * current directory.
     */
    void addModule(string file, string includePath = "") {
        string originalFile = file;

        if(!isAbsolute(file)) {
            file = buildNormalizedPath(includePath, file);
            if(!exists(file)) {
                file = absolutePath(file);
                if(!exists(file)) {
                    throw new Exception(format("File `%s` not found in include Path `%s` or current directory.", originalFile, includePath));
                }
            }
        }

        // now, get the path relative to the include Path
        string rel = relativePath(file, includePath);
        addModule(new DModule(rel, includePath));
    }
}