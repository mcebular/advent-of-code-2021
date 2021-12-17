module day17;

import std.algorithm;
import std.array;
import std.container;
import std.conv;
import std.math;
import std.range;
import std.regex;
import std.stdio;
import std.string;

void main() {

    // example input: target area: x=20..30, y=-10..-5
    // Vector2 from = Vector2(20, -10);
    // Vector2 to = Vector2(30, -5);

    // my input: target area: x=57..116, y=-198..-148
    Vector2 from = Vector2(57, -198);
    Vector2 to = Vector2(116, -148);

    int highestY = 0;
    uint count = 0;
    foreach (x; 0 .. 1000) {
        foreach (y; -1000 .. 1000) {
            Vector2[] path = fireProbe(from, to, x, y);
            if (path.length > 0) {
                count++;
                foreach (p; path) {
                    highestY = max(p.y, highestY);
                }
            }
        }
    }

    // pt 1
    writeln(highestY);
    // pt 2
    writeln(count);
}

Vector2[] fireProbe(Vector2 areaFrom, Vector2 areaTo, int vx, int vy) {
    Probe probe = Probe(vx, vy);

    Vector2[] path = [probe.position];
    uint step = 0;
    while (true) {
        // writeln("Step ", step, ", Probe ", probe);

        path ~= [probe.position];
        if (probe.position.isInArea(areaFrom, areaTo)) {
            // writeln("After ", step, " steps, probe is at position ", probe.position, ", which is inside area.");
            return path;
        }

        Probe nextProbe = probe.copy();
        nextProbe.position.x += nextProbe.velocity.x;
        nextProbe.position.y += nextProbe.velocity.y;

        if (nextProbe.velocity.x > 0) {
            nextProbe.velocity.x--;
        } else if (nextProbe.velocity.x < 0) {
            nextProbe.velocity.x++;
        }

        nextProbe.velocity.y--;

        if (nextProbe.position.y < areaFrom.y || nextProbe.position.x > areaTo.x) {
            // writeln("Probe missed the area!");
            return [];
        }

        probe = nextProbe;
        step++;
    }
}

public bool isInArea(Vector2 pos, Vector2 bottomLeft, Vector2 topRight) {
    bool inX = pos.x >= bottomLeft.x && pos.x <= topRight.x;
    bool inY = pos.y >= bottomLeft.y && pos.y <= topRight.y;
    return inX && inY;
}

struct Probe {
    Vector2 position;
    Vector2 velocity;

    this(int vx, int vy) {
        this.position = Vector2(0, 0);
        this.velocity = Vector2(vx, vy);
    }

    this(int px, int py, int vx, int vy) {
        this.position = Vector2(px, py);
        this.velocity = Vector2(vx, vy);
    }

    Probe copy() {
        return Probe(this.position.x, this.position.y, this.velocity.x, this.velocity.y);
    }
}

struct Vector2 {
    int x;
    int y;
}