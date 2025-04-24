export interface NoticeItem {
  noticeTitle: string;
  noticeType: string;
  noticeId: number;
  publishTime: string;
}

export type GetNoticeListResp = NoticeItem[];
