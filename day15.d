module day15;

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

    uint[][] input = File("input/day15.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(line => line.map!(c => c.to!string.to!uint).array())
        .array();

    auto cavern = new Array2d!(uint)(input.join(), input[0].length);
    // cavern.print();

    auto bigCavern = new Array2d!(uint)(input[0].length * 5, input.length * 5);
    for (int y = 0; y < bigCavern.height; y++) {
        for (int x = 0; x < bigCavern.width; x++) {
            int mx = x / cavern.width;
            int my = y / cavern.height;
            int ox = x % cavern.width;
            int oy = y % cavern.height;
            bigCavern[x, y] = cavern[ox, oy] + mx + my;
            bigCavern[x, y] = ((bigCavern[x, y] - 1) % 9) + 1;
        }
    }
    // bigCavern.print();

    // pt 1
    writeln(lowestRiskLevel(cavern));
    // pt 2
    writeln(lowestRiskLevel(bigCavern));
}

int lowestRiskLevel(Array2d!(uint) cavern) {
    int[Position] risks;
    risks[Position(0, 0)] = 0;

    auto frontier = BinaryHeap!(Position[], (a, b) => risks[a] > risks[b])([], 0);
    frontier.insert(Position(0, 0));

    while (!frontier.empty()) {
        Position pos = frontier.front();
        frontier.removeFront();

        if (pos.x == cavern.width - 1 && pos.y == cavern.height - 1) {
            return risks[pos];
        }

        foreach (adj; pos.adjacent(cavern.width - 1, cavern.height - 1)) {
            int nextRisk = risks[pos] + cavern[adj.x, adj.y];
            if (!(adj in risks) || nextRisk < risks[adj]) {
                risks[adj] = nextRisk;
                frontier.insert(Position(adj.x, adj.y));
            }
        }
    }

    return 0;
}

class Array2d(T) {

    private T[] arr;
    private uint width;
    private uint height;

    public this(uint width, uint height) {
        this.arr = new T[width * height];
        this.width = width;
        this.height = height;
    }

    public this(T[] arr, uint width) {
        this.arr = arr;
        this.width = width;
        this.height = arr.length / width;
    }

    ref T opIndex(uint x, uint y) {
        return arr[x + y * width];
    }

    int opApply(int delegate(ref T) dg) {
        int result = 0;
        foreach (T item; arr) {
            if (dg(item)) {
                result = 1;
                break;
            }
        }
        return result;
    }

    public void print() {
        for (int i = 0; i < arr.length; i++) {
            auto a = arr[i];
            write(a);
            if (i % width == width - 1) {
                write("\n");
            }
        }
        write("\n");
    }

}

struct Position {
    uint x;
    uint y;

    Position[] adjacent(int boundX, int boundY) {
        Position[] adjs;
        if (this.x > 0)      adjs ~= [Position(this.x - 1, this.y)];
        if (this.x < boundX) adjs ~= [Position(this.x + 1, this.y)];
        if (this.y > 0)      adjs ~= [Position(this.x, this.y - 1)];
        if (this.y < boundY) adjs ~= [Position(this.x, this.y + 1)];
        return adjs;
    }
}