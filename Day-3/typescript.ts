import { log } from "node:console";
import { readFileSync } from "node:fs";

function parseInput(useExample: boolean): string[] {
  return useExample
    ? readFileSync("example-input.txt", "utf8").split("\n")
    : readFileSync("input.txt", "utf8").split("\n");
}

function part1(useExample: boolean): number {
  const input = parseInput(useExample).join("");

  const matches = matchDifferentBrackets({
    input,
    start: "mul(",
    end: ")",
    recursively: true,
  });

  let result = 0;

  for (const match of matches) {
    const splitted = match.split(",");

    if (splitted.length !== 2) continue;

    const a = Number.parseInt(splitted[0]);
    const b = Number.parseInt(splitted[1]);

    if (
      Number.isNaN(a) ||
      Number.isNaN(b) ||
      a.toString() !== splitted[0] ||
      b.toString() !== splitted[1]
    )
      continue;

    result += a * b;
  }

  return result;
}

function matchDifferentBrackets(args: {
  input: string;
  start: string;
  end: string;
  recursively: boolean;
}): string[] {
  const { input, start, end, recursively } = args;

  const result: Array<string> = [];

  const matchStack: Array<string> = [];
  const resultStack: Array<string> = [];

  for (let i = 0; i < input.length; i++) {
    if (
      input.slice(i, i + start.length) === start &&
      (recursively || matchStack.length === 0)
    ) {
      i += start.length - 1;
      matchStack.push(start);
      resultStack.push("");
    } else if (input.slice(i, i + end.length) === end) {
      i += end.length - 1;
      if (matchStack.pop()) {
        result.push(resultStack.pop()!);
      }
    } else if (matchStack[matchStack.length - 1] === start) {
      resultStack.forEach((_, j) => (resultStack[j] += input[i]));
      // resultStack[resultStack.length - 1] += input[i];
    }
  }

  return result;
}

function part2(useExample: boolean): number {
  const input = parseInput(useExample).join("");

  const matches = matchDifferentBrackets({
    input: "do()" + input + "don't()",
    start: "do()",
    end: "don't()",
    recursively: false,
  });

  let result = 0;

  for (const match of matches) {
    const instructions = matchDifferentBrackets({
      input: match,
      start: "mul(",
      end: ")",
      recursively: true,
    });

    for (const instruction of instructions) {
      const splitted = instruction.split(",");

      if (splitted.length !== 2) continue;

      const a = Number.parseInt(splitted[0]);
      const b = Number.parseInt(splitted[1]);

      if (
        Number.isNaN(a) ||
        Number.isNaN(b) ||
        a.toString() !== splitted[0] ||
        b.toString() !== splitted[1]
      )
        continue;

      result += a * b;
    }
  }

  return result;
}
log("part1 example", part1(true));
log("part1 input", part1(false));

log("part2 example", part2(true));
log("part2 input", part2(false));
