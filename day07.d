module day07;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

void main() {

    int[] crabs = File("input/day07.txt")
        .byLine().array()[0].split(",").map!(to!int).array();
    // writeln(crabs);

    // pt 1
    iota(0, maxElement(crabs))
        .map!((posZero) {
            return crabs
                .map!((int c) { return abs(c - posZero); })
                .sum;
        })
        .minElement
        .writeln;

    // pt 2
    iota(0, maxElement(crabs))
        .map!((posZero) {
            return crabs
                .map!((int c) {
                    int n = abs(c - posZero);
                    return (n * (n + 1)) / 2;
                })
                .sum;
        })
        .minElement
        .writeln;
}
