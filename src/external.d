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

        if(Settings.ForceBuild || isAnyFileNewer(includePaths, linkPaths)) {
            string s = shell(command);
            writeln(s);
        } else {
            if(Settings.Verbose) writeln("Nothing to do.");
        }

    }

}


