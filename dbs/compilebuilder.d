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

module dbs.compilebuilder;

import std.file;
import std.stdio;
import std.datetime;
import std.string;
import std.process : shell, ErrnoException;

import dbs.settings;
import dbs.target;
import dbs.dmodule;
import dbs.dependency;
import dbs.output;

SysTime getModificationDate(string file) {
    return timeLastModified(file, SysTime.min);
}

SysTime getModificationDate(string[] files) {
    std.datetime.SysTime mostRecentDate = SysTime.min;

    foreach(f; files) {
        SysTime modificationDate = getModificationDate(f);
        if(modificationDate > mostRecentDate) {
            mostRecentDate = modificationDate;
        }
    }

    return mostRecentDate;
}

bool isAnyFileNewer(string[] files, string[] referenceFiles) {
    return getModificationDate(files) > getModificationDate(referenceFiles);
}

bool runCommand(string cmd) {
    if(Settings.Verbose) {
        writefln(sWrap("$ %s", Color.Yellow), cmd);
    }

    try {
        string s = shell(cmd);
        write(s);
        return true;
    } catch(ErrnoException e) {
        if(Settings.Verbose) writeln(e);
        return false;
    }
}

/**
 * Splits a list of space-separated file names into an array. Spaces escaped with "\"
 * are not used to split the files.
 */
string[] splitFileList(string fileList) {
    return cast(string[]) std.regex.split(fileList, std.regex.regex("(?<!\\\\)\\s+"));
}

class CompileBuilder {
    DTarget target;

    string[] linkNames;
    string[] linkPaths;
    string[] includePaths;

    string outputFile;
    string[] inputFiles;

    this(DTarget target) {
        this.target = target;
    }

    void addDependency(Dependency d) {
        foreach(dep; d.dependencies) {
            addDependency(dep);
        }

        linkNames ~= d.linkNames;
        linkPaths ~= d.linkPaths;
        includePaths ~= d.includePaths;
    }

    string singleObjectCommand(DModule mod) {
        return format("%s -c %s %s %s -of%s %s",
            compilerCommand,
            Settings.CompilerFlags,
            target.flags,
            includeFlags,
            mod.objectFilePath,
            mod.sourceFile);
    }

    string linkObjectsCommand(DModule[] modules) {
        string objectFiles;
        foreach(m; modules) {
            objectFiles ~= m.objectFilePath ~ " ";
        }
        objectFiles = strip(objectFiles);

        return format("%s %s %s %s %s -of%s %s",
            compilerCommand,
            Settings.CompilerFlags,
            target.flags,
            linkFlags,
            typeArgument,
            target.outputFilePath,
            objectFiles);
    }

private:
    @property string includeFlags() {
        string flags = "";
        foreach(i; includePaths) {
            flags ~= " -I" ~ i;
        }
        return flags;
    }

    @property string linkFlags() {
        string flags = "";
        foreach(l; linkPaths) {
            if(l != "") flags ~= " -L-L" ~ l;
        }
        foreach(l; linkNames) {
            if(l != "") flags ~= " -L-l" ~ l;
        }
        return flags;
    }

    @property string typeArgument() {
        switch(target.type) {
            case TargetType.Executable: return "";
            case TargetType.StaticLibrary: return " -lib";
            case TargetType.SharedLibrary: return " -shared";
            default: assert(false, "Cannot compile external or system libraries.");
        }
    }

    @property string compilerCommand() {
        switch(Settings.SelectedCompiler) {
            case Compiler.DMD: return "dmd";
            case Compiler.GDC: return "gdc";
            case Compiler.LDC: return "ldc2";
            default: assert(false, "Unknown Compiler.");
        }
    }
}

