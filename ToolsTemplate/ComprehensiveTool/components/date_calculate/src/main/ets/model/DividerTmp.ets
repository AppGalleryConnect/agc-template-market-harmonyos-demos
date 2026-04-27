export class DividerTmp {
  color: ResourceColor = $r('app.color.mine_drive_color');
  startMargin: Length = 10;
  endMargin: Length = 10;
  strokeWidth: Length = 1;

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth;
    this.startMargin = startMargin;
    this.endMargin = endMargin;
    this.color = color;
  }
}