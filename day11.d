module day11;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

void main() {

    uint[][] input = File("input/day11.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(line => line.map!(c => c.to!string
                .to!uint).array())
        .array();
    auto octi = new Array2d!(Dumbo)(input.join().map!((i) { return new Dumbo(i); }).array(), input[0].length);
    // octi.print();

    int step = 0;
    uint totalFlashesCount = 0;
    while (true) {
        auto nextOcti = new Array2d!(Dumbo)(octi.arr.map!((d) { return new Dumbo(d); }).array(), octi.width);

        foreach (x; 0..nextOcti.width) {
            foreach (y; 0..nextOcti.height) {
                nextOcti[x, y].energy += 1;
            }
        }

        bool anyDumbosFlashed = true;
        while (anyDumbosFlashed == true) {
            anyDumbosFlashed = false;

            foreach (x; 0 .. nextOcti.width) {
                foreach (y; 0 .. nextOcti.height) {

                    Dumbo dumbo = nextOcti[x, y];
                    if (dumbo.energy >= 10 && dumbo.flashed == false) {
                        anyDumbosFlashed = true;
                        dumbo.flashed = true;
                        totalFlashesCount++;
                        dumbo.energy = 0;
                        foreach (adj; Position(x, y).adjacent(nextOcti.width - 1, nextOcti.height - 1)) {
                            Dumbo adjDumbo = nextOcti[adj.x, adj.y];
                            if (!adjDumbo.flashed) {
                                adjDumbo.energy += 1;
                            }
                        }
                    }

                }
            }
        }

        octi = nextOcti;
        step++;

        // pt 1
        if (step == 100) {
            writeln(totalFlashesCount, " flashes after ", step, " steps.");
        }

        // pt 2
        bool allFlashed = true;
        foreach(o; nextOcti) {
            if (o.flashed == false) {
                allFlashed = false;
                break;
            }
        }

        if (allFlashed) {
            writeln("All octopuses flash in step ", step, ".");
            break;
        }

        // writeln("After step ", step, ": ");
        // nextOcti.print();
    }



}

struct Position {
    uint x;
    uint y;

    public Position[] adjacent(int boundX, int boundY) {
        Position[] adjs;
        for (int i = -1; i < 2; i++) {
            for (int j = -1; j < 2; j++) {
                if (i == 0 && j == 0) {
                    continue;
                }
                int nx = this.x + i;
                int ny = this.y + j;
                if (nx >= 0 && nx <= boundX && ny >= 0 && ny <= boundY) {
                    adjs ~= [Position(nx, ny)];
                }
            }
        }
        return adjs;
    }
}

class Dumbo {

    private int energy;
    public bool flashed;

    public this(int energy) {
        this.energy = energy;
    }

    public this(Dumbo d) {
        this.energy = d.energy;
    }

    override string toString() const {
        // return energy.to!string ~ "" ~ (flashed ? "T" : "F") ~ " ";
        return energy == 0 ? "\x1b[1m" ~ energy.to!string ~ "\x1b[0m" : energy.to!string;
    }

}

class Array2d(T) {

    public T[] arr;
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