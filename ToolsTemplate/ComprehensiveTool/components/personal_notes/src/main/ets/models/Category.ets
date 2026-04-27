/**
 * 分类
 */
@ObservedV2
export class Category {
  /**
   * id
   */
  @Trace id: string = '';
  /**
   * 分类名称
   */
  @Trace name: string = '';
  /**
   * 数量
   */
  @Trace totalCount: number = 0;

  constructor(name: string, totalCount: number, id?: string,) {
    this.id = id? id : new Date().getTime().toString();
    this.name = name;
    this.totalCount = totalCount;
  }
}



