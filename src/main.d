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
  -c  --config <config-file>        Uses the configuration file (default: DBuildFile)
  -L  --libdir <library-path>       Set the library output path (default: lib/)
  -B  --bindir <binary-path>        Set the binary output path (default: bin/)
  -C  --compiler {DMD|GDC|LDC}      Set the compiler (default: Dmd)
");
}

void printList() {
    string[] ds;
    string[] ts;
    string[] es;

    foreach(d; cfg.loadedDependencies) {
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
        "c|config", &configFile,
        "L|libdir", &Settings.LibraryPath,
        "B|bindir", &Settings.ExecutablePath,
        "C|compiler", &Settings.SelectedCompiler);

    string[] targetList = args[1..$];

    if(displayHelp || (!displayList && !targetList.length)) {
        printHelp();
        return 0;
    }

    cfg = new ConfigFile(configFile);

    if(displayList) {
        printList();
        return 0;
    }

    writeln((cast(External)cfg.loadedDependencies["luad"]).command);

    cfg.build(targetList);

    return 0;
}
