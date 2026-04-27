import { util } from '@kit.ArkTS';
import { ShareData } from '@tencent/qq-open-sdk';
import { ShareAppType, ShareWay } from './ShareEnum';

/**
 * 分享数据
 */
export interface ShareRecordData {
  recordId?: string;
  title: string;
  subTitle?: string;
  coverUrl?: string;
  thumbUrl?: ResourceStr;
  landingPageUrl?: string;
  createTime?: number;
}

/**
 * 打开分享面板的选项
 */
export interface ShareOptions {
  autoClose?: boolean;
  directPoster?: boolean;
  extComponentId?: string;
  sheetTitle?: string;
  posterSheetTitle?: string;
  excludedAbilities?: (ShareAppType | ShareWay)[];
}

/**
 * 其他信息
 */
export interface ExtraInfo {
  signQQShareData: (shareJson: string) => Promise<QQShareData>;
  isLayoutFullScreen?: boolean;
}

@ObservedV2
export class ShareViewData {
  @Trace recordId: string = util.generateRandomUUID();
  @Trace title: string = '';
  @Trace subTitle: string = '';
  @Trace coverUrl: string = '';
  @Trace thumbUrl: ResourceStr = '';
  @Trace landingPageUrl: string = '';
  @Trace createTime: number = 0;
  @Trace sheetType: SheetType = SheetType.BOTTOM;
  @Trace extComponentId: string = '';
  @Trace directPoster: boolean = false;
  @Trace autoClose: boolean = true;
  @Trace sheetTitle: string = '分享到';
  @Trace posterSheetTitle: string = '生成海报';
  @Trace excludedAbilities: (ShareAppType | ShareWay)[] = [];
  @Trace closeSheet: () => void = () => {
  };
  @Trace extraInfo: ExtraInfo = {
    signQQShareData: () => Promise.resolve(new QQShareData()),
    isLayoutFullScreen: false,
  };

  constructor(data?: ShareRecordData) {
    if (!data) {
      return;
    }
    if (data.recordId) {
      this.recordId = data.recordId;
    }
    this.title = data.title;
    this.subTitle = data.subTitle ?? '';
    this.coverUrl = data.coverUrl ?? '';
    this.thumbUrl = data.thumbUrl ?? '';
    this.landingPageUrl = data.landingPageUrl ?? '';
    this.createTime = data.createTime ?? 0;
  }

  /**
   * 设置分享选项
   * @param options
   */
  public setShareOptions(options: ShareOptions) {
    this.extComponentId = options.extComponentId ?? '';
    this.directPoster = options.directPoster ?? false;
    this.autoClose = options.autoClose ?? true;
    this.sheetTitle = options.sheetTitle ?? '分享到';
    this.posterSheetTitle = options.posterSheetTitle ?? '生成海报';
    this.excludedAbilities = options.excludedAbilities ?? [];
  }

  /**
   * 设置关闭半模态方法
   * @param callback
   */
  public setClose(callback: () => void) {
    this.closeSheet = () => {
      callback();
    };
  }
}

/**
 * 分享panelItem
 */
export interface ShareKinds {
  kindId: ShareAppType | ShareWay;
  label: ResourceStr;
  icon: ResourceStr;
  isPoster?: boolean;
}

export class QQShareData extends ShareData {
}

/**
 * QQ分享内容结构体
 */
export interface QQShareContent {
  msgStyle: number;
  title: string;
  summary: string
  brief: string
  url: string;
  pictureUrl: string;
}
