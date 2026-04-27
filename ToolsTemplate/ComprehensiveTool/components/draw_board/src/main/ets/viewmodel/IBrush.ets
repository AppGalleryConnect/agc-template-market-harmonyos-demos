
export interface IBrush {
  down(path: Path2D, x: number, y: number): void;
  move(path: Path2D, x: number, y: number): void;
  up(path: Path2D, x: number, y: number): void;
}

export default class NormalBrush implements IBrush {
  down(path: Path2D, x: number, y: number): void {
    path.moveTo(x, y);
  }

  move(path: Path2D, x: number, y: number): void {
    path.lineTo(x, y);
  }

  up(path: Path2D, x: number, y: number): void {}

}