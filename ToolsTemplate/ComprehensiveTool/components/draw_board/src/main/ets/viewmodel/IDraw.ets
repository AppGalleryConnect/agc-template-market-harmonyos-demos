import { CommonConstants } from '../constants/CommonConstants';
import { PencilPos, Pos, ShapePos, ShapeType } from '../model/Model';
import Paint from './Paint';

export interface IDraw {
  draw(context: CanvasRenderingContext2D): void;
}

export default class DrawPath implements IDraw {
  public paint: Paint;
  public path: Path2D;
  private points: Pos[] = [];
  private shapePoints: ShapePos[] = [];
  public rubberPoints: PencilPos[] = [];

  constructor(paint: Paint, path: Path2D) {
    this.paint = paint;
    this.path = path;
  }

  // 添加点
  public addPoint(x: number, y: number): void {
    this.points.push({ x, y });
  }

  public addShapePoint(shapeType: ShapeType, startX: number, startY: number, x: number, y: number, color: string,
    strokeWidth: number, alpha: number): void {
    this.shapePoints.push({
      shapeType,
      startX,
      startY,
      x,
      y,
      color,
      strokeWidth,
      alpha,
    });
  }


  public rebuildFromPoints(points: Pos[]): void {
    this.points = [...points];

    if (points.length >= 2) {
      this.path.moveTo(points[0].x, points[1].y);

      for (let i = 1; i < points.length; i++) {
        this.path.lineTo(points[i].x, points[i].y);
      }
    }
  }

  // 绘制星形
  public drawStar(startX: number, startY: number, endX: number, endY: number,
    color: string, strokeWidth: number, alpha: number): void {
    const width = Math.abs(endX - startX);
    const height = Math.abs(endY - startY);
    const centerX = startX + width / 2;
    const centerY = startY + height / 2;
    const outerRadius = Math.min(width, height) / 2;
    const innerRadius = outerRadius * 0.4;


    for (let i = 0; i < 5; i++) {
      // 外点
      const outerAngle = (i * 2 * Math.PI / 5) - Math.PI / 2;
      const outerX = centerX + outerRadius * Math.cos(outerAngle);
      const outerY = centerY + outerRadius * Math.sin(outerAngle);

      if (i === 0) {
        this.path.moveTo(outerX, outerY);
      } else {
        this.path.lineTo(outerX, outerY);
      }

      // 内点
      const innerAngle = ((i + 0.5) * 2 * Math.PI / 5) - Math.PI / 2;
      const innerX = centerX + innerRadius * Math.cos(innerAngle);
      const innerY = centerY + innerRadius * Math.sin(innerAngle);

      this.path.lineTo(innerX, innerY);
    }
    this.path.closePath();
  }

  // 绘制矩形
  public drawRectangle(startX: number, startY: number, endX: number, endY: number,
    color: string, strokeWidth: number, alpha: number): void {
    const x = Math.min(startX, endX);
    const y = Math.min(startY, endY);

    // 计算矩形的宽和高（取绝对值，确保为正数）
    const width = Math.abs(endX - startX);
    const height = Math.abs(endY - startY);
    ;
    this.path.rect(x, y, width, height);
  }

  // 绘制圆形
  public drawCircle(startX: number, startY: number, endX: number, endY: number,
    color: string, strokeWidth: number, alpha: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const radius = Math.sqrt(Math.pow(endX - startX, 2) + Math.pow(endY - startY, 2)) / 2;

    this.path.moveTo(centerX + radius, centerY);
    this.path.arc(centerX, centerY, radius, 0, Math.PI * 2);

  }

  // 绘制三角形
  public drawTriangle(startX: number, startY: number, endX: number, endY: number,
    color: string, strokeWidth: number, alpha: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const radius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;


    // 计算三角形的三个点
    for (let i = 0; i < 3; i++) {
      const angle = (i * 2 * Math.PI / 3) - Math.PI / 2;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      if (i === 0) {
        this.path.moveTo(x, y);
      } else {
        this.path.lineTo(x, y);
      }
    }
    this.path.closePath();
  }

  // 根据形状数据绘制形状
  public drawShapeFromData(shapeData: ShapePos,
    color: string = CommonConstants.BLACK,
    strokeWidth: number = CommonConstants.THREE,
    alpha: number = CommonConstants.ONE): void {
    const shapeType = shapeData.shapeType
    const startX = shapeData.startX
    const startY = shapeData.startY
    const x = shapeData.x
    const y = shapeData.y
    switch (shapeType) {
      case 'star':
        this.drawStar(startX, startY, x, y, color, strokeWidth, alpha);
        break;
      case 'rectangle':
        this.drawRectangle(startX, startY, x, y, color, strokeWidth, alpha);
        break;
      case 'circle':
        this.drawCircle(startX, startY, x, y, color, strokeWidth, alpha);
        break;
      case 'triangle':
        this.drawTriangle(startX, startY, x, y, color, strokeWidth, alpha);
        break;
      default:
        this.drawCircle(startX, startY, x, y, color, strokeWidth, alpha);
        break;
    }
  }


  // 获取所有点
  public getPoints(): Pos[] {
    return [...this.points];
  }

  // 获取所有点
  public getShapePoints(): ShapePos[] {
    return [...this.shapePoints];
  }

  draw(context: CanvasRenderingContext2D): void {
    context.lineWidth = this.paint.lineWidth;
    context.strokeStyle = this.paint.strokeStyle;
    context.globalAlpha = this.paint.globalAlpha;
    context.lineCap = 'round';
    context.stroke(this.path)
  }
}