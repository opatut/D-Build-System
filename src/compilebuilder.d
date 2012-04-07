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

import std.file;
import std.stdio;
import std.datetime;
import std.string;
import std.process : shell, ErrnoException;

import settings;
import dependency;
import output;

bool isAnyFileNewer(string[] files, string[] referenceFiles) {
    std.datetime.SysTime newestReference = SysTime.min;

    // timeLastModified(source) >= timeLastModified(target, SysTime.min)

    foreach(r; referenceFiles) {
        if(timeLastModified(r, SysTime.min) > newestReference)
            newestReference = timeLastModified(r, SysTime.min);
    }
    foreach(f; files) {
        if(timeLastModified(f) > newestReference)
            return true;
    }
    return false;
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

class CompileBuilder {
    TargetType targetType;

    string[] linkNames;
    string[] linkPaths;
    string[] includePaths;

    string outputFile;
    string[] inputFiles;
    string extraFlags;

    this(string flags = "") {
        extraFlags = flags;
    }

    void addDependency(Dependency d) {
        foreach(dep; d.dependencies) {
            addDependency(dep,);
        }

        linkNames ~= d.linkNames;
        linkPaths ~= d.linkPaths;
        includePaths ~= d.includePaths;
    }

    @property string command() {
        string cmd = "";
        cmd ~= compilerCommand;
        cmd ~= typeArgument;
        cmd ~= " -of" ~ outputFile;
        if(Settings.CompilerFlags) cmd ~= " " ~ strip(Settings.CompilerFlags);
        if(extraFlags) cmd ~= " " ~ strip(extraFlags);
        cmd ~= includeFlags;
        cmd ~= linkFlags;
        cmd ~= inputFileNames;
        return cmd;
    }

private:
    @property string inputFileNames() {
        string files = "";
        foreach(f; inputFiles) {
            files ~= " " ~ f;
        }
        return files;
    }

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
        switch(targetType) {
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

