export interface LumberConfig {
    startPos: Array<number>,
    trees: Array<Tree>,
}

interface Tree {
    pos: number,
    time: number
}