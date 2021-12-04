module day04;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import std.string;

void main() {

    string[] input = File("input/day04.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        // .filter!(line => line.length > 0)
        .array();

    string[] numbers = input[0].split(",").array();
    string[][][] boards;

    int idx = 2;
    while (idx + 5 <= input.length) {
        auto b = input[idx..idx+5]
            .map!(function(string line) {
                return line.split(" ")
                    .filter!(p => p.length > 0)
                    // .map!(to!int)
                    .array();
            })
            .array();
        idx += 6;

        boards ~= [b];
        // writeln(b);
    }

    int[] won_boards;
    int[int] won_boards_scores;
    foreach(string number; numbers) {
        // mark boards
        foreach(string[][] board; boards) {
            foreach(string[] line; board) {
                for (int i = 0; i < line.length; i++) {
                    if (line[i] == number) {
                        line[i] = "*" ~ number;
                    }
                }
            }
        }

        // check boards
        for (int i = 0; i < boards.length; i++) {
            string[][] board = boards[i];
            if (i in won_boards_scores) {
                continue;
            }
            if (check_board(board)) {
                int score = board_score(board, number);
                // writeln("Winning board is: ", board);
                // writeln("Its score is: ", score);
                won_boards ~= [i];
                won_boards_scores[i] = board_score(board, number);
            }
        }
    }

    // writeln(won_boards);
    writeln("First won board score: ", won_boards_scores[won_boards[0]]);
    writeln("Last won board score: ", won_boards_scores[won_boards[$-1]]);
}

int board_score(string[][] board, string called_num) {
    int board_sum = board
        .map!(line => line.filter!(v => v[0] != '*').map!(to!int).sum())
        .sum();
    return board_sum * called_num.to!int;
}

bool check_board(string[][] board) {
    for (int i = 0; i < board.length; i++) {
        bool has_horiz = true;
        bool has_vert = true;
        for (int j = 0; j < board[i].length; j++) {
            if (board[i][j][0] != '*') {
                has_horiz = false;
            }
            if (board[j][i][0] != '*') {
                has_vert = false;
            }
            if (!has_horiz && !has_vert) {
                break;
            }
        }

        if (has_horiz || has_vert) {
            return true;
        }
    }

    return false;
}

unittest {
    assert(check_board([["1", "2", "3"], ["1", "2", "3"], ["1", "2", "3"]]) == false);
    assert(check_board([["*1", "2", "3"], ["1", "*2", "3"], ["1", "2", "*3"]]) == false);
    assert(check_board([["*1", "2", "*3"], ["1", "*2", "3"], ["*1", "2", "*3"]]) == false);
    assert(check_board([["*1", "*2", "3"], ["*1", "*2", "3"], ["1", "2", "3"]]) == false);
    assert(check_board([["*1", "*2", "*3"], ["1", "*2", "3"], ["1", "2", "*3"]]) == true);
    assert(check_board([["*1", "2", "*3"], ["1", "2", "*3"], ["1", "2", "*3"]]) == true);
}