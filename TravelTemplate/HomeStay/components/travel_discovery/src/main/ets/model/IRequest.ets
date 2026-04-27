import { QueryTravelogueListType } from '../constant/Index';

export interface QueryTravelogueListRequest {
  // 类型
  type: QueryTravelogueListType;

  // 标题
  title?: string;

  // 用户ID
  userId?: number;

  // 页码
  pageNum?: number;

  // 每页数量
  pageSize?: number;
}

export interface RecordBrowseRequest {
  // 游记ID
  id: number;
}

export interface QueryTravelogueDetailRequest {
  // 游记ID
  id: number;

  // 用户ID
  userId: number;
}

export interface LikeTravelogueRequest {
  // 用户ID
  userId: number;

  // 关系ID(游记ID)
  relId: number;

  // 关系类型
  relType: string;
}

export interface CommentTravelogueRequest {
  // 用户ID
  userId: number;

  // 游记ID
  travelId: number;

  // 评价内容
  evaluateContent: string;
}
