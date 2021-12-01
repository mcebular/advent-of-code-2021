module day01;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import std.string;

void main()
{

    int[] depths = File("input/day01.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(to!int)
        .array();

    // pt 1
    depth_increases(depths, 1);

    // pt 2
    depth_increases(depths, 3);
}

void depth_increases(int[] depths, int window_size)
{
    int increases = 0;
    int decreases = 0;

    int[] prev_window = depths[0 .. window_size];
    int[] curr_window = depths[1 .. 1 + window_size];

    for (int i = 2; i <= depths.length; i++)
    {
        int prev_sum = prev_window.fold!((a, b) => a + b);
        int curr_sum = curr_window.fold!((a, b) => a + b);

        // writeln(prev_sum, " ", curr_sum);

        if (prev_sum < curr_sum)
        {
            increases++;
        }
        else if (prev_sum > curr_sum)
        {
            decreases++;
        }

        if (i + window_size > depths.length)
        {
            break;
        }

        prev_window = curr_window;
        curr_window = depths[i .. i + window_size];
    }

    writeln(increases.to!string);
}
