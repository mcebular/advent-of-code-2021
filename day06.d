module day06;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import std.string;

void main() {

    int[] fishes = File("input/day06.txt")
        .byLine().array()[0].split(",").map!(to!int).array();

    // writeln(fishes);

    long[long] fishCountPerDay;
    foreach (long i; 0..9) {
        fishCountPerDay[i] = 0;
    }
    foreach (long fish; fishes) {
        fishCountPerDay[fish] += 1;
    }

    int day = 0;
    while(day <= 256) {
        if (day == 80 || day == 256) {
            writeln("Day ", day, " has ", fishCountPerDay.values.sum, " fishes.");
        }

        long[long] newDayFishCount;
        for (long i = 8; i > 0; i--) {
            newDayFishCount[i - 1] = fishCountPerDay[i];
        }
        newDayFishCount[8] = fishCountPerDay[0];
        newDayFishCount[6] += fishCountPerDay[0];

        fishCountPerDay = newDayFishCount;
        day++;
    }
}
