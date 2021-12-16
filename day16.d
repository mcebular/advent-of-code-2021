module day16;

import std.algorithm;
import std.array;
import std.container;
import std.conv;
import std.math;
import std.range;
import std.regex;
import std.stdio;
import std.string;

void main() {

    string[] input = File("input/day16.txt")
        .byLine()
        .map!(to!string)
        .map!strip
        .filter!(line => line.length > 0)
        .map!(hex => hex2bin(hex))
        .array();
    // writeln(input[0]);
    // writeln(input[0].length);

    Packet[] packets = parsePackets(input[0], 0, 0, 1).packets;
    // pt 1
    writeln(packets.versionSum);
    // pt 2
    writeln(packets[0].value);
}

string hex2bin(string hexValue) {
    return hexValue.map!((c) => format("%04b", ("" ~ [c]).to!int(16))).join();
}

ParsePacketsResult parsePackets(string input, int startIdx, int endIdx = 0, int packetCount = 0) {
    // writeln("STR=", startIdx, " END=", endIdx, " PCN=", packetCount);

    if (endIdx == 0 && packetCount == 0) {
        throw new Exception("When do I stop?!");
    }

    int idx = startIdx;
    Packet[] packets;

    while (true) {
        if (endIdx > 0 && idx >= endIdx) {
            break;
        }
        if (packetCount > 0 && packets.length >= packetCount) {
            break;
        }

        // packet header
        int ver = input[idx .. idx + 3].to!int(2);
        int typ = input[idx + 3 .. idx + 6].to!int(2);
        // writeln("VER=", ver, " TYP=", typ);
        idx += 6;

        if (typ == 4) {
            // packet contains literal
            string literal = "";
            bool continueRead = true;
            while (continueRead) {
                continueRead = input[idx] == '1';
                literal ~= input[idx + 1 .. idx + 5];
                idx = idx + 5;
            }

            packets ~= [Packet(ver, typ, literal.to!ulong(2))];
            continue;
        }

        // packet is an operator & contains sub-packets
        int ltid = input[idx];
        idx++;

        if (ltid == '1') {
            // next 11 bits are number of sub-packets.
            int subCount = input[idx .. idx + 11].to!int(2);
            idx += 11;
            ParsePacketsResult result = parsePackets(input, idx, 0, subCount);
            packets ~= [Packet(ver, typ, 0, result.packets)];
            idx = result.endIdx;

        } else if (ltid == '0') {
            // next 15 bits are total length of sub-packets
            int subLength = input[idx .. idx + 15].to!int(2);
            idx += 15;
            ParsePacketsResult result = parsePackets(input, idx, idx + subLength, 0);
            packets ~= [Packet(ver, typ, 0, result.packets)];
            assert(result.endIdx == idx + subLength);
            idx = result.endIdx;

        } else {
            throw new Exception("Invalid input: " ~ [ltid.to!char]);
        }

    }

    return ParsePacketsResult(idx, packets);
}

ulong value(Packet packet) {
    switch(packet.typ) {
        case 4:
            return packet.literal;
        case 0:
            // sum packet
            return packet.nested.map!(p => p.value).sum;
        case 1:
            // product packet
            return packet.nested.map!(p => p.value).fold!((a, b) => a * b);
        case 2:
            // minimum packet
            return packet.nested.map!(p => p.value).minElement;
        case 3:
            // maximum packet
            return packet.nested.map!(p => p.value).maxElement;
        case 5:
            // greater-than packet
            if (packet.nested[0].value > packet.nested[1].value) {
                return 1;
            } else {
                return 0;
            }
        case 6:
            // less-than packet
            if (packet.nested[0].value < packet.nested[1].value) {
                return 1;
            } else {
                return 0;
            }
        case 7:
            // equal-to packet
            if (packet.nested[0].value == packet.nested[1].value) {
                return 1;
            } else {
                return 0;
            }
        default:
            throw new Exception("Invalid packet type: " ~ packet.typ.to!string);
    }
}

struct ParsePacketsResult {
    int endIdx;
    Packet[] packets;
}

struct Packet {
    uint ver;
    uint typ;
    ulong literal;
    Packet[] nested;
}

uint versionSum(Packet[] packets) {
    int sum = 0;
    foreach (packet; packets) {
        sum += packet.ver;
        sum += versionSum(packet.nested);
    }
    return sum;
}
