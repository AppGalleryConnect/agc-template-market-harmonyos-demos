import { window } from '@kit.ArkUI';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { ShareViewData } from '../common/ShareParams';
import { downloadImage, saveToSandbox, base64ToSandbox, isBase64Path, isSandboxPath } from './FileUtils';
import { ShareContentType } from '../common/ShareEnum';

const TAG = '[SystemShareUtils]';

/**
 * 系统分享
 */
export class SystemShareUtils {
  private static _instance: SystemShareUtils;
  private shareData: systemShare.SharedData = new systemShare.SharedData({
    utd: utd.UniformDataType.TEXT,
  });
  private uiContext: UIContext | undefined = undefined;

  /**
   * 获取实例
   * @returns
   */
  public static get instance() {
    if (!SystemShareUtils._instance) {
      SystemShareUtils._instance = new SystemShareUtils();
    }
    return SystemShareUtils._instance;
  }

  /**
   * 初始化数据
   * @param data
   */
  public async init(uiContext: UIContext, data: ShareViewData) {
    this.uiContext = uiContext;
    this.shareData = await this.getShareData(data);
  }

  /**
   * 拉起系统分享面板
   * @param data
   */
  public share(uiContext: UIContext): Promise<void> {
    return new Promise((resolve, reject) => {
      const controller: systemShare.ShareController = new systemShare.ShareController(this.shareData);
      return controller.show(uiContext.getHostContext() as common.UIAbilityContext, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DEFAULT,
      }).then(() => {
        resolve();
      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, `ShareController show error. code: ${error.code}, message: ${error.message}`);
        promptAction.showToast({ message: '拉起系统分享出错' });
        reject();
      });
    });
  }

  /**
   * 碰一碰回调
   */
  private knockCallback: Callback<harmonyShare.SharableTarget> = (sharableTarget: harmonyShare.SharableTarget) => {
    sharableTarget.share(this.shareData);
  }

  /**
   * 监听碰一碰
   */
  public onKnockShare() {
    harmonyShare.on('knockShare', this.knockCallback);
  }

  /**
   * 取消监听碰一碰
   */
  public offKnockShare() {
    harmonyShare.off('knockShare', this.knockCallback);
  }

  /**
   * 隔空传送回调
   */
  private gestureCallback: Callback<harmonyShare.SharableTarget> = (target: harmonyShare.SharableTarget) => {
    target.share(this.shareData);
  }

  /**
   * 注册隔空传送的事件监听
   */
  public onGestureShare() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      const context = this.uiContext?.getHostContext() as Context;
      window.getLastWindow(context).then((data) => {
        try {
          const mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.on('gesturesShare', { windowId: mainWindowID }, (target: harmonyShare.SharableTarget) => {
            this.gestureCallback(target);
          });
        } catch (error) {
          UtilLog.error(TAG, `getWindowProperties error: ${error.code} ${error.message}`);
        }
      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, `registerGestureShareListener getLastWindow error: ${error.code} ${error.message}`);
      })
    }
  }

  /**
   * 取消注册隔空传送的事件监听
   */
  public offGestureShare() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      const context = this.uiContext?.getHostContext() as Context;
      window.getLastWindow(context).then((data) => {
        try {
          const mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.off('gesturesShare', { windowId: mainWindowID }, this.gestureCallback);
        } catch (error) {
          UtilLog.error(TAG, `getWindowProperties error ${error.code} ${error.message}`);
        }
      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, `unRegisterGestureShareListener getLastWindow error ${error.code} ${error.message}`);
      })
    }
  }

  /**
   * 获取华为分享的数据
   * @param data
   * @returns
   */
  private async getShareData(data: ShareViewData) {
    if (data.shareType === ShareContentType.IMAGE) {
      return await this.getImageShareData(data);
    }
    const content = this.getContent(data);
    const thumbUri = await this.getThumbnail(data.thumbUrl || data.coverUrl);

    const shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: (data.landingPageUrl || thumbUri) ? utd.UniformDataType.HYPERLINK : utd.UniformDataType.TEXT,
      title: data.title,
      description: data.subTitle,
      content: content,
      thumbnailUri: thumbUri,
    });

    return shareData;
  }

  /**
   * 获取分享内容
   * @param data
   * @returns
   */
  private getContent(data: ShareViewData) {
    if (data.landingPageUrl) {
      return data.landingPageUrl;
    }
    if (data.subTitle) {
      return `${data.title} | ${data.subTitle}`;
    }
    return data.title;
  }

  /**
   * 获取缩略图
   * @param thumbUrl
   * @returns
   */
  private async getThumbnail(thumbUrl: ResourceStr) {
    let thumbUri: string = '';

    try {
      if (thumbUrl) {
        let thumbBuffer = new ArrayBuffer(100);
        if (typeof thumbUrl === 'string') {
          if (isBase64Path(thumbUrl)) {
            thumbUri = await base64ToSandbox(this.uiContext!, thumbUrl);
            return thumbUri;
          }
          if (isSandboxPath(thumbUrl)) {
            thumbUri = thumbUrl;
            return thumbUri;
          }
          thumbBuffer = await downloadImage(thumbUrl);
        } else {
          if (this.uiContext) {
            const context = this.uiContext.getHostContext() as Context;
            const content = await context.resourceManager.getMediaContent(thumbUrl.id);
            thumbBuffer = content.buffer as ArrayBuffer;
          }
        }
        if (this.uiContext) {
          thumbUri = await saveToSandbox(this.uiContext, thumbBuffer);
        }
      }
    } catch (e) {
      UtilLog.error(TAG, 'getThumbnail failed, error: ' + JSON.stringify(e));
    }

    return thumbUri;
  }

  /**
   * 复制内容到剪切板
   * @param data
   */
  public async copy(data: ShareViewData) {
    try {
      const pasteboardData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, `${data.title} | ${data.landingPageUrl}`);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteboardData);
      promptAction.showToast({ message: '复制成功' });
    } catch (err) {
      UtilLog.error(TAG, `Failed to creat data, errCode: ${err.code}, errMessage: ${err.message}`);
    }
  }

  /**
   * 获取图片分享数据
   * @param data
   * @param image
   * @returns
   */
  private async getImageShareData(data: ShareViewData): Promise<systemShare.SharedData> {
    try {
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.IMAGE,
        uri: data.imageUri,
        title: data.title,
        description: data.subTitle,
      });

      return shareData;
    } catch (e) {
      UtilLog.error(TAG, `getImageShareData failed, error: ${JSON.stringify(e)}`);
      return new systemShare.SharedData({
        utd: utd.UniformDataType.IMAGE,
      });
    }
  }
}