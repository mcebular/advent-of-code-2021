module day05;

import std.algorithm;
import std.array;
import std.conv;
import std.regex;
import std.stdio;
import std.string;

struct Point {
    int x;
    int y;
}

struct Line {
    Point from;
    Point to;
}

alias Area = int[int][int];

void main() {

    static auto rgx = regex(r"^(\d+),(\d+) -> (\d+),(\d+)$");
    Line[] input = File("input/day05.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!((string line) {
            auto matches = matchAll(line, rgx).front;
            return Line(
                Point(
                    matches[1].to!int,
                    matches[2].to!int
                ),
                Point(
                    matches[3].to!int,
                    matches[4].to!int
                ),
            );
        })
        .array();

    // writeln(input);

    // pt 1
    calcOverlaps(input, false);
    // pt 2
    calcOverlaps(input, true);
}

void calcOverlaps(Line[] input, bool includeDiagonals) {
    Area area;
    input
        .filter!(l => includeDiagonals ? true : !l.isDiagonal)
        .each!((Line l) {
            l.pointsOnLine.each!((Point p) { area[p.x][p.y] += 1; });
        });
    // area.print();
    writeln(area.byValueFlat.filter!(i => i > 1).array().length);
}

void print(Area area) {
    for (int j = 0; j < 10; j++) {
        for (int i = 0; i < 10; i++) {
            if (i in area && j in area[i]) {
                write(area[i][j]);
            } else {
                write(".");
            }
        }
        writeln();
    }
}

auto byValueFlat(Area area) {
    return area.byValue.map!(v => v.byValue).joiner;
}

bool isDiagonal(Line line) {
    return line.from.x != line.to.x && line.from.y != line.to.y;
}

Point[] pointsOnLine(Line line) {
    Point fr = line.from;
    Point to = line.to;

    int start_x = min(line.from.x, line.to.x);
    int start_y = min(line.from.y, line.to.y);
    int end_x = max(line.from.x, line.to.x);
    int end_y = max(line.from.y, line.to.y);

    Point[] points;

    if (start_y == end_y) {
        // horizontal line
        foreach (int x; start_x .. end_x + 1) {
            points ~= [Point(x, start_y)];
        }
    } else if (start_x == end_x) {
        // vertical line
        foreach (int y; start_y .. end_y + 1) {
            points ~= [Point(start_x, y)];
        }
    } else {
        // diagonal line
        int curr_x = line.from.x;
        int curr_y = line.from.y;
        while(true) {
            points ~= [Point(curr_x, curr_y)];

            if (curr_x == line.to.x && curr_y == line.to.y) {
                break;
            }

            if (curr_x < line.to.x) {
                curr_x++;
            } else {
                curr_x--;
            }

            if (curr_y < line.to.y) {
                curr_y++;
            } else {
                curr_y--;
            }
        }
    }

    // writeln(points);
    return points;
}

unittest {
    assert(
        Line(Point(0, 0), Point(4, 0)).pointsOnLine ==
            [Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0), Point(4, 0)]
    );
    assert(
        Line(Point(0, 0), Point(0, 4)).pointsOnLine ==
            [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4)]
    );
    assert(
        Line(Point(2, 0), Point(5, 3)).pointsOnLine ==
            [Point(2, 0), Point(3, 1), Point(4, 2), Point(5, 3)]
    );
    assert(
        Line(Point(5, 3), Point(2, 0)).pointsOnLine ==
            [Point(5, 3), Point(4, 2), Point(3, 1), Point(2, 0)]
    );
}

unittest {
    assert(Line(Point(0, 0), Point(4, 0)).isDiagonal == false);
    assert(Line(Point(0, 0), Point(0, 4)).isDiagonal == false);
    assert(Line(Point(2, 0), Point(5, 3)).isDiagonal == true);
}
