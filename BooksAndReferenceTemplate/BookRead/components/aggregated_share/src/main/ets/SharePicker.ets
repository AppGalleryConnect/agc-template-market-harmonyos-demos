import { ShareViewData, ShareRecordData, ShareOptions, QQShareData } from './common/ShareParams';
import { PopViewUtils } from './utils/PopViewUtils';
import { shareViewBuilder } from './views/ShareView';

/**
 * 拉起分享面板的picker
 */
@ObservedV2
export class SharePicker {
  @Trace private data: ShareViewData = new ShareViewData();
  @Trace private sheetOptions: SheetOptions = {
    showClose: true,
    height: SheetSize.FIT_CONTENT,
    preferType: SheetType.CENTER,
    onTypeDidChange: (type: SheetType) => {
      this.data.sheetType = type;
    },
  };

  constructor(record: ShareRecordData) {
    this.data = new ShareViewData(record);
    this.data.setClose(this.close);
  }

  /**
   * 设置QQ互联分享签名
   * @param callback
   * @returns
   */
  public setSignQQShareDataCB(callback: (shareJson: string) => Promise<QQShareData>): SharePicker {
    this.data.extraInfo.signQQShareData = (shareJson: string) => {
      return callback(shareJson);
    };
    return this;
  }

  /**
   * 设置应用窗口模式
   * @param isLayoutFullScreen
   */
  public setWindowLayoutFullScreen(isLayoutFullScreen: boolean): SharePicker {
    this.data.extraInfo.isLayoutFullScreen = isLayoutFullScreen;
    return this;
  }

  /**
   * 拉起分享半模态弹窗
   * @param options
   */
  public show(options?: ShareOptions): void {
    if (options) {
      this.data.setShareOptions(options);
    }

    PopViewUtils.showSheet<ShareViewData>(wrapBuilder(shareViewBuilder), this.sheetOptions, this.data);
  }

  /**
   * 关闭分享半模态弹窗
   */
  public close(): void {
    PopViewUtils.closeSheet();
  }
}