module day09;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

class Array2d(T) {

    private T[] arr;
    private uint width;
    private uint height;

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

void main() {

    uint[][] input = File("input/day09.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(line => line.map!(c => c.to!string.to!uint).array())
        .array();
    auto arr = new Array2d!(uint)(input.join(), input[0].length);
    // arr.print();

    int[] lowPoints;
    for (int i = 0; i < arr.width; i++) {
        for (int j = 0; j < arr.height; j++) {
            Position pos = Position(i, j);
            bool lowPoint = true;
            foreach (adj; pos.adjacent(arr.width - 1, arr.height - 1)) {
                if (arr[pos.x, pos.y] >= arr[adj.x, adj.y]) {
                    lowPoint = false;
                    break;
                }
            }
            if (lowPoint) {
                lowPoints ~= [arr[pos.x, pos.y]];
            }
        }
    }

    // pt 1
    writeln(lowPoints.map!(i => i += 1).sum);

    uint[] basinSizes;
    for (int i = 0; i < arr.width; i++) {
        for (int j = 0; j < arr.height; j++) {
            if (arr[i, j] != 9) {
                // go in all directions and change numbers to 9 until border (a 9).
                Position[] frontier = [Position(i, j)];
                int basinSize = 0;
                while (frontier.length > 0) {
                    Position pos = frontier[$ - 1];
                    frontier = frontier[0..$-1];
                    if (arr[pos.x, pos.y] != 9) basinSize++;
                    arr[pos.x, pos.y] = 9;

                    foreach (adj; pos.adjacent(arr.width - 1, arr.height - 1)) {
                        if (arr[adj.x, adj.y] != 9) {
                            frontier ~= [adj];
                        }
                    }
                }
                basinSizes ~= [basinSize];
            }
        }
    }

    // pt 2
    uint[] bins = basinSizes.sort().retro().array()[0 .. 3];
    writeln(bins[0] * bins[1] * bins[2]);
}

