module day12;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.uni;

void main() {

    string[] input = File("input/day12.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .array();

    Cave[string] caves;

    foreach (connection; input) {
        string[] pts = connection.split("-");
        string cid1 = pts[0];
        string cid2 = pts[1];

        if (!(cid1 in caves)) {
            caves[cid1] = Cave(cid1);
        }

        if (!(cid2 in caves)) {
            caves[cid2] = Cave(cid2);
        }

        caves[cid1].connections[cid2] = caves[cid2];
        caves[cid2].connections[cid1] = caves[cid1];
    }

    part1(caves);
    part2(caves);
}

void part1(Cave[string] caves) {
    Path[] complete;
    Path[] frontier;
    frontier ~= [Path(["start"])];
    while (frontier.length > 0) {
        Path[] nextFrontier = [];

        foreach (Path path; frontier) {
            if (path.current() == "end") {
                complete ~= [path];
                continue;
            }
            foreach (Cave connection; caves[path.current()].connections) {
                if (path.contains(connection.id) && connection.isSmall()) {
                    continue;
                }
                nextFrontier ~= [Path(path.path ~ [connection.id])];
            }
        }

        frontier = nextFrontier;
    }

    writeln(complete.length);
}

void part2(Cave[string] caves) {
    Path[] complete;
    Path[] frontier;
    frontier ~= [Path(["start"])];
    while (frontier.length > 0) {
        Path[] nextFrontier = [];

        foreach (Path path; frontier) {
            if (path.current() == "end") {
                complete ~= [path];
                continue;
            }
            foreach (Cave connection; caves[path.current()].connections) {
                if (connection.id == "start") {
                    continue;
                }
                if (path.contains(connection.id) && connection.isSmall()) {
                    if (path.visitedSmallCaveTwice() == false) {
                        nextFrontier ~= [Path(path.path ~ [connection.id])];
                    } else {
                        continue;
                    }
                }
                nextFrontier ~= [Path(path.path ~ [connection.id])];
            }
        }

        frontier = nextFrontier;
    }

    // looks like paths in complete array are not unique...
    Path[string] completeDistinct;
    foreach(c; complete) {
        string key = c.to!string;
        if (!(key in completeDistinct)) {
            completeDistinct[key] = c;
        }
    }
    writeln(completeDistinct.length);
}

struct Cave {
    string id;
    Cave[string] connections;

    string toString() const {
        return id;
    }

    bool isSmall() {
        return isLower(id[0]);
    }
}

struct Path {
    string[] path;

    string current() {
        return path[$-1];
    }

    bool contains(string pid) {
        return path.canFind(pid);
    }

    bool visitedSmallCaveTwice() {
        for (int i = 0; i < path.length; i++) {
            for (int j = 0; j < path.length; j++) {
                if (i == j) continue;
                if (path[i][0].isLower() && path[i] == path[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    string toString() const {
        return path.join(",");
    }
}