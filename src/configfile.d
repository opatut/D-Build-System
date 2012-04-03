import std.file;
import std.stdio;
import std.regex;
import std.algorithm;
import std.string;
import std.traits;
import std.conv;

import dependency, target, external, settings;

int[2] findNext(string source, string open, string close) {
    int nextOpen = cast(int)countUntil(source, open);
    int nextClose = cast(int)countUntil(source, close);
    if (nextOpen != -1 && nextOpen < nextClose) return [1, nextOpen];
    else return [-1, nextClose];
}

int[2] findSection(string source, string open = "{", string close = "}") {
    string s = source;

    // cut away everything until first open sequence
    auto spl = findSplitAfter( s, open );
    int begin = cast(int)spl[0].length;
    s = spl[1];
    assert(s != source, "Could not find opening sequence.");

    // source contains no more opening sequence
    int levels = 1;

    while(levels > 0 && s.length > 0) {
        auto next = findNext(s, open, close);
        levels += next[0];
        s = s[next[1] + 1 .. $];
        if(next[1] == -1) break; // could not find any more pattern
    }

    int end = cast(int)(source.length - s.length - close.length);

    assert(end > begin, "Could not find matching close pattern.");

    return [begin, end];
}

string firstLine(ref string text) {
    string line = splitLines(text)[0];
    text = text[line.length + 1 .. $];
    return line;
}

static auto matchSection = regex("^([A-Za-z_][A-Za-z0-9_]*)\\s*\\{$");
static auto matchAssign = regex("^(.+)\\s*:\\s*(.*)$");
static auto stringListSplitPattern = regex("(?<!\\\\)\\s+");

class ParseStruct {
    ParseStruct[] children;
    string[string] values;
    string name;

    this(string name, string c) {
        this.name = name;

        while(c != "") {
            string oldC = c;
            string line = firstLine(c);

            // first, let's remove the comments
            auto cmt = findSplitBefore(line, "#");
            line = cmt[0]; // first group is code, rest is comment

            // strip whitespaces
            line = strip(line);
            if(line == "") continue; // empty line

            // see if this is an assign line
            auto as = match(line, matchAssign);
            if(as) {
                values[as.captures[1]] = as.captures[2];
                continue;
            }

            // see if a section starts here
            auto se = match(line, matchSection);
            if(se || strip(c)[0] == '{' ) {
                string sectionName = (as
                    ? strip(as.captures[1])
                    : strip(line[0.. $ - "{".length]) );

                auto sectionBounds = findSection(oldC);

                // parse content inside section
                string section = oldC[sectionBounds[0] .. sectionBounds[1]];
                children ~= new ParseStruct(sectionName, section);

                // continue after section
                c = oldC[sectionBounds[1] + "}".length .. $];
                continue;
            }

            writefln("Cannot parse line: %s", line);
        }
    }

    bool to(T)(string key, ref T target) {
        if(key in values) {
            target = values[key];
            return true;
        }
        return false;
    }

    void require(string[] required) {
        foreach(k; required) {
            assert(k in values, format("Key `%s` required in section `%s`.", name, k));
        }
    }
}

T stringToEnum(T)(string key, bool caseSensitive = false) {
    if(!caseSensitive) key = toLower(key);
    foreach(v, e; EnumMembers!T) {
        string type = to!string(e);
        if(!caseSensitive) type = toLower(type);
        if(type == key) return e;
    }

    assert(0, "No entry for " ~ key ~ " in " ~ T.stringof);
}

string[] splitStringList(string input) {
    string[] list = std.regex.split(strip(input), stringListSplitPattern);
    foreach(ref l; list) {
        if(canFind(l, "\\ ")) {
            l = std.array.replace(l, "\\ ", " ");
        }
    }
    return list;
}

class ConfigFile {
    string[string] dependencyStrings;
    Dependency[string] loadedDependencies;

    string[] defaultTargets;

    this(string filename) {
        string c = cast(string) read(filename);
        auto r = new ParseStruct("", c);

        string compiler = "";
        if(r.to("compiler", compiler))
            Settings.SelectedCompiler = stringToEnum!Compiler(compiler);
        r.to("libraryPath", Settings.LibraryPath);
        r.to("binaryPath", Settings.ExecutablePath);

        string def;
        if(r.to("default", def))
            defaultTargets = splitStringList(def);

        foreach(child; r.children) {
            if(child.name == "Target") readTarget(child);
            else if(child.name == "External") readExternal(child);
            else if(child.name == "Dependency") readDependency(child);
            else assert(0, format("Illegal section type `%s`.", child.name));
        }

        // fix dependencies
        foreach(loadedKey; loadedDependencies.keys) {
            Dependency loaded = loadedDependencies[loadedKey];
            if(loadedKey in dependencyStrings) {
                string[] deps = splitStringList(dependencyStrings[loadedKey]);
                foreach(d; deps) {
                    if(d in loadedDependencies)
                        loaded.dependencies ~= loadedDependencies[d];
                    else
                        assert(0, format("Cannot find dependency `%s` for `%s`.", d, loadedKey));
                }
            }
        }
    }

    void readDependency(ParseStruct r) {
        assert(r.children.length == 0, "`Dependency` section may not have children.");

        r.require(["name"]);

        string libraries;
        r.to("libraries", libraries);

        Dependency d = new Dependency(
            r.values["name"],
            splitStringList(libraries)
            );

        insertDependency(d, r);
    }

    void readExternal(ParseStruct r) {
        assert(r.children.length == 0, "`External` section may not have children.");

        r.require(["name", "command"]);

        // string name, string command, string[] linkNames = [], string[] linkPaths = [], string[] includePaths = [], Dependency[] dependencies = []
        string libraries;
        r.to("libraries", libraries);

        string libraryPaths;
        r.to("libraryPaths", libraryPaths);

        string includePaths;
        r.to("includePaths", includePaths);

        External e = new External(
            r.values["name"],
            r.values["command"],
            splitStringList(libraries),
            splitStringList(libraryPaths),
            splitStringList(includePaths)
            );

        insertDependency(e, r);
    }

    void readTarget(ParseStruct r) {
        assert(r.children.length == 0, "`Target` section may not have children.");

        r.require(["name", "files", "type"]);

        string documentRoot;
        r.to("documentRoot", documentRoot);

        Target t = new Target(
            r.values["name"],
            r.values["files"],
            documentRoot,
            stringToEnum!TargetType(r.values["type"]));

        insertDependency(t, r);
    }

    void insertDependency(Dependency d, ParseStruct r) {
        r.require(["name"]);
        loadedDependencies[r.values["name"]] = d;
        string dependencyString;
        r.to("depends", dependencyString);
        dependencyStrings[d.name] = dependencyString;
    }

    bool build(string[] targetList) {
        foreach(target; targetList) {
            if(target in loadedDependencies) {
                loadedDependencies[target].prepare();
            } else {
                writefln("Cannot find target %s. Aborting.", target);
                return false;
            }
        }
        return true;
    }
}
