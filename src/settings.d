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

module settings;

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

    /// -C|--compiler
    /// One of these: Dmd, Gnu, Ldc, Ldc2
    /// Compiler to use.
    static Compiler SelectedCompiler = Compiler.DMD;

    /// -v|--verbose
    /// Be verbose.
    static bool Verbose = false;

    /// -f|--force
    /// Force building every target in the target list.
    static bool ForceBuild = false;

    /// -F|--force-all
    /// Force building every target and external
    static bool ForceBuildAll = false;
}
