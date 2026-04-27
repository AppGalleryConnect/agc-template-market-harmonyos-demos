/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { StatusFLAG } from '../constant/Index';
import { IComment, ITravelogue } from './IResponse';

@ObservedV2
export class HistoryList {
  historyList: string[] = [];
}

@ObservedV2
export class CommentModel implements IComment {
  // 评价创建人
  @Trace createBy: string = '';
  // 评价创建时间
  @Trace createTime: string | number = '';
  // 评价内容
  @Trace evaluateContent: string = '';
  // 评价人头像
  @Trace userHeadImg: string = '';
}

export class FindModule {
  img: ResourceStr = '';
  label: ResourceStr = '';
  targetUrl: string = '';
  isOpenApp: boolean = false;
}

@ObservedV2
export class PostCardModel implements ITravelogue {
  // 游记ID
  id: number = 0;
  // 标题
  title: string = '';
  // 发布者
  publisher: string = '';
  // 发布者头像
  publisherAvatar: string = '';
  // 发布时间
  publishTime: string = '';
  // 游记图片
  @Trace images: string[] | string = [];
  // 游记内容
  @Trace content: string = '';
  // 点赞数
  @Trace likeNum: number = 0;
  // 收藏数
  @Trace collectNum: number = 0;
  // 评论数
  commentNum: number = 0;
  // 当前用户点赞状态（Y是，N否）
  @Trace currentUserLikeStatus: StatusFLAG = StatusFLAG.NO;
  // 当前用户收藏状态（Y是，N否）
  @Trace currentUserCollectStatus: StatusFLAG = StatusFLAG.NO;

  constructor(item?: PostCardModel) {
    this.id = item?.id || 1;
    this.publisher = item?.publisher || '';
    this.publisherAvatar = item?.publisherAvatar || ''
    this.title = item?.title || '';
    this.content = item?.content || '';
    if (typeof item?.images === 'string') {
      this.images = JSON.parse(item.images || '[]');
    } else {
      this.images = item?.images || [];
    }
    this.publishTime = item?.publishTime || '';
    this.likeNum = item?.likeNum || 0;
    this.collectNum = item?.collectNum || 0;
    this.commentNum = item?.commentNum || 0;
    this.currentUserLikeStatus = item?.currentUserLikeStatus || StatusFLAG.NO;
    this.currentUserCollectStatus = item?.currentUserCollectStatus || StatusFLAG.NO;
  }
}

@ObservedV2
export class PostDetailModel extends PostCardModel {
  @Trace travelogueEvaluateList: CommentModel[] = [];
  @Trace relatedModules: FindModule[] = [];

  constructor(item?: PostDetailModel) {
    super(item);
    this.travelogueEvaluateList = item?.travelogueEvaluateList || [];
    this.relatedModules = item?.relatedModules || [];
  }
}

class CardBasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: PostCardModel[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): PostCardModel {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.ADD, index, count }]);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.DELETE, index, count }]);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

export class CardDataSource extends CardBasicDataSource {
  private dataArray: PostCardModel[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): PostCardModel {
    return this.dataArray[index];
  }

  public addData(data: PostCardModel[]): void {
    const index = this.dataArray.length;
    this.dataArray.splice(index, 0, ...data);
    this.notifyDataAdd(index, data.length);
  }

  public pushData(data: PostCardModel): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1, 1);
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index, 1);
  }

  public clearAllData() {
    this.dataArray.splice(0, this.dataArray.length);
    this.notifyDataDelete(0, this.dataArray.length);
  }
}