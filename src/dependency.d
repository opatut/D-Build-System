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

import settings;

class Dependency {
    string name;
    bool prepared = false;
    string[] linkNames;     // -L-l
    string[] linkPaths;     // -L-L
    string[] includePaths;  // -I
    Dependency[] dependencies;

    this(string name, string[] linkNames = [], string[] linkPaths = [], string[] includePaths = [], Dependency[] dependencies = []) {
        this.name = name;
        this.linkNames = (linkNames.length > 0 ? linkNames : [name]);
        this.linkPaths = linkPaths;
        this.includePaths = includePaths;
        this.dependencies = dependencies;
    }

    /// prepares this dependency (e.g. if this is a target, build it)
    void prepare() {
        if(!prepared) {
            prepareDependencies();
            // if(Settings.Verbose) writefln(":: Preparing %s", name);
            _prepare();

            prepared = true;
        }
    }

    /// override this for custom preparation process
    void _prepare() {}

    /// prepares all dependencies of this dependency
    void prepareDependencies() {
        foreach(d; dependencies) {
            d.prepare();
        }
    }
}

