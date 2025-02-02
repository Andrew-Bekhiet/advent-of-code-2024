import { readFileSync } from "node:fs";

function parseInput(useExample: boolean): {
  updates: number[][];
  rules: [number, number][];
} {
  const rawInput = useExample
    ? readFileSync("example-input.txt", "utf8")
    : readFileSync("input.txt", "utf8");

  const [rawRules, rawPages] = rawInput.split("\n\n");

  const updates = rawPages
    .split("\n")
    .map((line) =>
      line
        .split(",")
        .map((n) => parseInt(n))
        .filter((n) => !Number.isNaN(n))
    )
    .filter((n) => n.length > 0);

  const rules = rawRules
    .split("\n")
    .map((rule) => rule.split("|").map((n) => parseInt(n)) as [number, number]);

  return { rules, updates };
}

function filterRulesForPages(
  rules: [number, number][],
  pages: number[]
): { forward: Map<number, number[]>; backward: Map<number, number[]> } {
  return rules
    .filter(([n1, n2]) => pages.includes(n1) || pages.includes(n2))
    .reduce(
      (acc, [n1, n2]) => {
        return {
          forward: acc.forward.set(n1, [...(acc.forward.get(n1) ?? []), n2]),
          backward: acc.backward.set(n2, [...(acc.backward.get(n2) ?? []), n1]),
        };
      },
      {
        forward: new Map<number, number[]>(),
        backward: new Map<number, number[]>(),
      }
    );
}

function isSortedBy<T>(
  pages: T[],
  forward: Map<T, T[]>,
  backward: Map<T, T[]>
): boolean {
  return pages.every((page, i) => {
    const isFirst = i == 0;
    const isLast = i == pages.length - 1;

    return (
      (isFirst || mapCompare(pages[i - 1], page, forward, backward) < 0) &&
      (isLast || mapCompare(page, pages[i + 1], forward, backward) < 0)
    );
  });
}

function mapCompare<T>(
  a: T,
  b: T,
  forward: Map<T, T[]>,
  backward: Map<T, T[]>
): number {
  return forward.get(a)?.includes(b)
    ? -1
    : backward.get(b)?.includes(a)
    ? 1
    : 0;
}

function part1(useExample: boolean): number {
  const { updates, rules } = parseInput(useExample);

  return updates
    .filter((pages) => {
      const { forward, backward } = filterRulesForPages(rules, pages);

      return isSortedBy(pages, forward, backward);
    })
    .reduce((acc, pages) => acc + pages[(pages.length / 2) | 0], 0);
}

function part2(useExample: boolean): number {
  const { updates, rules } = parseInput(useExample);

  return updates.reduce((acc, pages) => {
    const { forward, backward } = filterRulesForPages(rules, pages);
    if (isSortedBy(pages, forward, backward)) {
      return acc;
    }

    const sorted = pages.sort((a, b) => mapCompare(a, b, forward, backward));

    return acc + sorted[(sorted.length / 2) | 0];
  }, 0);
}

console.log("part1 example", part1(true));
console.log("part1 input", part1(false));

console.log("part2 example", part2(true));
console.log("part2 input", part2(false));
