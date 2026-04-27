export default class Paint {
  lineWidth: number;
  strokeStyle: string;
  globalAlpha: number;

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
}