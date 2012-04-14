import dbs.all;

import std.stdio;

void main() {
    DModule mod = new DModule("dbs/all.d");
    
    DTarget t = new DTarget("dbs");
    t.type = TargetType.StaticLibrary;
    
    t.createModulesFromDirectory("dbs/");
    
    t.build();
}