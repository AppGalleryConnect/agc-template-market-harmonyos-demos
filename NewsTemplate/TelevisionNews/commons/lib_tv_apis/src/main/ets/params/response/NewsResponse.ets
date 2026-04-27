import { NewsEnum, VideoEnum } from '../../constants/Constants';
import { PostImgList } from '../base/BaseModel';
import { AuthorResponse } from './AuthorResponse';

/**
 * 新闻内容-云侧接口响应模型
 */
export interface NewsResponse {
  // 内容id
  id: string
  // 新闻类型
  type: NewsEnum
  // 标题
  title: string
  // 作者
  author: AuthorResponse
  // 创建时间
  createTime: number
  // 视频url
  videoUrl?: string
  // 封面图
  coverUrl?: string
  // 视频类型
  videoType?: VideoEnum
  // 视频时长(单位: 毫秒)
  videoDuration?: number
  // 正文
  postBody?: string
  // 图片链接
  postImgList?: PostImgList[]
  // 来源
  articleFrom?: string
  // 播放次数
  playCount?: string
  // 总数
  totalCount?: number
}