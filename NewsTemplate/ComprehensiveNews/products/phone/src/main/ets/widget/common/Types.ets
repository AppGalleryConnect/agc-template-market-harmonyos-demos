/**
 * 服务卡片列表item模型
 */
export class FormItemModel {
  id: string = ''
  type: number = 0
  title: string = ''
  createTime: number = 0
  markCount: number = 0
  likeCount: number = 0
  shareCount: number = 0
  isLiked: boolean = false
  isMarked: boolean = false
  postBody: string = ''
  videoUrl: string = ''
  coverUrl: string = ''
  videoDuration: number = 0
  commentCount: number = 0

  constructor(id: string, title: string) {
    this.id = id;
    this.title = title;
  }
}