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

module dbs.output;

import std.stdio;
import std.string;
import std.conv;

enum Color {
    None = -1,
    Black = 0,
    Red,
    Green,
    Yellow,
    Blue,
    Purple,
    Cyan,
    White
}

enum Style {
    Background = -1,
    Normal = 0,
    Bold = 1,
    Underline = 4,
    Blink = 5
}

string sWrap(string str, Color color, Style style = Style.Normal, Color background = Color.None, bool highIntensity = false) {
    return sStart(color, style, highIntensity)
        ~ (background != Color.None ? sStart(background, Style.Background, highIntensity) : "")
        ~ str
        ~ sEnd();
}

string sStart(Color color, Style style = Style.Normal, bool highIntensity = false) {
    version(Posix) {
        string s = to!string(
            30 +
            cast(int)color +
            (style == Style.Background ? 10 : 0 ) +
            (highIntensity ? 60 : 0) );

        if(style != Style.Background) {
            s = format("%s;%s", cast(int)style, s);
        }
        return format("\033[%sm", s);
    } else {
    return "";
    }
}

string sEnd() {
    version(Posix) {
        return "\033[0m";
    } else {
        return "";
    }
}