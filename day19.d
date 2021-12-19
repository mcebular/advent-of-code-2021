module day19;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.regex;
import std.stdio;
import std.string;

void main() {
    string[] input = File("input/day19.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        // .filter!(line => line.length > 0)
        .array();

    Scanner[] scanners = parse(input);
    writeln(scanners.length);
    // validate against the input
    assert(scanners.length == 34);

    Vector3[] rotations = uniqueRotations();
    writeln(rotations.length);

    // ***** optimisation start
    // distances between points in each scanner.
    int[int][string] insideDistances;
    foreach(scanner; scanners) {
        int[int] dists;
        for (int i = 0; i < scanner.beacons.length; i++) {
            for (int j = i + 1; j < scanner.beacons.length; j++) {
                dists[distance(scanner.beacons[i], scanner.beacons[j])] += 1;
            }
        }
        insideDistances[scanner.id] = dists;
    }

    // for two scanners to match, they need to share at least 12 points.
    // 12 points share (12*(12-1))/2=66 connections (distances).
    // so there must be at least 66 same distances in A and B.
    bool possiblyMatchingScanners(int[int] a, int[int] b) {
        int[int] common;
        foreach (key, value; a) {
            if (key in b) {
                common[key] = min(value, b[key]);
            }
        }
        return common.values.sum >= 66;
    }
    // ***** optimisation end

    Scanner[] fixedScanners = [scanners[0]];
    Scanner[] remainingScanners = scanners[1 .. $];
    Vector3[] scannerPositions = [Vector3(0, 0, 0)];

    outer: while (remainingScanners.length > 0) {
        writeln("Remaining scanners: ", remainingScanners.length);

        for (int i = 0; i < remainingScanners.length; i++) {
            Scanner current = remainingScanners[i];
            foreach(fixed; fixedScanners) {
                // ***** optimisation start
                if (!possiblyMatchingScanners(insideDistances[current.id], insideDistances[fixed.id])) {
                    continue;
                }
                // ***** optimisation end

                foreach (rot; rotations) {
                    Scanner currentRotated = current.rotate(rot);

                    // for each point, translate all B points to one of A's points.
                    foreach (p1; fixed.beacons) {
                        foreach (p2; currentRotated.beacons) {
                            Vector3 diff = diff(p1, p2);
                            Scanner currentRotatedOffset = currentRotated.translate(neg(diff));
                            int[] dists = distances(fixed, currentRotatedOffset);
                            if (dists.count(0) >= 12) {
                                writefln(
                                    "Scanners %s and %s match, %s is rotated by %s and offset by %s.",
                                    fixed.id, current.id, current.id, rot, diff
                                );
                                fixedScanners ~= [currentRotatedOffset];
                                remainingScanners = remainingScanners[0 .. i] ~ remainingScanners[i + 1 .. $];
                                scannerPositions ~= [diff];
                                continue outer;
                            }
                        }
                    }
                }
            }
        }
    }

    bool[Vector3] uniqueBeacons;
    foreach (scanner; fixedScanners) {
        foreach (beacon; scanner.beacons) {
            if (!(beacon in uniqueBeacons)) {
                uniqueBeacons[beacon] = true;
            }
        }
    }
    // pt 1
    writeln("No. of beacons: ", uniqueBeacons.values.length);

    int maxScannerDistance = 0;
    foreach(s1; scannerPositions) {
        foreach(s2; scannerPositions) {
            maxScannerDistance = max(maxScannerDistance, manhattan(s1, s2));
        }
    }
    // pt 2
    writeln(maxScannerDistance);
}

Vector3[] uniqueRotations() {
    Vector3[][Vector3] all;
    foreach (int rotx; [0, 90, 180, 270]) {
        foreach (int roty; [0, 90, 180, 270]) {
            foreach (int rotz; [0, 90, 180, 270]) {
                Vector3 v = Vector3(5, 3, 7);
                v = rotateX(v, rotx);
                v = rotateY(v, roty);
                v = rotateZ(v, rotz);
                if (!(v in all)) {
                    all[v] = [];
                }
                all[v] = all[v] ~ [Vector3(rotx, roty, rotz)];
            }
        }
    }
    return all.values.map!(v => v[0]).array;
}


//
// Scanner is esentially a group of vectors
//

struct Scanner {
    string id;
    Vector3[] beacons;
}

int[] distances(Scanner a, Scanner b) {
    int[] result = [];

    foreach (pa; a.beacons) {
        foreach (pb; b.beacons) {
            result ~= [distance(pa, pb)];
        }
    }

    return result;
}

Scanner rotate(Scanner s, Vector3 rotation) {
    return Scanner(s.id, s.beacons.map!(b => rotate(b, rotation)).array);
}

Scanner translate(Scanner s, Vector3 translation) {
    return Scanner(s.id, s.beacons.map!(b => translate(b, translation)).array);
}

Scanner[] parse(string[] input) {
    Scanner[] scanners = [];
    Scanner s;

    for (int i = 0; i < input.length; i++) {
        string line = input[i];

        if (line.length > 3 && line[0 .. 3] == "---") {
            string id = line.split(" ")[2];
            s = Scanner(id, []);
            continue;
        }

        if (line.length == 0) {
            if (s.id != "" && s.beacons.length > 0) {
                scanners ~= [s];
                s = Scanner("", []);
            }
            continue;
        }

        int[] coords = line.split(",").map!(p => p.to!int).array;
        s.beacons ~= [Vector3(coords[0], coords[1], coords[2])];
    }

    return scanners;
}

unittest {
    Scanner[] result = parse([
        "--- scanner 0 ---", "1,2,3", "", "--- scanner 1234 ---", "-4,5,-6",
        "-5,1,1", ""
    ]);
    assert(result[0].id == "0");
    assert(result[0].beacons[0] == Vector3(1, 2, 3));

    assert(result[1].id == "1234");
    assert(result[1].beacons[0] == Vector3(-4, 5, -6));
    assert(result[1].beacons[1] == Vector3(-5, 1, 1));
}

unittest {
    Scanner[] scanners = parse([
        "--- scanner 0 ---",
        "-1,-1,1",
        "-2,-2,2",
        "-3,-3,3",
        "-2,-3,1",
        "5,6,-4",
        "8,0,7",
        "",
        "--- scanner 0 ---",
        "1,-1,1",
        "2,-2,2",
        "3,-3,3",
        "2,-1,3",
        "-5,4,-6",
        "-8,-7,0",
        "",
        "--- scanner 0 ---",
        "-1,-1,-1",
        "-2,-2,-2",
        "-3,-3,-3",
        "-1,-3,-2",
        "4,6,5",
        "-7,0,8",
        "",
        "--- scanner 0 ---",
        "1,1,-1",
        "2,2,-2",
        "3,3,-3",
        "1,3,-2",
        "-4,-6,5",
        "7,0,8",
        "",
        "--- scanner 0 ---",
        "1,1,1",
        "2,2,2",
        "3,3,3",
        "3,1,2",
        "-6,-4,-5",
        "0,7,-8",
        ""
    ]);

    Scanner first = scanners[0];
    int same = 0;
    foreach (Vector3 rot; uniqueRotations()) {
        Scanner rotated = rotate(first, rot);
        foreach (s; scanners) {
            if (s == rotated) {
                same++;
                break;
            }
        }
    }
    assert(same == 5);

}


//
// Vector operations
//

Vector3 rotate(Vector3 vector, Vector3 rotation) {
    return rotateX(rotateY(rotateZ(vector, rotation.z), rotation.y), rotation.x);
}

Vector3 translate(Vector3 vector, Vector3 translation) {
    return Vector3(vector.x + translation.x, vector.y + translation.y, vector.z + translation.z);
}

Vector3 diff(Vector3 a, Vector3 b) {
    return Vector3(b.x - a.x, b.y - a.y, b.z - a.z);
}

Vector3 neg(Vector3 v) {
    return Vector3(-v.x, -v.y, -v.z);
}

int manhattan(Vector3 a, Vector3 b) {
    return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z);
}

int distance(Vector3 a, Vector3 b) {
    Vector3 diff = diff(a, b);
    // return sqrt((diff.x * diff.x + diff.y * diff.y + diff.z * diff.z).to!double);
    return (diff.x * diff.x + diff.y * diff.y + diff.z * diff.z);
}

unittest {
    assert(translate(Vector3(3, 5, 7), Vector3(2, 2, 2)) == Vector3(5, 7, 9));
    assert(translate(Vector3(-3, -5, -7), Vector3(2, 2, 2)) == Vector3(-1, -3, -5));
    assert(translate(Vector3(3, 5, 7), Vector3(-2, -2, -2)) == Vector3(1, 3, 5));
    assert(translate(Vector3(-3, -5, -7), Vector3(-2, -2, -2)) == Vector3(-5, -7, -9));
}

unittest {
    assert(distance(Vector3(0, 0, 0), Vector3(0, 0, 0)) == 0);
    assert(distance(Vector3(0, 0, 0), Vector3(1, 0, 0)) == 1 * 1);
    assert(distance(Vector3(0, 0, 0), Vector3(5, 0, 0)) == 5 * 5);
}


//
// Rotation matrices
//

Vector3 rotateX(Vector3 vector, int degrees) {
    double rad = deg2rad(degrees);
    int[][] rmx =
        [
            [1, 0, 0],
            [0, cos(rad).to!int, -sin(rad).to!int],
            [0, sin(rad).to!int, cos(rad).to!int]
        ];

    return matrixMultiply(vector, rmx);
}

Vector3 rotateY(Vector3 vector, int degrees) {
    double rad = deg2rad(degrees);
    int[][] rmx =
        [
            [cos(rad).to!int, 0, sin(rad).to!int],
            [0, 1, 0],
            [-sin(rad).to!int, 0, cos(rad).to!int]
        ];

    return matrixMultiply(vector, rmx);
}

Vector3 rotateZ(Vector3 vector, int degrees) {
    double rad = deg2rad(degrees);
    int[][] rmx =
        [
            [cos(rad).to!int, -sin(rad).to!int, 0],
            [sin(rad).to!int, cos(rad).to!int, 0],
            [0, 0, 1]
        ];

    return matrixMultiply(vector, rmx);
}

double deg2rad(int degrees) {
    return degrees * PI / 180;
}


//
// Matrix-Vector multiplication
//

struct Vector3 {
    int x, y, z;

    string toString() const {
        return format("[%d, %d, %d]", x, y, z);
    }
}

Vector3 matrixMultiply(Vector3 vector, int[][] matrix) {
    int x = matrix[0][0] * vector.x + matrix[0][1] * vector.y + matrix[0][2] * vector.z;
    int y = matrix[1][0] * vector.x + matrix[1][1] * vector.y + matrix[1][2] * vector.z;
    int z = matrix[2][0] * vector.x + matrix[2][1] * vector.y + matrix[2][2] * vector.z;
    return Vector3(x, y, z);
}

unittest {
    assert(matrixMultiply(Vector3(4,5,6), [[3,9,-1],[4,-2,6],[7,1,-5]]) == Vector3(51, 42, 3));
}
