@ObservedV2
export class DrawingListVM {
  //编辑模式
  @Trace mangerMode: boolean = false
  //选中的画作id
  @Trace selectedIds: string[] = []

   scroller: ListScroller = new ListScroller();

  /**
   * 切换选中状态
   * @param id 画作ID
   */
  toggleSelection(id: string): void {
    const index = this.selectedIds.indexOf(id)
    if (index > -1) {
      // 已选中，则移除
      this.selectedIds.splice(index, 1)
    } else {
      // 未选中，则添加
      this.selectedIds.push(id)
    }
  }

  /**
   * 全选
   * @param allIds 所有画作ID数组
   */
  selectAll(allIds: string[]): void {
    this.selectedIds = [...allIds]
  }

  /**
   * 取消全选
   */
  clearSelection(): void {
    this.selectedIds = []
  }

  /**
   * 获取已选中数量
   * @returns 已选中的数量
   */
  getSelectedCount(): number {
    return this.selectedIds.length
  }

  /**
   * 判断是否有选中项
   * @returns 是否有选中项
   */
  hasSelection(): boolean {
    return this.selectedIds.length > 0
  }
}