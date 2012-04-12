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

/*txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
bakgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset
*/
