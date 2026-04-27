// 历史颜色视图模型类，管理用户使用过的颜色历史记录
@ObservedV2
export class ColorHistoryVM {
  // 最大历史颜色数量
  private readonly MAX_COLORS: number = 56
  // 历史颜色数组
  @Trace colors: string[] = []

  // 添加颜色到历史记录
  addColor(color: string): void {
    const existingIndex = this.colors.indexOf(color)
    if (existingIndex !== -1) {
      this.colors.splice(existingIndex, 1)
    }
    this.colors.unshift(color)
    if (this.colors.length > this.MAX_COLORS) {
      this.colors = this.colors.slice(0, this.MAX_COLORS)
    }
  }
}
