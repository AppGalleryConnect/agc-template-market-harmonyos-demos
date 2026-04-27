// 定义点赞图标数据结构
export interface LikeIcon {
  x: number // X坐标
  y: number // Y坐标
  initialX: number // 初始X坐标
  initialY: number // 初始Y坐标
  radius: number // 半径
  emoji: string // emoji表情
  fontSize: number // 字体大小
  opacity: number // 透明度
  createTime: number // 创建时间
  lifespan: number // 生命周期(毫秒)
  scale: number // 当前缩放比例
  initialScale: number // 初始缩放比例
  maxScale: number // 最大缩放比例
  maxOffset: number // 最大摆动幅度
  direction: number // 摆动方向 (+1或-1)
}
