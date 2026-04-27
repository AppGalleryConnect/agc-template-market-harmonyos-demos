/**
 * 笔记
 */
@ObservedV2
export class Note {
  /**
   * id
   */
  id: string = '';
  /**
   * 标题
   */
  @Trace title: string = '';
  /**
   * 分类
   */
  categoryId: string = '';
  /**
   * 内容
   */
  styledString: MutableStyledString
  /**
   * 创建时间
   */
  createTime: string = '';
  /**
   * 修改时间
   */
  updateTime: string = '';
  /**
   * 是否被选中，首页多选时使用
   */
  @Trace isSelected: boolean = false;

  /**
   * 内容描述
   */
  @Trace description: string = '';

  constructor(styledString: MutableStyledString, title?: string, categoryId?: string) {
    this.styledString = styledString;
    this.title = title || '';
    this.categoryId = categoryId || '';
    this.id = new Date().getTime().toString();
    this.createTime = new Date().getTime().toString();
    this.updateTime = this.createTime
    this.description = this.styledString.getString()
  }

  updateContent(styledString: MutableStyledString, title?: string, category?: string): boolean {
    if (!styledString) {
      return false;
    }
    this.styledString = styledString;
    this.title = title || this.title;
    this.categoryId = category || this.categoryId;
    this.updateTime = new Date().getTime().toString();
    this.description = this.styledString.getString()
    return true;
  }
}