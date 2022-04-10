type Items = Array<String>;
type Option = Items;
type Matrix = Array<Array<0 | 1>>;

function selectItemFrom(matrix: Matrix): number {
    // TODO: there are more fancy things we can do here, like MRV
    return 0;
}

function activeOptions(i: number, items: Items, matrix: Matrix): Array<Option> {
    return matrix.filter((row) => row[i] === 1)
        .map((row) => row.map((bit, index) => bit === 1 ? items[index] : ""))
        .map((row) => row.filter((name) => name !== ""));
}

function coverItem(i: number, items: Items, matrix: Matrix): [Items, Matrix] {
    let smallerItems = [...items.slice(0, i), ...items.slice(i + 1)];
    let smallerMatrix = matrix.map((row) => [...row.slice(0, i), ...row.slice(i + 1)]);
    return [smallerItems, smallerMatrix];
}

let items: Items = ["a", "b", "c", "d", "e", "f", "g"];

let matrix: Matrix = [
    [0, 0, 1, 0, 1, 0, 0],
    [1, 0, 0, 1, 0, 0, 1],
    [0, 1, 1, 0, 0, 1, 0],
    [1, 0, 0, 1, 0, 1, 0],
    [0, 1, 0, 0, 0, 0, 1],
    [0, 0, 0, 1, 1, 0, 1],
];

function solve(items: Items, matrix: Matrix, accumOptions: Array<Option> = []): Array<Option> {
    // Select an item `i` that needs to be covered; but terminate
    // successfully if none are left (we've found a solution).
    if (matrix[0].length == 0) {
        return accumOptions;
    }
    let i = selectItemFrom(matrix);

    // If no active options involve `i`, terminate unsuccessfully
    // (there's no solution). Otherwise cover item `i`.
    let options: Array<Option> = activeOptions(i, items, matrix);
    if (options.length === 0) {
        return [];
    }
    [items, matrix] = coverItem(i, items, matrix);

    // For each just-deleted option `O` that involves `i`,
    // one at a time, cover each item `j != i` in `O`, and
    // and solve the residual problem.
    let solutions: Array<Option> = [];
    for (let option of options) {
        let [itemsCopy, matrixCopy] = [items, matrix];
        for (let name of option) {
            if (name !== items[i]) {
                let j = itemsCopy.indexOf(name);
                [itemsCopy, matrixCopy] = coverItem(j, itemsCopy, matrixCopy);
            }
        }
        solutions.push(...solve(itemsCopy, matrixCopy, [...accumOptions, option]));
    }
    return solutions;
}

console.log(solve(items, matrix));
