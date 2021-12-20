module day20;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

void main() {
    string[] input = File("input/day20.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .array();

    string enhancement = input[0];
    assert(enhancement.length == 512);
    input = input[1 .. $];

    auto image = new SparseArray2d!(char)('.');

    for (int j = 0; j < input.length; j++) {
        string line = input[j];
        for (int i = 0; i < line.length; i++) {
            image[i, j] = line[i];
        }
    }

    // image.print();

    uint steps = 1;
    while (steps <= 50) {
        // Notice! Due to how mask is composed, color of the next image is
        // "inverted". Thus the default char of image changes from dark to light
        // (or vice versa).
        auto nextImage = new SparseArray2d!(char)(steps % 2 == 0 ? '.' : '#');
        for (int j = image.min.y - 1; j <= image.max.y + 1; j++) {
            for (int i = image.min.x - 1; i <= image.max.x + 1; i++) {
                Position[] area = Position(i, j).adjacentArea();
                uint enhcPos = area.map!(p => image[p])
                    .map!(l => l == '#' ? '1' : '0')
                    .to!int(2);
                char enhcChar = enhancement[enhcPos];
                nextImage[i, j] = enhcChar;
            }
        }
        // nextImage.print();
        image = nextImage;

        if (steps == 2 || steps == 50) {
            int litCount = 0;
            foreach (pos, val; image) {
                if (val == '#') {
                    litCount++;
                }
            }
            writeln(litCount);
        }

        steps++;
    }
}

class SparseArray2d(T) {

    private T[Position] arr;

    private T noValue;

    Position min;
    Position max;

    this(T noValue) {
        this.noValue = noValue;
        this.min = Position(0, 0);
        this.max = Position(0, 0);
    }

    ref T opIndex(Position pos) {
        return pos in arr ? arr[pos] : noValue;
    }

    ref T opIndex(int x, int y) {
        return this[Position(x, y)];
    }

    void opIndexAssign(T value, Position pos) {
        min.x = std.algorithm.min(min.x, pos.x);
        max.x = std.algorithm.max(max.x, pos.x);
        min.y = std.algorithm.min(min.y, pos.y);
        max.y = std.algorithm.max(max.y, pos.y);
        arr[pos] = value;
    }

    void opIndexAssign(T value, int x, int y) {
        this[Position(x, y)] = value;
    }

    int opApply(int delegate(ref Position, ref T) dg) {
        int result = 0;
        foreach (Position key, T value; arr) {
            if (dg(key, value)) {
                result = 1;
                break;
            }
        }
        return result;
    }

    public void print() {
        for (int j = min.y; j <= max.y; j++) {
            for (int i = min.x; i <= max.x; i++) {
                T val = arr[Position(i, j)];
                write(val);
            }
            write("\n");
        }
        write("\n");
    }

}

struct Position {
    int x;
    int y;

    Position[] adjacentArea() {
        return [
            Position(x - 1, y - 1),
            Position(x    , y - 1),
            Position(x + 1, y - 1),
            Position(x - 1, y),
            Position(x    , y),
            Position(x + 1, y),
            Position(x - 1, y + 1),
            Position(x    , y + 1),
            Position(x + 1, y + 1),
        ];
    }
}