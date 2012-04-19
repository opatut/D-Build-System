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

module dbs.dmodule;

import std.file;
import std.string;
import std.array;
import std.path;
import std.regex;

import dbs.target;
import dbs.settings;
import dbs.compilebuilder;
import dbs.output;

/**
 * Builds a module from a D package into an object file.
 */
class DModule {
    DTarget target;
    string sourceFile;
    string objectFile;
    string includePath;

    /**
     * Constructor.
     *
     * Parameters:
     *   sourceFile = The path to the source file, relative to the the includePath.
     *   includePath = The path from which this module's source file can be included.
     *
     * Examples:
     *   File structure
     *     - /home/user/src/project/
     *     - /home/user/src/project/package_a/module_a.d
     *     - /home/user/src/project/package_a/module_b.d
     *
     *   sourceFile = `package_a/module_*.d`
     *   includePath = `/home/user/src/project` // or
     *   includePath = `./` // if DBS is run from within /home/user/src/project
     */
    this(string sourceFile, string includePath = "./") {
        if(!std.file.exists(sourceFile))
            throw new Exception("Source file `" ~ sourceFile ~ "` does not exist.");
        this.sourceFile = absolutePath(buildNormalizedPath(includePath, sourceFile));
        this.includePath = includePath;
        this.objectFile = sourceFile.replace("/", "_").replace(regex(".d$"), "") ~ ".o";
    }

    @property string objectFilePath() {
        return buildNormalizedPath(target.objectFileDirectory, objectFile);
    }

    bool requiresCompilation() {
        return target.forceCompilation ||
            getModificationDate(sourceFile) > getModificationDate(objectFilePath);
    }

    bool compile() {
        return runCommand(target.builder.singleObjectCommand(this));
    }
}
