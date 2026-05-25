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
   * 序列化后的属性字符串
   */
  serializedStyledString: string
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

  /**
   * 手写数据文件名
   */
  handwriteFileName: string = '';

  /**
   * 笔记类型：普通笔记 | 录音笔记
   */
  @Trace noteType: 'normal' | 'recording' = 'normal';

  /**
   * 录音笔记的音频文件路径（仅录音笔记有效）
   */
  @Trace audioUri: string = '';

  constructor(styledString: MutableStyledString, title?: string, categoryId?: string) {
    this.styledString = styledString;
    this.serializedStyledString = '';
    this.title = title || '';
    this.categoryId = categoryId || '';
    this.id = new Date().getTime().toString();
    this.createTime = new Date().getTime().toString();
    this.updateTime = this.createTime
    this.description = this.styledString.getString()
    // 初始化手写文件名
    this.handwriteFileName = `handwrite_${this.id}`;
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
