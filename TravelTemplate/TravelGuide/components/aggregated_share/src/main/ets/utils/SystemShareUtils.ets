import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { ShareViewData } from '../common/ShareParams';
import { Logger } from '../common/Logger';
import { downloadImage, saveToSandbox } from './FileUtils';

const TAG = 'SystemShareUtils';

/**
 * 系统分享
 */
export class SystemShareUtils {
  private static _instance: SystemShareUtils;
  private shareData: systemShare.SharedData = new systemShare.SharedData({
    utd: utd.UniformDataType.TEXT,
  });

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
  public async init(data: ShareViewData) {
    this.shareData = await this.getShareData(data);
  }

  /**
   * 拉起系统分享面板
   * @param data
   */
  public share(): Promise<void> {
    return new Promise((resolve, reject) => {
      const controller: systemShare.ShareController = new systemShare.ShareController(this.shareData);
      return controller.show(getContext(this) as common.UIAbilityContext, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DEFAULT,
      }).then(() => {
        resolve();
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `ShareController show error. code: ${error.code}, message: ${error.message}`);
        promptAction.showToast({ message: '拉起系统分享出错' });
        reject();
      });
    });
  }

  /**
   * 发起碰一碰
   */
  private callback = async (sharableTarget: harmonyShare.SharableTarget) => {
    sharableTarget.share(this.shareData);
  }

  /**
   * 监听碰一碰
   */
  public onKnockShare() {
    harmonyShare.on('knockShare', this.callback);
  }

  /**
   * 取消监听碰一碰
   */
  public offKnockShare() {
    harmonyShare.off('knockShare', this.callback);
  }

  /**
   * 获取华为分享的数据
   * @param data
   * @returns
   */
  private async getShareData(data: ShareViewData) {
    const content = this.getContent(data);
    const thumbUri = await this.getThumbnail(data.thumbUrl);

    const shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: data.landingPageUrl ? utd.UniformDataType.HYPERLINK : utd.UniformDataType.TEXT,
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
          thumbBuffer = await downloadImage(thumbUrl);
        } else {
          const content = await getContext(this).resourceManager.getMediaContent(thumbUrl);
          thumbBuffer = content.buffer as ArrayBuffer;
        }
        thumbUri = await saveToSandbox(thumbBuffer);
      }
    } catch (e) {
      Logger.error(TAG, 'getThumbnail failed, error: ' + JSON.stringify(e));
    }

    return thumbUri;
  }

  /**
   * 复制内容到剪切板
   * @param data
   */
  public copy(data: ShareViewData) {
    try {
      const pasteboardData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, `${data.title} | ${data.landingPageUrl}`);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData);
      promptAction.showToast({ message: '复制成功' });
    } catch (err) {
    }
  }
}