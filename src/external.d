import std.stdio;
import std.process : shell, ErrnoException;

import dependency;

class External : Dependency {
    string command;
    string includePath;
    string libPath;

    this(string name, string command, string[] linkNames = [], string[] linkPaths = [], string[] includePaths = [], Dependency[] dependencies = []) {
        this.command = command;
        super(name, linkNames, linkPaths, includePaths, dependencies);
    }

    void build() {
        writefln("Building external target %s.", name);
        writefln("$ %s", command);

        string s = shell(command);
        writeln(s);

        writeln();
    }

    @property string linkName() {
        return name;
    }
    @property string[] includePaths() {
        if(includePath != "") return [includePath];
        return [];
    }
    @property string[] linkPaths() {
        if(libPath != "") return [libPath];
        return [];
    }
}


