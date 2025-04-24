export interface CommentItem {
  commentMakerIcon: string;
  commentMakerName: string;
  comment: string;
  score: number;
  commentTime: string;
  hotelName: string;
}

export type GetCommentListResp = CommentItem[];
