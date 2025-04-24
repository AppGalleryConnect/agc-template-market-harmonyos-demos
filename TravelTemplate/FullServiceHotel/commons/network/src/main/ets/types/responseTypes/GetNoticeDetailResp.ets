export interface ContentItem {
  title: string;
  content: string;
  image: string;
}

export interface GetNoticeDetailResp {
  noticeTitle: string;
  noticeType: string;
  contentList: ContentItem[];
  noticeId: number;
  publishTime: string;
}
