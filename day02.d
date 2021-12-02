module day02;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import std.string;

struct Instruction {
    string direction;
    int amount;
}

struct Position {
    int x;
    int y;
    int aim;
}

void main() {

    Instruction[] instructions = File("input/day02.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(function(string line) {
            string[] pts = line.split(" ");
            return Instruction(pts[0], pts[1].to!int);
        })
        .array();

    part1(instructions);
    part2(instructions);
}

void part1(Instruction[] instructions) {
    auto pos = Position();

    foreach (Instruction i; instructions) {
        switch(i.direction) {
        case "forward":
            pos.x += i.amount;
            break;
        case "down":
            pos.y += i.amount;
            break;
        case "up":
            pos.y -= i.amount;
            break;
        default:
            writeln("Unknown instruction: ", i.direction);
        }
    }

    writeln(pos.x * pos.y);
}

void part2(Instruction[] instructions) {
    auto pos = Position();

    foreach (Instruction i; instructions) {
        switch (i.direction) {
        case "forward":
            pos.x += i.amount;
            pos.y += pos.aim * i.amount;
            break;
        case "down":
            pos.aim += i.amount;
            break;
        case "up":
            pos.aim -= i.amount;
            break;
        default:
            writeln("Unknown instruction: ", i.direction);
        }
    }

    writeln(pos.x * pos.y);
}