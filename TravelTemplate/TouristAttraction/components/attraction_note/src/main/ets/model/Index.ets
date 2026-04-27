/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { UtilLog } from '@hw-agconnect/util-log';
import { RouteModel } from 'module_base';
import { StatusFLAG } from '../constant/Index';
import { IAttraction, IComment, ITravelogue } from './IResponse';

@ObservedV2
export class HistoryList {
  historyList: string[] = [];
}

@ObservedV2
export class CommentModel implements IComment {
  // 评价创建人
  createBy: string = '';
  // 评价创建时间
  createTime: string | number = '';
  // 评价内容
  evaluateContent: string = '';
  // 评价人头像
  userHeadImg: string = '';
}

export class FindModule {
  img: ResourceStr = '';
  label: ResourceStr = '';
  targetUrl: string = '';
  isOpenApp: boolean = false;
}

@ObservedV2
export class AttractionModel implements IAttraction {
  labels: string[];
  detailImages: ResourceStr[];
  attractionId: number;
  name: string;
  banner: ResourceStr;
  icon: ResourceStr;
  isHot: number;
  latitude: number;
  longitude: number;
  duration: number;
  location: string;
  introduction: string;

  constructor(item?: AttractionModel) {
    this.labels = item?.labels || [];
    this.detailImages = item?.detailImages || [];
    this.attractionId = item?.attractionId || 0;
    this.name = item?.name || '';
    this.duration = item?.duration || 0;
    this.banner = item?.banner || '';
    this.icon = item?.icon || '';
    this.isHot = item?.isHot || 0;
    this.latitude = item?.latitude || 0;
    this.longitude = item?.longitude || 0;
    this.location = item?.location || '';
    this.introduction = item?.introduction || '';
  }
}

@ObservedV2
export class LocationInfo {
  longitude: number = 0;
  latitude: number = 0;
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
  images: string[] | string = [];
  // 游记内容
  content: string = '';
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
  routeId?: number = 0;

  constructor(item?: PostCardModel) {
    this.id = item?.id || 1;
    this.publisher = item?.publisher || '';
    this.publisherAvatar = item?.publisherAvatar || '';
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
    this.routeId = item?.routeId || 0;
  }
}

@ObservedV2
export class PostDetailModel extends PostCardModel {
  travelogueEvaluateList: CommentModel[] = [];
  relatedModules: FindModule[] = [];

  constructor(item?: PostDetailModel) {
    super(item);
    this.travelogueEvaluateList = item?.travelogueEvaluateList || [];
    this.relatedModules = item?.relatedModules || [];
  }
}

export interface RouteParam {
  route: RouteModel,
  attractionIds: number[]
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
      UtilLog.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      UtilLog.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.ADD, index, count }]);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.DELETE, index, count }]);
    });
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
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