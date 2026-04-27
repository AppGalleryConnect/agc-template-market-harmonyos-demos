// 路径信息类，保存每个路径的绘制属性
export class PathInfo {
  path: Path2D
  color: string
  strokeWidth: number
  alpha?: number
  isEraser?: boolean
  isClearAction?: boolean  // 标记是否为清空操作
  lineCap?: CanvasLineCap
  lineJoin?: CanvasLineJoin

  constructor(
    path: Path2D,
    color: string,
    strokeWidth: number,
    alpha?: number,
    isEraser?: boolean,
    lineCap?: CanvasLineCap,
    lineJoin?: CanvasLineJoin,
    isClearAction?: boolean
  ) {
    this.path = path
    this.color = color
    this.strokeWidth = strokeWidth
    this.alpha = alpha ?? 1
    this.isEraser = isEraser ?? false
    this.lineCap = lineCap ?? 'round'
    this.lineJoin = lineJoin ?? 'round'
    this.isClearAction = isClearAction ?? false
  }
}
