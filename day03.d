module day03;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import std.string;

void main() {

    string[] report = File("input/day03.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .array();

    // pt 1
    power_consumption(report);

    // pt 2
    auto oxy = oxygen_rating(report);
    auto co2 = co2_rating(report);
    writeln(oxy.to!int(2) * co2.to!int(2));
}

struct BinCount {
    int ones;
    int zeros;
}

BinCount count_ones_zeros(string[] report, int position) {
    BinCount result = BinCount();
    foreach (string line; report) {
        if (line[position] == '1') {
            result.ones++;
        } else {
            result.zeros++;
        }
    }

    return result;
}

string oxygen_rating(string[] report) {
    return report_rating(report, (string[] report, int position) {
        BinCount c = count_ones_zeros(report, position);
        if (c.ones >= c.zeros) {
            report = report.filter!(r => r[position] == '1').array();
        } else {
            report = report.filter!(r => r[position] == '0').array();
        }
        return report;
    });
}

string co2_rating(string[] report) {
    return report_rating(report, (string[] report, int position) {
        BinCount c = count_ones_zeros(report, position);
        if (c.zeros <= c.ones) {
            report = report.filter!(r => r[position] == '0').array();
        } else {
            report = report.filter!(r => r[position] == '1').array();
        }
        return report;
    });
}

string report_rating(string[] report, string[] function (string[] report, int position) report_filter) {
    string[] current_report = report[0 .. report.length];
    int current_position = 0;
    while (current_report.length > 1) {
        current_report = report_filter(current_report, current_position);
        current_position++;
    }
    return current_report[0];
}

void power_consumption(string[] report) {
    int[] ones = new int[report[0].length];
    int[] zeros = new int[report[0].length];

    foreach (string number; report) {
        for (int i = 0; i < number.length; i++) {
            char c = number[i];
            if (c == '0') {
                zeros[i]++;
            } else if (c == '1') {
                ones[i]++;
            } else {
                writeln("oof!");
            }
        }
    }

    // writeln(ones, zeros);

    string gamma = "";
    string epsilon = "";

    for (int i = 0; i < ones.length; i++) {
        int oc = ones[i];
        int zc = zeros[i];

        if (oc > zc) {
            gamma ~= "1";
            epsilon ~= "0";
        } else {
            gamma ~= "0";
            epsilon ~= "1";
        }
    }

    // writeln(gamma, ", ", epsilon);
    writeln(gamma.to!int(2) * epsilon.to!int(2));
}
