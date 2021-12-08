module day08;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

void main() {

    DisplayLine[] input = File("input/day08.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!((line) {
            auto parts = line.split(" | ");
            return DisplayLine(parts[0].split(" "), parts[1].split(" "));
        })
        .array();
    // writeln(input);

    // pt 1
    writeln(input
        .map!((line) =>
            line.output
                .filter!((i) =>
                    [2, 3, 4, 7].canFind(i.length)
                )
                .array()
                .length
            )
        .sum
    );

    // pt 2
    int sum = 0;
    foreach (DisplayLine line; input) {
        int[string] mappings;

        string one = line.digits.find!(d => d.length == 2).array()[0];
        // writeln("1: ", one);
        mappings[one.array().sort().to!string] = 1;

        string four = line.digits.filter!(d => d.length == 4).array()[0];
        // writeln("4: ", four);
        mappings[four.array().sort().to!string] = 4;

        string seven = line.digits.filter!(d => d.length == 3).array()[0];
        // writeln("7: ", seven);
        mappings[seven.array().sort().to!string] = 7;

        string eight = line.digits.filter!(d => d.length == 7).array()[0];
        // writeln("8: ", eight);
        mappings[eight.array().sort().to!string] = 8;

        string six = line.digits.filter!(d => d.length == 6 && !seven.all!(sd => d.canFind(sd))).array()[0];
        // writeln("6: ", six);
        mappings[six.array().sort().to!string] = 6;

        string nine = line.digits.filter!(d => d.length == 6 && four.all!(fd => d.canFind(fd))).array()[0];
        // writeln("9: ", nine);
        mappings[nine.array().sort().to!string] = 9;

        string zero = line.digits.filter!(d => d.length == 6 && d != six.to!string && d != nine.to!string).array()[0];
        // writeln("0: ", zero);
        mappings[zero.array().sort().to!string] = 0;

        string two = line.digits.filter!(d => d.length == 5 && !d.all!(fd => nine.canFind(fd))).array()[0];
        // writeln("2: ", two);
        mappings[two.array().sort().to!string] = 2;

        string five = line.digits.filter!(d =>
            d.length == 5 &&
            d.filter!(id => two.canFind(id)).array().length == 3
        ).array()[0];
        // writeln("5: ", five);
        mappings[five.array().sort().to!string] = 5;

        string three = line.digits.filter!(d =>
            d.length == 5 &&
            d.filter!(id => two.canFind(id)).array().length == 4
        ).array()[0];
        // writeln("3: ", three);
        mappings[three.array().sort().to!string] = 3;

        // writeln(line.output, mappings);
        int finalDigits = line.output
            .map!(o => mappings[o.array().sort().to!string])
            .map!(d => d.to!string)
            .join("")
            .to!int;
        // writeln(finalDigits);
        sum += finalDigits;
    }

    writeln(sum);
}

struct DisplayLine {
    string[] digits;
    string[] output;
}