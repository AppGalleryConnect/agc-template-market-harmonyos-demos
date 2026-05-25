import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';

/** 隔空传送：单条笔记内容 JSON 的 payload 类型（B 端用于创建新笔记） */
export interface NoteSharePayload {
  title: string;
  categoryId: string;
  serializedStyledString: string;
  description: string;
  createTime: string;
  updateTime: string;
}

/** URI 总长上限，富文本序列化后可能较大，超长则仅分享链接 */
const MAX_IMPORT_URI_LENGTH = 16000;

export class GesturesShareService {
  private static instance: GesturesShareService;
  private context: common.UIAbilityContext | undefined = undefined;
  private windowId: number | null = null;
  // 存储当前笔记数据
  private currentNoteId: string = '';
  private currentNoteTitle: string = '';
  /** 同步返回缓存的笔记 JSON，用于隔空传送；有值则传内容，无值则仅传链接 */
  private notePayloadGetter: (() => string | null) | undefined = undefined;

  private constructor() {

  }

  public static getInstance(context?: common.UIAbilityContext): GesturesShareService {
    if (!GesturesShareService.instance) {
      GesturesShareService.instance = new GesturesShareService();
    }
    if (context) {
      GesturesShareService.instance.context = context;
    }
    return GesturesShareService.instance;
  }

  /**
   * 设置当前笔记信息（在EditNotes中调用）
   */
  public setCurrentNote(noteId: string, noteTitle: string): void {
    this.currentNoteId = noteId;
    this.currentNoteTitle = noteTitle;
    hilog.info(0x0000, 'GesturesShare', `设置当前笔记: ${noteId} - ${noteTitle}`);
  }

  /**
   * 设置同步 getter：返回当前笔记内容的 JSON 字符串（由编辑页定时缓存），无缓存时返回 null 则仅传链接
   */
  public setNotePayloadGetter(getter: (() => string | null) | undefined): void {
    this.notePayloadGetter = getter;
  }

  /**
   * 开始监听隔空传送手势
   */
  public startGestureListening(): void {
    if (!canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      hilog.warn(0x0000, 'GesturesShare', '设备不支持隔空传送');
      return;
    }

    if (!this.context) {
      hilog.error(0x0000, 'GesturesShare', 'context未设置，无法监听');
      return;
    }

    window.getLastWindow(this.context).then((windowInstance) => {
      try {
        this.windowId = windowInstance.getWindowProperties().id;
        harmonyShare.on('gesturesShare', { windowId: this.windowId }, (target) => {
          this.onGestureTriggered(target);
        });
        hilog.info(0x0000, 'GesturesShare', '开始监听隔空传送手势');
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(0x0000, 'GesturesShare', `监听失败: ${error.code} ${error.message}`);
      }
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, 'GesturesShare', `获取窗口失败: ${error.code} ${error.message}`);
    });
  }

  /**
   * 停止监听隔空传送手势
   */
  public stopGestureListening(): void {
    if (!canIUse('SystemCapability.Collaboration.HarmonyShare') || !this.windowId) {
      return;
    }

    try {
      harmonyShare.off('gesturesShare', { windowId: this.windowId });
      hilog.info(0x0000, 'GesturesShare', '停止监听隔空传送手势');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `取消监听失败: ${err.code} ${err.message}`);
    }
  }

  /**
   * 手势触发时的回调：
   * - 笔记内容较少：像之前一样以链接形式传递，并且把标题和内容编码到链接里；
   * - 笔记内容很长：以纯文本方式传递。
   */
  private onGestureTriggered(target: harmonyShare.SharableTarget): void {
    const baseTitle = this.currentNoteTitle || '我的笔记';
    const baseOpenLink = `https://notes.app/open?` +
      `noteId=${encodeURIComponent(this.currentNoteId)}&` +
      `title=${encodeURIComponent(baseTitle)}`;

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: baseOpenLink,
      title: baseTitle,
      description: '点击查看笔记内容',
    });

    // 如果有缓存的笔记内容，根据长度决定：
    // - 内容较少：把 payload 编码进链接里（B 端可从链接中解析标题和内容）；
    // - 内容很长：以纯文本形式传过去。
    if (this.notePayloadGetter) {
      const payloadJson = this.notePayloadGetter();
      if (payloadJson && payloadJson.length > 0) {
        // 把 JSON 做 base64 编码，再作为 payload 参数塞进链接中
        const payloadBase64 = this.base64Encode(payloadJson);
        const appLinkWithPayload = `${baseOpenLink}&payload=${encodeURIComponent(payloadBase64)}`;

        if (appLinkWithPayload.length <= MAX_IMPORT_URI_LENGTH) {
          // 笔记标题和内容比较少：仍然以链接形式传递（链接里带有完整信息）
          shareData = new systemShare.SharedData({
            utd: utd.UniformDataType.HYPERLINK,
            content: appLinkWithPayload,
            title: baseTitle,
            description: '点击在另一台设备中打开并导入笔记',
          });
          hilog.info(0x0000, 'GesturesShare', '分享笔记链接(内嵌payload)');
        } else {
          // 笔记内容非常多：以纯文本形式传递 payload，保持“暂无可用打开方式”等系统弹框行为
          const payloadText = `NOTES_IMPORT:${payloadJson}`;
          shareData = new systemShare.SharedData({
            utd: utd.UniformDataType.PLAIN_TEXT,
            content: payloadText,
            title: baseTitle,
            description: '隔空传送笔记内容（纯文本）',
          });
          hilog.warn(0x0000, 'GesturesShare', '笔记内容过长，改为纯文本分享');
        }
      } else {
        hilog.info(0x0000, 'GesturesShare', '无缓存，分享基础笔记链接');
      }
    }

    try {
      target.share(shareData);
      hilog.info(0x0000, 'GesturesShare', '分享笔记完成');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `分享失败: ${err.code} ${err.message}`);
    }
  }

  private static readonly BASE64_CHARS: string =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  private base64Encode(str: string): string {
    let bytes: Uint8Array;
    try {
      const encoder = new util.TextEncoder();
      bytes = encoder.encodeInto(str);
    } catch (e) {
      const err = e as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `base64Encode encodeInto failed: ${err.code} ${err.message}`);
      return '';
    }
    let result = '';
    for (let i = 0; i < bytes.length; i += 3) {
      const b0 = bytes[i];
      const b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      const b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      result += GesturesShareService.BASE64_CHARS[b0 >> 2];
      result += GesturesShareService.BASE64_CHARS[((b0 & 3) << 4) | (b1 >> 4)];
      result += (i + 1 < bytes.length) ? GesturesShareService.BASE64_CHARS[((b1 & 15) << 2) | (b2 >> 6)] : '=';
      result += (i + 2 < bytes.length) ? GesturesShareService.BASE64_CHARS[b2 & 63] : '=';
    }
    return result;
  }
}
