module day13;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.uni;

void main() {

    string[] input = File("input/day13.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        // .filter!(line => line.length > 0)
        .array();

    Dot[] dots;
    Fold[] folds;
    bool atDots = true;
    foreach (line; input) {
        if (line.length == 0) {
            atDots = false;
            continue;
        }

        if (atDots) {
            int[] pts = line.split(",").map!((c) => c.to!int).array;
            dots ~= [Dot(pts[0], pts[1])];
        } else /* lines */ {
            string[] pts = line.split(" ")[2].split("=");
            folds ~= [Fold(pts[0], pts[1].to!int)];
        }
    }

    bool first = true;
    foreach(fold; folds) {
        if (fold.orientation == "x") {
            for (int i = 0; i < dots.length; i++) {
                Dot dot = dots[i];
                if (dot.x > fold.position) {
                    dots[i].x = dot.x - (dot.x - fold.position) * 2;
                }
            }

        } else if (fold.orientation == "y") {
            for(int i = 0; i < dots.length; i++) {
                Dot dot = dots[i];
                if (dot.y > fold.position) {
                    dots[i].y = dot.y - (dot.y - fold.position) * 2;
                }
            }

        } else {
            throw new Exception("Invalid fold orientation");
        }

        if (first) {
            first = false;
            // pt 1
            writeln(dots.unique.length);
        }
    }

    // pt 2
    for (int y = 0; y < 7; y++) {
        for (int x = 0; x < 50; x++) {
            if (dots.contains(x, y)) {
                write("#");
            } else {
                write(".");
            }
        }
        write("\n");
    }
}

Dot[] unique(Dot[] dots) {
    Dot[string] uniqueDots;
    foreach (dot; dots) {
        uniqueDots[dot.toString] = dot;
    }
    return uniqueDots.values;
}

bool contains(Dot[] dots, int x, int y) {
    foreach(dot; dots) {
        if (dot.x == x && dot.y == y) {
            return true;
        }
    }
    return false;
}

struct Dot {
    int x;
    int y;

    string toString() const {
        return "[" ~ x.to!string ~ "," ~ y.to!string ~ "]";
    }
}

struct Fold {
    string orientation;
    int position;
}
