module day21;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

void main() {
    writeln(" ----- part 1 ----- ");
    part1();
    writeln(" ----- part 2 ----- ");
    part2();
}

void part2() {

    struct GameState {
        int currentPlayer;
        int player1pos;
        int player2pos;
        int player1total;
        int player2total;

        string toString() const {
            return format("{c=%d p=%d,%d t=%d,%d}", currentPlayer, player1pos, player2pos, player1total, player2total);
        }
    }

    GameState parse(string str) {
        string[] pts = str.split(",");
        return GameState(
            pts[0].to!int,
            pts[1].to!int,
            pts[2].to!int,
            pts[3].to!int,
            pts[4].to!int,
        );
    }

    ulong getOrDefault(ulong[GameState] states, GameState key, ulong defaultValue) {
        if (key in states) {
            return states[key];
        }
        return defaultValue;
    }

    ulong[GameState] states;

    // example input:
    // Player 1 starting position: 4
    // Player 2 starting position: 8
    // states[GameState(1,4,8,0,0)] = 1;

    // my input:
    // Player 1 starting position: 10
    // Player 2 starting position: 8
    states[GameState(1,10,8,0,0)] = 1;

    const int scoreToWin = 21;
    ulong[GameState] finalStates;

    while (states.keys.length > 0) {
        // writeln(states);

        ulong[GameState] nextStates;
        foreach(GameState prevState; states.keys) {
            if (prevState.player1total >= scoreToWin || prevState.player2total >= scoreToWin) {
                // Game is done, move count to finalStates.
                finalStates[prevState] += states[prevState];
                continue;
            }

            foreach (int a; 1 .. 4) {
                foreach (int b; 1 .. 4) {
                    foreach (int c; 1 .. 4) {
                        int rolledSum = a + b + c;
                        // writefln("Dice rolled: %d, %d, %d", a, b, c);

                        if (prevState.currentPlayer == 1) {
                            int nextPlayer1pos = ((prevState.player1pos + rolledSum - 1) % 10) + 1;
                            int nextPlayer1total = prevState.player1total + nextPlayer1pos;
                            GameState nextState = GameState(
                                2,
                                nextPlayer1pos,
                                prevState.player2pos,
                                nextPlayer1total,
                                prevState.player2total
                            );
                            nextStates[nextState] += states[prevState];

                        } else {
                            int nextPlayer2pos = ((prevState.player2pos + rolledSum - 1) % 10) + 1;
                            int nextPlayer2total = prevState.player2total + nextPlayer2pos;
                            GameState nextState = GameState(
                                1,
                                prevState.player1pos,
                                nextPlayer2pos,
                                prevState.player1total,
                                nextPlayer2total
                            );
                            nextStates[nextState] += states[prevState];

                        }
                    }
                }
            }
        }

        states = nextStates;
    }

    states = finalStates;

    ulong player1wins = 0;
    ulong player2wins = 0;
    foreach(GameState state; states.keys) {
        if (state.player1total >= scoreToWin) {
            player1wins += states[state];
        } else {
            player2wins += states[state];
        }
    }

    assert(states.values.sum == player1wins + player2wins);
    writefln("Unique states = %d\nTotal states = %d\nPlayer 1 wins = %d\nPlayer 2 wins = %d",
        states.keys.length,
        states.values.sum,
        player1wins,
        player2wins
    );
}

void part1() {
    int[int] players;
    // example input:
    // Player 1 starting position: 4
    // Player 2 starting position: 8
    // players[1] = 4;
    // players[2] = 8;

    // my input:
    // Player 1 starting position: 10
    // Player 2 starting position: 8
    players[1] = 10;
    players[2] = 8;

    Die die = new Die(100, 100);

    int[int] playerTotals;
    playerTotals[1] = 0;
    playerTotals[2] = 0;

    int currentPlayer = 1;
    int step = 0;
    while (step < 10_000) {
        int[] rolledValues = [die.roll, die.roll, die.roll];

        players[currentPlayer] += rolledValues.sum;
        players[currentPlayer] = ((players[currentPlayer] - 1) % 10) + 1;
        playerTotals[currentPlayer] += players[currentPlayer];
        /*writef("Player %s rolls %s and moves to space %d for a total score of %d.\n",
            currentPlayer, rolledValues, players[currentPlayer], playerTotals[currentPlayer]
        );*/

        if (currentPlayer == 1) {
            currentPlayer = 2;
        } else {
            currentPlayer = 1;
        }

        if (playerTotals[1] >= 1000) {
            writef("%d * %d = %d\n",
                playerTotals[2], die.timesRolled, playerTotals[2] * die.timesRolled
            );
            break;
        }

        if (playerTotals[2] >= 1000) {
            writef("%d * %d = %d\n",
                playerTotals[1], die.timesRolled, playerTotals[1] * die.timesRolled
            );
            break;
        }

        step++;
    }
}

class Die {
    uint current;
    uint max;
    uint timesRolled = 0;

    this(uint current, uint max) {
        this.current = current;
        this.max = max;
    }

    uint roll() {
        timesRolled++;
        current = ((current - 1 + 1) % 100) + 1;
        return current;
    }
}