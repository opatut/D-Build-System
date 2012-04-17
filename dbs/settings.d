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

module dbs.settings;

import std.stdio;
import std.getopt;
import std.parallelism;

import dbs.output;

/// Compilers available
enum Compiler {
    DMD,
    GDC,
    LDC
}

/// Target types
enum TargetType {
    Executable,
    SharedLibrary,
    StaticLibrary,
    External,
    SystemLibrary
}

/// OS specific string formats
version(Windows) {
    enum SharedLibraryFilenameFormat = "%s.lib";
    enum StaticLibraryFilenameFormat = "%s.lib";
    enum BinaryFilenameFormat = "%s.exe";
}
else version(Posix) {
    enum SharedLibraryFilenameFormat = "lib%s.so";
    enum StaticLibraryFilenameFormat = "lib%s.a";
    enum BinaryFilenameFormat = "%s";
} else {
    static assert(false, "Unknown operating system.");
}

/// List of settings, encapsulated in a struct.
struct Settings {
    /// -L|--lib
    /// Library output path
    static string LibraryPath = "lib/";

    /// -B|--bin
    /// Executable output path
    static string ExecutablePath = "bin/";

    /// Object file output path
    static string ObjectFilePath = "build/";

    /// -C|--compiler
    /// One of these: Dmd, Gnu, Ldc, Ldc2
    /// Compiler to use.
    static Compiler SelectedCompiler = Compiler.DMD;

    /// -v|--verbose
    /// Be verbose.
    static bool Verbose = false;

    /// -f|--force
    /// Force building every target (and every object) in the target list.
    static bool ForceTargets = false;

    /// -F|--force-all
    /// Force building every target and external that is depended on.
    static bool ForceAll = false;

    /// -m|--compiler-flags
    /// Extra flags to be passed to the compiler.
    static string CompilerFlags = "";

    /// -j|--jobs
    /// Number of worker jobs, 0 = NUMCORES, -1 = INFINITE
    static int Jobs = -1; // -1 means <number of cores - 1>, -2 means infinite

    static void getOpt(ref string[] args) {
        string compilerFlags;
        int jobs = 1;
        getopt(args,
            std.getopt.config.bundling,
            std.getopt.config.caseSensitive,
            std.getopt.config.passThrough,      // ignore unrecognized options
            "v|verbose", &Settings.Verbose,
            "f|force", &Settings.ForceTargets,
            "F|force-all", &Settings.ForceAll,
            "L|libdir", &Settings.LibraryPath,
            "B|bindir", &Settings.ExecutablePath,
            "C|compiler", &Settings.SelectedCompiler,
            "m|compiler-flags", &compilerFlags,
            "j|jobs", &jobs);

        if(Settings.Verbose) {
            if(jobs == 0) writefln(sWrap("Compiling in %s parallel jobs.", Color.Yellow), totalCPUs);
            if(jobs == -1) writeln(sWrap("Compiling in endless parallel jobs.", Color.Yellow));
        }
        Settings.Jobs = jobs - 1; // so if we had -j=1 this means 0 worker threads, 0 -> -1, -1 -> -2

        if(compilerFlags)
            Settings.CompilerFlags ~= compilerFlags ~ " ";
    }
}
