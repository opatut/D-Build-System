import std.stdio;
import std.getopt;

import settings;
import target;
import dependency;
import external;
import configfile;

ConfigFile cfg;

bool isClass(Class, Obj)(Obj x) {
    return Class.classinfo == x.classinfo;
}

void printHelp() {
    write("DBS - D Build System
Copyright (c) 2012 -- Written by Paul 'opatut' Bienkowski
Usage:
  dbs [options] targets

  -h  --help                        Display this help
  -l  --list-targets                Lists the available targets from the configuration
  -v  --verbose                     Be verbose (more output information)
  -f  --force                       Force building every target and dependency
  -c  --config <config-file>        Uses the configuration file (default: DBuildFile)
  -L  --libdir <library-path>       Set the library output path (default: lib/)
  -B  --bindir <binary-path>        Set the binary output path (default: bin/)
  -C  --compiler {DMD|GDC|LDC}      Set the compiler (default: Dmd)
");
}

string list() {
    string result = "";
    foreach(d; cfg.loadedDependencies) {
        result ~= d.name ~ " ";
    }
    return result;
}

int main(string[] args) {
    bool displayHelp, displayList;
    string configFile = "DBuildFile";
    getopt(args,
        std.getopt.config.bundling,
        std.getopt.config.caseSensitive,
        "h|help", &displayHelp,
        "l|list-targets", &displayList,
        "v|verbose", &Settings.Verbose,
        "f|force", &Settings.ForceBuild,
        "c|config", &configFile,
        "L|libdir", &Settings.LibraryPath,
        "B|bindir", &Settings.ExecutablePath,
        "C|compiler", &Settings.SelectedCompiler);

    string[] targetList = args[1..$];

    if(displayHelp) {
        printHelp();
        return 0;
    }

    cfg = new ConfigFile(configFile);

    if(displayList) {
        writeln(list());
        return 0;
    }

    if(targetList.length == 0) {
        targetList = cfg.defaultTargets;
    }

    if(!targetList.length) {
        writefln("No target selected. Available targets:
  %s

You can define default targets in your DBuildFile
  default: target1 target2 ...

For usage information, use --help.", list());
        return 0;
    }

    cfg.build(targetList);

    return 0;
}
