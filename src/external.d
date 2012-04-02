import std.stdio;
import std.process : shell, ErrnoException;

import dependency;
import settings;
import compilebuilder;

class External : Dependency {
    string command;

    this(string name, string command, string[] linkNames = [], string[] linkPaths = [], string[] includePaths = [], Dependency[] dependencies = []) {
        this.command = command;
        super(name, linkNames, linkPaths, includePaths, dependencies);
    }

    void _prepare() {
        if(Settings.Verbose) {
            writefln("==== Building external target %s ====", name);
            writefln("$ %s", command);
        }

        if(isAnyFileNewer(includePaths, linkPaths)) {
            string s = shell(command);
            writeln(s);
        } else {
            if(Settings.Verbose) writeln("Nothing to do.");
        }

    }

}


