export class PathPoint {
  x: number = 0;
  y: number = 0;
}

export class DrawHistoryItem {
  points: PathPoint[];
  pattern: CanvasPattern | null;
  lineWidth: number;

  constructor(points: PathPoint[], pattern: CanvasPattern | null, lineWidth: number) {
    this.points = points;
    this.pattern = pattern;
    this.lineWidth = lineWidth;
  }

  toPath2D(): Path2D {
    let path = new Path2D();
    if (this.points.length > 0) {
      path.moveTo(this.points[0].x, this.points[0].y);
      for (let i = 1; i < this.points.length; i++) {
        let prev = this.points[i - 1];
        let curr = this.points[i];
        path.quadraticCurveTo((curr.x + prev.x) / 2, (curr.y + prev.y) / 2, curr.x, curr.y);
      }
    }
    return path;
  }
}

export class Paint {
  lineWidth: number;
  strokeStyle: string;
  globalAlpha: number;
  shadowBlur: number = 0;
  lineCap: string = 'round';
  lineJoin: string = 'round';
  lineDash: number[] = [];

  constructor(lineWidth: number, strokeStyle: string, alpha: number) {
    this.lineWidth = lineWidth;
    this.strokeStyle = strokeStyle;
    this.globalAlpha = alpha;
  }

  setColor(color: string) {
    this.strokeStyle = color;
  }

  setStrokeWidth(width: number) {
    this.lineWidth = width;
  }

  setGlobalAlpha(alpha: number) {
    this.globalAlpha = alpha;
  }

  setShadowBlur(blur: number) {
    this.shadowBlur = blur;
  }

  setLineDash(lineDash: number[]) {
    this.lineDash = lineDash;
  }

  clone(): Paint {
    const p = new Paint(this.lineWidth, this.strokeStyle, this.globalAlpha);
    p.lineCap = this.lineCap;
    p.lineJoin = this.lineJoin;
    p.shadowBlur = this.shadowBlur;
    p.lineDash = this.lineDash;
    return p;
  }
}

export class DrawPath {
  public paint: Paint;
  public path: Path2D;
  private points: PathPoint[] = [];
  public canvasWidth: number = 0;
  public canvasHeight: number = 0;

  constructor(paint: Paint, path: Path2D) {
    this.paint = paint;
    this.path = path;
  }

  public addPoint(x: number, y: number): void {
    this.points.push({ x, y });
  }

  public rebuildFromPoints(points: PathPoint[]): void {
    this.points = [...points];
    if (points.length >= 2) {
      this.path.moveTo(points[0].x, points[0].y);
      for (let i = 1; i < points.length; i++) {
        this.path.lineTo(points[i].x, points[i].y);
      }
    }
  }


  public getPoints(): PathPoint[] {
    return [...this.points];
  }

  draw(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D, targetWidth: number = 0,
    targetHeight: number = 0): void {
    context.save();
    const lineDash1 = this.paint.lineDash[0] ?? 0;
    let lineDash2 = this.paint.lineDash[1] ?? 0;
    lineDash2 = lineDash2 / lineDash1 * this.paint.lineWidth;
    context.setLineDash([lineDash1, lineDash2]);
    if (this.canvasWidth > 0 && this.canvasHeight > 0 && targetWidth > 0 && targetHeight > 0) {
      const scaleX: number = targetWidth / this.canvasWidth;
      const scaleY: number = targetHeight / this.canvasHeight;
      if (scaleX !== 1 || scaleY !== 1) {
        context.scale(scaleX, scaleY);
      }
    }
    context.globalCompositeOperation = 'source-over';
    context.globalAlpha = this.paint.globalAlpha;
    context.lineWidth = this.paint.lineWidth;
    context.strokeStyle = this.paint.strokeStyle;
    context.shadowBlur = this.paint.shadowBlur;
    context.shadowColor = this.paint.strokeStyle;
    context.lineCap = this.paint.lineCap as CanvasLineCap;
    context.lineJoin = this.paint.lineJoin as CanvasLineJoin;
    context.stroke(this.path);
    context.restore();
  }
}