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
            if(Settings.Verbose) writefln(":: Preparing %s", name);
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

