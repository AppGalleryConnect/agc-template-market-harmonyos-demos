import { StatusFLAG } from '../constant/Index';

/**
 * 响应基础
 */
export interface IBase {
  code: number;
  msg?: string;
  showMsg?: string;
}

export interface IComment {
  id: number;
  createBy: string;
  createTime: string | number;
  evaluateContent: string;
  userHeadImg: string;
  likeNum: number;
  likeStatus: StatusFLAG | string;
}

/**
 * 游记响应模型
 */
export interface ITravelogue {
  id: number;
  title: string;
  publisher: string;
  publisherAvatar: string;
  publishTime: string;
  images: string[] | string;
  content: string;
  likeNum: number;
  collectNum: number;
  shareNum: number;
  commentNum: number;
  currentUserLikeStatus: StatusFLAG | string;
  currentUserCollectStatus: StatusFLAG | string;
  travelogueEvaluateList?: IComment[];
}

export interface ITravelogueList {
  data: ITravelogue[];
}

export interface ITravelogueDetail {
  data: ITravelogue | null;
}