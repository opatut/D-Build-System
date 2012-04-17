import dbs.all;

import std.stdio;

void main(string[] args) {
    Settings.getOpt(args);

    DTarget t = new DTarget("dbs");
    t.type = TargetType.StaticLibrary;
    t.createModulesFromDirectory("dbs/");
    t.build();
}