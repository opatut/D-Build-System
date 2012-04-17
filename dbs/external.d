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

module dbs.external;

import std.stdio;

import dbs.dependency;
import dbs.settings;
import dbs.compilebuilder;
import dbs.output;

class SystemDependency : Dependency {
    this(string name) {
        super(name);
        linkNames = [name];
    }

    bool requiresBuilding() {
        return false;
    }

    bool performBuild() {
        // this is already built, don't do anything
        return true;
    }
}

class External : Dependency {
    string command;

    this(string name, string command) {
        super(name);
        this.command = command;
    }

    bool requiresBuilding() {
        return true;
    }

    bool performBuild() {
        if(Settings.ForceBuildAll || isAnyFileNewer(includePaths, linkPaths)) {
            if(Settings.Verbose) {
                writefln(sWrap(":: Building external target %s", Color.White, Style.Bold), name);
            }
            return runCommand(command);
        } else {
            if(Settings.Verbose) writefln(sWrap("-> Nothing to do for target %s", Color.Yellow), name);
        }
        return true;

    }

}


