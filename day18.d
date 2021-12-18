module day18;

import std.algorithm;
import std.array;
import std.container;
import std.conv;
import std.math;
import std.range;
import std.regex;
import std.stdio;
import std.string;
import std.typecons : Nullable;

void main() {
    SfNumber[] input = File("input/day18.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(i => read(i))
        .array();

    // pt 1
    writeln(magnitude(sum(input)));

    // pt 2
    int maxMag = 0;
    foreach (first; input) {
        foreach (second; input) {
            if (first == second) {
                continue;
            }
            int mag = magnitude(sum([first, second]));
            maxMag = max(mag, maxMag);
        }
    }
    writeln(maxMag);
}

struct SfNumber {
    int[] values;
    int[] nestings;
}

SfNumber read(string input) {
    int[] values;
    int[] nestings;

    uint nesting = -1;
    foreach (c; input) {
        switch (c) {
        case '[':
            nesting++;
            break;
        case ']':
            nesting--;
            break;
        case ',':
            break;
        default:
            values ~= [("" ~ [c]).to!int];
            nestings ~= [nesting];
            break;
        }
    }
    return SfNumber(values, nestings);
}

SfNumber explode(SfNumber sfNumber) {
    int[] values = sfNumber.values;
    int[] nestings = sfNumber.nestings;
    // find index of 1st repeated nesting (a pair)
    uint ri = -1;
    for(uint i = 0; i < nestings.length; i++) {
        if (nestings[i] >= 4 && nestings[i] == nestings[i + 1]) {
            ri = i;
            break;
        }
    }

    if (ri == -1) {
        // nothing to explode.
        return sfNumber;
    }

    if (ri > 0) {
        // add to the left.
        values[ri - 1] += values[ri];
    }
    if (ri + 2 < values.length) {
        // add to the right.
        values[ri + 2] += values[ri + 1];
    }

    // insert zero where pair used to be.
    return SfNumber(
        values[0 .. ri] ~ [0] ~ values[ri + 2 .. $],
        nestings[0 .. ri] ~ [nestings[ri] - 1] ~ nestings[ri + 2 .. $]);
}

SfNumber split(SfNumber sfNumber) {
    int[] values = sfNumber.values;
    int[] nestings = sfNumber.nestings;
    // find index of 1st >=10 number
    uint si = -1;
    for (uint i = 0; i < nestings.length; i++) {
        if (values[i] >= 10) {
            si = i;
            break;
        }
    }

    if (si == -1) {
        // nothing to split.
        return sfNumber;
    }

    int number = values[si];
    int left = floor(number / 2.0).to!int;
    int right = ceil(number / 2.0).to!int;
    int nesting = nestings[si] + 1;

    return SfNumber(
        values[0 .. si] ~ [left, right] ~ values[si + 1 .. $],
        nestings[0 .. si] ~ [nesting, nesting] ~ nestings[si + 1 .. $]
    );
}

SfNumber reduce(SfNumber sfNumber) {
    SfNumber current = sfNumber;
    while (true) {
        SfNumber next;

        next = explode(current);
        if (current != next) {
            // explosion happened. (try exploding again).
            current = next;
            continue;
        }

        next = split(current);
        if (current == next) {
            // split did not happen. (reduce concluded).
            break;
        }
        current = next;
    }
    return current;
}

SfNumber add(SfNumber a, SfNumber b) {
    return SfNumber(
        a.values ~ b.values,
        a.nestings.map!(c => c + 1).array ~ b.nestings.map!(c => c + 1).array
    );
}

SfNumber sum(SfNumber[] numbers) {
    SfNumber result = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
        result = reduce(add(result, numbers[i]));
    }
    return result;
}

int magnitude(SfNumber sfNumber) {
    int[] values = sfNumber.values;
    int[] nestings = sfNumber.nestings;

    while (values.length > 1) {
        // find index of 1st repeated nesting (a pair)
        uint ri = -1;
        for (uint i = 0; i < nestings.length; i++) {
            if (nestings[i] == nestings[i + 1]) {
                ri = i;
                break;
            }
        }

        if (ri == -1) {
            break;
        }

        int mag = (3 * values[ri]) + (2 * values[ri + 1]);
        int nesting = nestings[ri] - 1;

        values = values[0 .. ri] ~ mag ~ values[ri + 2 .. $];
        nestings = nestings[0 .. ri] ~ nesting ~ nestings[ri + 2 .. $];

    }

    return values[0];
}

//
// unit tests
//

unittest {
    // read
    assert(read("[1,2]") == SfNumber([1, 2], [0, 0]));
    assert(read("[[1,2],3]") == SfNumber([1, 2, 3], [1, 1, 0]));
    assert(read("[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]") ==
        SfNumber([9,3,8,0,9,6,3,7,4,9,3], [2, 3, 3, 3, 3, 2, 3, 3, 3, 3, 1]));
}

unittest {
    // explode
    assert(explode(read("[[[[[9,8],1],2],3],4]")) == read("[[[[0,9],2],3],4]"));
    assert(explode(read("[7,[6,[5,[4,[3,2]]]]]")) == read("[7,[6,[5,[7,0]]]]"));
    assert(explode(read("[[6,[5,[4,[3,2]]]],1]")) == read("[[6,[5,[7,0]]],3]"));
    assert(explode(read("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")) == read("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"));
    assert(explode(read("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")) == read("[[3,[2,[8,0]]],[9,[5,[7,0]]]]"));
}

unittest {
    // split
    assert(split(SfNumber([10, 1], [0, 0])) == read("[[5,5],1]"));
    assert(split(SfNumber([1, 11], [0, 0])) == read("[1,[5,6]]"));
}

unittest {
    // reduce
    assert(reduce(read("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")) == read("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"));
}

unittest {
    // add
    assert(add(read("[[[[4,3],4],4],[7,[[8,4],9]]]"), read("[1,1]")) == read("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"));
}

unittest {
    // sum
    assert(sum([
        read("[1,1]"),
        read("[2,2]"),
        read("[3,3]"),
        read("[4,4]")
        ]) == read("[[[[1,1],[2,2]],[3,3]],[4,4]]"));

    assert(sum([
        read("[1,1]"),
        read("[2,2]"),
        read("[3,3]"),
        read("[4,4]"),
        read("[5,5]")
        ]) == read("[[[[3,0],[5,3]],[4,4]],[5,5]]"));

    assert(sum([
        read("[1,1]"),
        read("[2,2]"),
        read("[3,3]"),
        read("[4,4]"),
        read("[5,5]"),
        read("[6,6]")
        ]) == read("[[[[5,0],[7,4]],[5,5]],[6,6]]"));
}

unittest {
    // magnitude
    assert(magnitude(read("[9,1]")) == 29);
    assert(magnitude(read("[1,9]")) == 21);
    assert(magnitude(read("[[9,1],[1,9]]")) == 129);
    assert(magnitude(read("[[1,2],[[3,4],5]]")) == 143);
    assert(magnitude(read("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")) == 1384);
    assert(magnitude(read("[[[[1,1],[2,2]],[3,3]],[4,4]]")) == 445);
    assert(magnitude(read("[[[[3,0],[5,3]],[4,4]],[5,5]]")) == 791);
    assert(magnitude(read("[[[[5,0],[7,4]],[5,5]],[6,6]]")) == 1137);
    assert(magnitude(read("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")) == 3488);
}
