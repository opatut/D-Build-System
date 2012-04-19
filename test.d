import dbs.all;

import std.stdio;

void main(string[] args) {
    Settings.getOpt(args);

    auto dbs = new DTarget("dbs", TargetType.StaticLibrary);
    dbs.createModulesFromDirectory("dbs/");
    dbs.build();

    auto test = new DTarget("test", TargetType.Executable);
    test.addModule("test.d");
    test.dependencies ~= dbs;
    test.build();
}