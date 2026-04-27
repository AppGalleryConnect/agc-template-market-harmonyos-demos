import { Type } from '@ohos.arkui.StateManagement'

@ObservedV2
export class DrawingHistoryItem {
  @Trace id: string = ''
  //画本名称
  @Trace drawingName: string = ''
  //画布资源路径
  @Trace drawingBoardPath: string = ''
  //画板内容路径
  @Trace drawingPath: string = ''
  //背景类型
  @Trace backgroundSelectType: string = 'SolidColor'
  /** 画布背景图片 */
  @Trace canvasBackgroundImage: ResourceStr = ''
  /** 画布背景颜色 */
  @Trace canvasColor: string = '#ffffff'
  /** 画布渐变色 */
  @Trace gradientColor: Array<[ResourceColor, number]> = []
  //上次修改事件
  @Trace lastEditTime: string = ''
}


/**
 * 绘画历史视图模型
 * 管理画本列表的增删改查
 */
@ObservedV2
export class DrawingHistoryList {
  /** 画本列表 */
  @Type(DrawingHistoryItem)
  @Trace drawingList: DrawingHistoryItem[] = []

  /**
   * 添加画本
   * @param item 画本项
   */
  addItem(item: DrawingHistoryItem): void {
    this.drawingList.unshift(item)
  }

  /**
   * 检查指定ID的画本是否存在
   * @param id 画本ID
   * @returns 是否存在
   */
  isItemExistById(id: string): boolean {
    // 空ID直接返回false（边界校验）
    if (!id) {
      return false;
    }
    return this.drawingList.some(item => item.id === id);
  }

  /**
   * 替换指定ID的画本子项（全量替换并移到最前面）
   * @param id 画本ID
   * @param newItem 新的画本项（需包含ID）
   * @returns 是否替换成功（false：ID不存在/参数非法）
   */
  replaceItemById(id: string, newItem: DrawingHistoryItem): boolean {
    // 边界校验：ID为空/新项ID与目标ID不一致 → 拒绝替换
    if (!id || !newItem || newItem.id !== id) {
      return false;
    }

    const index = this.drawingList.findIndex(item => item.id === id);
    if (index === -1) {
      return false;
    }

    // 删除原位置的项
    this.drawingList.splice(index, 1);
    // 将更新后的项添加到最前面
    this.drawingList.unshift(newItem);
    return true;
  }

  /**
   * 根据ID删除单个项
   * @param id 画本ID
   * @returns 是否删除成功
   */
  deleteItemById(id: string) {
    const index = this.drawingList.findIndex(item => item.id === id)
    if (index !== -1) {
      this.drawingList.splice(index, 1)
    }
  }

  /**
   * 根据ID数组删除多个项（优化版本）
   * @param ids ID数组
   * @returns 删除的数量
   */
  deleteMultipleItemsById(ids: string[]): number {
    if (!ids || ids.length === 0) {
      return 0
    }

    // 使用Set提高查找性能
    const idsSet = new Set(ids)
    const originalLength = this.drawingList.length

    // 过滤掉ID在集合中的项
    this.drawingList = this.drawingList.filter(item => !idsSet.has(item.id))

    return originalLength - this.drawingList.length
  }

  /**
   * 获取列表长度
   * @returns 列表长度
   */
  getCount(): number {
    return this.drawingList.length
  }

  /**
   * 判断列表是否为空
   * @returns 是否为空
   */
  isEmpty(): boolean {
    return this.drawingList.length === 0
  }
}