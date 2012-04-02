import std.stdio;
import std.getopt;

import settings;
import target;
import dependency;
import external;

int main(string[] args) {
    Dependency[string] deps;

    deps["luajit-5.1"] = new Dependency("luajit-5.1");
    deps["dl"] = new Dependency("dl");
    deps["curl"] = new Dependency("curl");

    deps["luad"] = new External("luad", "cd externals/LuaD; make", ["luad"], ["externals/LuaD/lib/"], ["externals/LuaD/"]);
    deps["orange"] = new External("orange", "cd externals/orange; make", ["orange"], ["externals/orange/lib/64/", "externals/orange/lib/32/"], ["externals/orange"]);
    deps["delerict"] = new External("delerict", "cd externals/Derelict3/build; rdmd derelict.d",
        ["DerelictAL", "DerelictFT", "DerelictGL3", "DerelictGLFW3", "DerelictIL", "DerelictUtil"],
        ["externals/Derelict3/lib/"], ["externals/Derelict3/import/"]);

    deps["derp"] = new Target("derp", "derp/", "", TargetType.StaticLibrary,
        [deps["luajit-5.1"], deps["dl"], deps["curl"], deps["luad"], deps["orange"], deps["delerict"]]);
    deps["derper"] = new Target("derper", "derper/", "", TargetType.Executable, [deps["derp"], deps["luad"]]);


    bool displayHelp, displayList;
    string configFile;
    getopt(args,
        std.getopt.config.bundling,
        "h|help", &displayHelp,
        "l|list-targets", &displayList,
        "c|config", &configFile,
        "L|libdir", &Settings.LibraryPath,
        "B|bindir", &Settings.ExecutablePath,
        "C|compiler", &Settings.SelectedCompiler);

    string[] targetList = args[1..$];
    if(displayHelp || (!displayList && !targetList.length)) {
        write("DBS - D Build System
Copyright (c) 2012 -- Written by Paul 'opatut' Bienkowski
Usage:
  dbs [options] targets

  -h  --help                            Display this help
  -l  --list-targets                    Lists the available targets from the configuration
  -c  --config <config-file>            Uses the configuration file (default: DBuildFile)
  -L  --libdir <library-path>           Set the library output path (default: lib/)
  -B  --bindir <binary-path>            Set the binary output path (default: bin/)
  -C  --compiler {Dmd|Gnu|Ldc|Ldc2}     Set the compiler (default: dmd)
");
        return 0;
    }

    bool isClass(Class, Obj)(Obj x) {
        return Class.classinfo == x.classinfo;
    }

    if(displayList) {
        string[] ds;
        string[] ts;
        string[] es;

        foreach(d; deps) {
            if(isClass!Dependency(d)) {
                ds ~= d.name;
            } else if(isClass!Target(d)) {
                ts ~= d.name;
            } else if(isClass!External(d)) {
                es ~= d.name;
            }
        }

        void writeList(string t, string[] list) {
            writeln(t ~ ":");
            write("   ");
            foreach(l; list) write(" " ~ l);
            writeln();
        }
        writeList("System Dependencies", ds);
        writeList("External Targets", es);
        writeList("Targets", ts);
        return 0;
    }


    foreach(t; targetList) {
        if(t in deps) {
            deps[t].prepare();
        } else {
            writefln("Cannot find target %s. Aborting.", t);
        }
        writeln();
    }

    return 0;
}
