import { CommentItem, KeywordItem } from '../types';

import { https } from 'network';
import { Logger } from 'commonlib';

@ObservedV2
export class CommentListPageVM {
  @Trace keyWordList: KeywordItem[] = [
    {
      desc: '服务周到',
      count: 4.6,
    },
    {
      desc: '环境卫生',
      count: 4.3,
    },
    {
      desc: '设施设备',
      count: 4.4,
    },
    {
      desc: '综合体验',
      count: 4.5,
    },
  ];
  @Trace commentList: CommentItem[] = [];
  private static _instance: CommentListPageVM;

  public static get instance() {
    if (!CommentListPageVM._instance) {
      CommentListPageVM._instance = new CommentListPageVM();
    }
    return CommentListPageVM._instance;
  }

  private constructor() {
    this.getCommentList();
  }

  public async getCommentList() {
    const res = await https.getCommentList();
    if (res.code !== 0) {
      Logger.error('get Comment list failed');
      return;
    }
    this.commentList = [];
    const initList = res.data;
    initList.forEach((item) => {
      const commentItem: CommentItem = {
        avatar: item.commentMakerIcon ?? undefined,
        userName: item.commentMakerName ?? '',
        date: item.commentTime,
        location: item.hotelName,
        star: item.score,
        desc: item.comment,
      };
      this.commentList.push(commentItem);
    });
  }
}
