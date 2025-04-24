export class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 10
  endMargin: Length = 10
  color: ResourceColor = $r('app.color.mine_drive_color')

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}