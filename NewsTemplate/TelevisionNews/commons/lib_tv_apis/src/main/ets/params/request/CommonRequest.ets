import { ChatEnum, NewsEnum } from '../../constants/Constants';
import { PostImgList } from '../base/BaseModel';

/**
 * 发布动态请求字段
 */
export interface PostRequest {
  // 正文
  postBody: string;

  // 图片、视频链接
  postImgList?: PostImgList[];
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
 * 搜索
 */
export interface SearchRequest {
  search: string;
}


/**
 * 查询推荐请求
 */
export interface QueryListRequest {
  currentIndex: number;
  currentPage: number;
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
 * 查询个人相关
 */
export interface UserRequest {
  userId: string;
}














