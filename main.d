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

/*
import std.stdio;
import std.getopt;
import std.file;

import dbs.all;

ConfigFile cfg;

bool isClass(Class, Obj)(Obj x) {
    return Class.classinfo == x.classinfo;
}

void printHelp() {
    writeln(sWrap("DBS - D Build System", Color.White, Style.Bold) );
    writeln(sWrap("Copyright (c) 2012 -- Written by Paul 'opatut' Bienkowski", Color.White, Style.Bold) );

    write("Usage:
  dbs [options] targets

  -h  --help                        Display this help
  -l  --list-targets                Lists the available targets from the configuration
  -v  --verbose                     Be verbose (more output information)
  -f  --force                       Force building every target
  -F  --force-all                   Force building every target and external
  -c  --config <config-file>        Uses the configuration file (default: DBuildFile)
  -L  --libdir <library-path>       Set the library output path (default: lib/)
  -B  --bindir <binary-path>        Set the binary output path (default: bin/)
  -C  --compiler {DMD|GDC|LDC}      Set the compiler (default: Dmd)
  -m  --compiler-flags              Sets additional compiler flags
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

    // get command-line config
    Settings.getOpt(args);
    // get rest of options
    try {
        getopt(args,
            std.getopt.config.bundling,
            std.getopt.config.caseSensitive,
            "h|help", &displayHelp,
            "l|list-targets", &displayList,
            "c|config", &configFile);
    } catch(Exception e) {
        writeln(sWrap("Error parsing arguments: ", Color.Red, Style.Bold) ~ e.msg);
        return 1;
    }

    string[] targetList = args[1..$];

    if(displayHelp) {
        printHelp();
        return 0;
    }

    try {
        cfg = new ConfigFile(configFile);
    } catch(FileException e) {
        writeln(sWrap("Error loading " ~ e.msg, Color.Red, Style.Bold));
        return 1;
    }

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

    if(!cfg.build(targetList))
        return 1;

    return 0;
}
*/

int main() { return 0; }
