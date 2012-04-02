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
}
