import std.file;
import std.datetime;

import settings;
import dependency;

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

class CompileBuilder {
    TargetType targetType;

    string[] linkNames;
    string[] linkPaths;
    string[] includePaths;

    string outputFile;
    string[] inputFiles;

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

