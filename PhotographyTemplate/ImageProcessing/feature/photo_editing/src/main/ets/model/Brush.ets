export interface IBrush {
  down(path: Path2D, x: number, y: number): void;
  move(path: Path2D, x: number, y: number): void;
}

export class NormalBrush implements IBrush {
  down(path: Path2D, x: number, y: number): void {
    path.moveTo(x, y);
  }

  move(path: Path2D, x: number, y: number): void {
    path.lineTo(x, y);
  }
}

export class MarkerBrush implements IBrush {
  down(path: Path2D, x: number, y: number): void {
    path.moveTo(x, y);
  }

  move(path: Path2D, x: number, y: number): void {
    path.lineTo(x, y);
  }
}

export class PencilBrush implements IBrush {
  private lastX: number = 0;
  private lastY: number = 0;

  down(path: Path2D, x: number, y: number): void {
    this.lastX = x;
    this.lastY = y;
    path.moveTo(x, y);
  }

  move(path: Path2D, x: number, y: number): void {
    path.quadraticCurveTo(this.lastX, this.lastY, (x + this.lastX) / 2, (y + this.lastY) / 2);
    this.lastX = x;
    this.lastY = y;
  }
}

export class FountainBrush implements IBrush {
  private prevX: number = 0;
  private prevY: number = 0;

  down(path: Path2D, x: number, y: number): void {
    this.prevX = x;
    this.prevY = y;
    path.moveTo(x, y);
  }

  move(path: Path2D, x: number, y: number): void {
    const midX = (this.prevX + x) / 2;
    const midY = (this.prevY + y) / 2;
    path.quadraticCurveTo(this.prevX, this.prevY, midX, midY);
    this.prevX = x;
    this.prevY = y;
  }
}
