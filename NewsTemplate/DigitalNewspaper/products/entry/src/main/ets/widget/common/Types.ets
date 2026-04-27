/**
 * 服务卡片列表item模型
 */
export class FormItemModel {
  id: string
  title: string
  authorId?: string
  createTime: number
  createDate?: string
  commentCount?: number
  markCount?: number
  likeCount?: number
  shareCount?: number
  isLiked?: boolean
  isMarked?: boolean
  richContent?: string

  constructor(id: string, title: string, createTime: number) {
    this.id = id;
    this.title =title;
    this.createTime = createTime;
  }
}

/**
 * 服务卡片-数据模型
 */
export class FormCardData {
  data: string = '';
}

/**
 * 服务卡片-跳转模型
 */
@ObservedV2
export class FormCardRouter {
  @Trace id: number = 0;
  @Trace pageUrl: string = '';
  @Trace newsId: string = '';
  @Trace newsTitle: string = '';
}