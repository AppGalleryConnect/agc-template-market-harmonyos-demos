/**
 * 静默登录请求响应
 */
export interface LoginWithHuaweiIDResp {
  token: string;
  userId: string;
}

/**
 * 用户信息模型
 */
export interface IUserInfo {
  // id
  userId: number;

  // 昵称
  nickName?: string;

  // 头像
  avatar?: string;

  // 姓名
  name?: string;

  // 性别
  gender?: number;

  // 手机号码
  mobile?: string;

  // 生日
  birth?: number;
}

/**
 * 数字报纸云侧接口模型，包含单页报纸信息
 */
export interface DigitalNewsResponse {
  // 版面id
  id: number
  // 版面图片
  newsImg: string
  // 版面名称
  newsName: string
  // 位置信息，格式: x1,y1,x2,y2,x3,y3,x4,y4,,newsUrl,,newsId,,newsTitle||...
  position: string
  // 图片宽度
  width: string
  // 图片高度
  height: string
  // 报纸id
  paperId: number
  // 报纸时间，格式: 年月日xxxx-xx-xx
  paperTime: string
}

/**
 * 报纸来源
 */
export interface DigitalNewsSource {
  // 来源id
  id: string
  // 来源名称
  name: string
}

/**
 * 新闻文章详情
 */
export interface NewsArticle {
  // 新闻id
  id: string
  // 标题
  title: string
  // 作者
  authorId?: string
  // 创建时间
  createTime: number
  // 创建日期
  createDate?: string
  // 评论总数
  commentCount?: number
  // 收藏数量
  markCount?: number
  // 点赞数量
  likeCount?: number
  // 分享数量
  shareCount?: number
  // 是否被点赞
  isLiked?: boolean
  // 是否被收藏
  isMarked?: boolean
  // 文章-富文本
  richContent?: string
}

/**
 * 动态图片/视频
 */
export interface PostImgList {
  picVideoUrl: string
  movingVideoUrl?: string
  id?: string
  surfaceUrl: string
  type?: number
  essayId?: string
}