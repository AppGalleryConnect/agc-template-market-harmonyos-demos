import { ChatEnum, NewsEnum } from '../../constants/Constants';
import { PostImgList } from '../base/BaseModel';

/**
 * 查询动态请求字段
 */
export interface PostQueryRequest {
  currentIndex: number;
  currentPage: number;
  topicTitle?: string;
}

/**
 * 发布动态请求字段
 */
export interface PostRequest {
  // 正文
  postBody: string;

  // 图片、视频链接
  postImgList?: PostImgList[];

  // 城市定位
  city?: string;
}

/**
 * 修改个人信息
 */
export interface ModifyPersonalInfoRequest {
  authorIcon?: string;
  authorNickName?: string;
  authorPhone?: string;
  authorDesc?: string;
  verifyCode?: string;
}

/**
 * 发送消息
 */
export interface SendMessageRequest {
  type: ChatEnum;
  content: string;
  createTime: number;
}

/**
 * 发表评论
 */
export interface PublishCommentRequest {
  newsId: string;
  content: string;
  parentCommentId?: string;
}

/**
 * 查询评论
 */
export interface CommentRequest {
  commentId: string;
}

/**
 * 查询作者
 */
export interface AuthorRequest {
  authorId: string;
}

/**
 * 查询公众号
 */
export interface SubscribeRequest {
  subscribeId: string;
  avId?: string;
}

/**
 * 查询新闻
 */
export interface NewsRequest {
  newsId: string
}

/**
 * 添加预约请求
 */
export interface AddReservationRequest {
  newsId: string
  liveStartTime: number
  eventId: number
}

/**
 * 搜索
 */
export interface SearchRequest {
  search: string;
}

/**
 * 添加文章请求
 */
export interface AddArticleRequest {
  title: string;
  content: string;
  setting: string;
  postImgList: PostImgList[];
}

/**
 * 动态布局新增数据请求
 */
export interface AddFlexLayoutRequest {
  articleId: string;
  setting: string;
}

/**
 * 视频关注列表请求
 */
export interface VideoFollowRequest {
  followedUserIds: string[];
}

/**
 * 查询视频列表
 */
export interface VideoListRequest {
  userId: string;
  type: number;
}

/**
 * 查询单个视频
 */
export interface VideoInfoRequest {
  id: string;
}

/**
 * 登录请求
 */
export interface SignInRequest {
  loginChannel?: string;
  nickPhone?: string;
}

/**
 * 获取验证码
 */
export interface SendCodeRequest {
  phone: string;
}

/**
 * 验证短信验证码
 */
export interface VerifyCodeRequest {
  phone: string;
  code: string;
}

/**
 * 查询个人相关
 */
export interface UserRequest {
  userId: string;
}

/**
 * 设置会员到期时间
 */
export interface MemberExpireTimeRequest {
  productId: string;
}

/**
 * 删除评论请求
 */
export interface DeleteCommentRequest {
  newsId: string;
  commentId: string;
}

/**
 * 首页推荐流查询
 */
export interface HomeListRequest {
  postType: string;
  currentIndex: number;
  currentPage: number;
}

/**
 * 广播流查询
 */
export interface BroadcastRequest {
  id: string
  postType: string;
  currentIndex: number;
  currentPage: number;
}

/**
 * 互动关注流查询
 */
export interface ActionFollowRequest {
  pageIndex: number;
}

/**
 * 首页关注流查询
 */
export interface HomeFollowRequest {
  newsType: NewsEnum[];
  currentIndex: number;
  currentPage: number;
  handleExtraInfo?: boolean;
}

/**
 * 城市查询
 */
export interface CityRequest {
  ip: string;
}

/**
 * 查询单个评论
 */
export interface CommentInfoRequest {
  commentId: string;
  ignoreReplyInner: boolean;
}

/**
 * 查询评论列表
 */
export interface CommentListRequest {
  newsId: string;
  ignoreReplyInner: boolean;
}

/**
 * 查询数字报纸列表
 */
export interface ENewsRequest {
  sourceId: string;
  publishDate: number;
}