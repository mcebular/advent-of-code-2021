module day10;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

void main() {

    string[] input = File("input/day10.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .array();
    // writeln(input);

    char[] illegals = [];
    string[] autocompletes = [];
    foreach(line; input) {
        // writeln(line);
        bool corrupted = false;
        char[] chars = [];
        foreach (c; line) {
            if (c.isOpeningBracket()) {
                chars ~= [c];
            } else if (c.isClosingBracket()) {
                char top = chars[$-1];
                chars = chars[0..$-1];
                char matchingTop = top.matchingBracket();
                if (matchingTop != c) {
                    // writeln("Expected " ~ matchingTop ~ ", but found " ~ c ~ " instead.");
                    illegals ~= [c];
                    corrupted = true;
                    break;
                }
            }
        }

        if (!corrupted) {
            // writeln(line, " is incomplete, chars were ", chars);
            autocompletes ~= [chars.retro.map!((c) => c.to!char.matchingBracket()).array().to!string];
        }
    }

    // pt 1
    writeln(illegals.map!((c) => c.to!char.corruptionScore).sum);

    // pt 2
    long[] scores = autocompletes.map!((l) {
        long score = 0;
        foreach (c; l) {
            score *= 5;
            score += c.to!char.autocompleteScore;
        }
        return score;
    }).array();
    writeln(scores.sort()[$ / 2]);

}

int autocompleteScore(char c) {
    switch (c) {
    case ')': return 1;
    case ']': return 2;
    case '}': return 3;
    case '>': return 4;
    default:
        throw new Exception("Character not a bracket: " ~ c);
    }
}

int corruptionScore(char c) {
    switch (c) {
    case ')': return 3;
    case ']': return 57;
    case '}': return 1197;
    case '>': return 25_137;
    default: throw new Exception("Character not a bracket: " ~ c);
    }
}

char isOpeningBracket(char c) {
    switch(c) {
    case '(': return true;
    case '[': return true;
    case '{': return true;
    case '<': return true;
    default: return false;
    }
}

char isClosingBracket(char c) {
    switch (c) {
    case ')': return true;
    case ']': return true;
    case '}': return true;
    case '>': return true;
    default: return false;
    }
}

char matchingBracket(char c) {
    switch (c) {
    case '(': return ')';
    case ')': return '(';
    case '[': return ']';
    case ']': return '[';
    case '{': return '}';
    case '}': return '{';
    case '<': return '>';
    case '>': return '<';
    default: throw new Exception("Character not a bracket: " ~ c);
    }
}