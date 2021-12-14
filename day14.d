module day14;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.regex;
import std.stdio;
import std.string;

void main() {

    static auto rgx = regex(r"^(\w\w) -> (\w)+$");

    string[] input = File("input/day14.txt")
        .byLine()
        .map!(to!string)
        .map!strip // .filter!(line => line.length > 0)
        .array();

    long[string] pairs;
    for (int i = 1; i < input[0].length; i++) {
        dchar first = input[0][i-1];
        dchar second = input[0][i];
        string pair = [first, second].to!string;
        pairs[pair]++;
    }

    Insertion[string] insertions;
    foreach (line; input[2..$]) {
        auto matches = matchAll(line, rgx).front;
        Insertion ins = Insertion(matches[1][0], matches[1][1], matches[2][0]);
        insertions[ins.pair()] = ins;
    }


    long[dchar] charCount;
    for (int step = 1; step <= 40; step++) {
        long[string] nextPairs;
        long[dchar] nextCharCount;
        nextCharCount[input[0][0]]++;

        foreach (pair; pairs.keys) {
            dchar first = pair[0];
            dchar second = pair[1];
            dchar middle = insertions[[first, second].to!string].middle;

            nextPairs[[first, middle].to!string] += pairs[pair];
            nextPairs[[middle, second].to!string] += pairs[pair];

            nextCharCount[middle] += pairs[pair];
            nextCharCount[second] += pairs[pair];
        }

        pairs = nextPairs;
        charCount = nextCharCount;

        if (step == 10 || step == 40) {
            writeln(step, ": ", charCount.values.maxElement - charCount.values.minElement);
        }
    }
}

struct Insertion {
    dchar first;
    dchar second;
    dchar middle;

    string pair() {
        return [first, second].to!string;
    }
}
