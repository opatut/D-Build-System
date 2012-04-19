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

module dbs.dependency;

import std.stdio;

import dbs.settings;

abstract class Dependency {
private:
    bool built = false;

public:
    string name;
    Dependency[] dependencies;
    string[] linkPaths;
    string[] linkNames;
    string[] includePaths;

    this(string name) {
        this.name = name;
    }

    bool build() {
        if(!built) {
            if(!buildDependencies()) {
                return false;
            }
            built = true;
            return performBuild();
        } else {
            return true;
        }
    }

    bool requiresBuilding();
    bool performBuild();

protected:
    bool buildDependencies() {
        foreach(d; dependencies) {
            if(!d.build()) {
                return false;
            }
        }
        return true;
    }
}

