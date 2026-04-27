import { image } from '@kit.ImageKit';
import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { WEB_ID } from '../commons/Constant';
import { CommonUtils } from '../utils/CommonUtils';
import { Logger } from '../utils/Logger';
import { PopupUtils } from '../utils/PopupUtils';
import { WindowUtil } from '../utils/WindowUtil';

const TAG = '[SnapShotWebController]'

@ObservedV2
export class SnapShotWebController {
  // 网页尺寸
  @Trace h5Width: number = 0;
  @Trace h5Height: number = 0;
  // Web组件尺寸
  @Trace webWidth: number = 0;
  @Trace webHeight: number = 0;
  // 当前网页位置
  @Trace curXOffset: number = 0;
  @Trace curYOffset: number = 0;
  // 备份当前网页位置
  @Trace xOffsetBefore: number = 0;
  @Trace yOffsetBefore: number = 0;
  // 截图过程的Web组件覆盖
  @Trace webMaskImage: PixelMap | undefined = undefined;
  @Trace webMaskImageZIndex: number = -1;
  // 合并后的图片
  @Trace mergedImage: PixelMap | undefined = undefined;
  // 截图后小窗大小
  @Trace snapPopupWidth: number = 100;
  @Trace snapPopupHeight: number = 200;
  @Trace snapPopupPosition: Position = { x: 0, y: 0 };
  // 是否显示预览窗口
  @Trace isShowPreview: boolean = false;
  @Trace showPreview: boolean = false;

  @Trace isLargePreview: boolean = false;

  //Web是否已经滚动到底部
  @Trace webTouchBottom: boolean = false;
  // 屏幕尺寸
  @Trace displayWidth: number = 0;
  @Trace displayHeight: number = 0;

  webviewController: webview.WebviewController = new webview.WebviewController();

  constructor(controller: webview.WebviewController) {
    this.webviewController = controller
  }

  /**
   * 截图函数。
   */
  async snapShot() {
    // 获取Web页面尺寸
    this.getWebSize();
    // 截图前的状态初始化
    await this.beforeSnapshot();
    // 使用Canvas离屏绘制在缓冲区拼接截图
    const canvasSetting: RenderingContextSettings = new RenderingContextSettings(true);
    const offCanvasCtx: OffscreenCanvasRenderingContext2D =
      new OffscreenCanvasRenderingContext2D(this.h5Width, this.h5Height, canvasSetting);
    // 前置常量
    const snipTimes = Math.ceil(this.h5Height / this.webHeight);
    const lastTime = snipTimes - 1;
    const leftoverHeight = this.h5Height % this.webHeight;
    let cropLeftover: image.Region = { x: 0, y: 0, size: { height: 0, width: 0 } }
    if (this.webTouchBottom) {
      // 这里要分两种情况，1.滚动到底部时，裁剪应该取最后一张除去重复部分以外的底部
      cropLeftover = {
        x: 0,
        y: WindowUtil.uiContext.vp2px(this.webHeight - leftoverHeight),
        size: {
          height: WindowUtil.uiContext.vp2px(leftoverHeight),
          width: WindowUtil.uiContext.vp2px(this.webWidth)
        }
      };
    } else {
      // 2.未滚动到底部时，裁剪应该取最后一张leftoverHeight的上部分
      cropLeftover = {
        x: 0,
        y: 0,
        size: {
          height: WindowUtil.uiContext.vp2px(leftoverHeight),
          width: WindowUtil.uiContext.vp2px(this.webWidth)
        }
      };
    }

    // 开始截图
    for (let i = 0; i < snipTimes; i++) {
      const curSnip = await WindowUtil.uiContext.getComponentSnapshot().get(WEB_ID);
      // 最后一次截图需要特殊处理，去除重复部分
      if (i === lastTime) {
        await curSnip.crop(cropLeftover);
        offCanvasCtx.drawImage(curSnip, 0, this.webHeight * i, this.webWidth, leftoverHeight);
      } else {
        offCanvasCtx.drawImage(curSnip, 0, this.webHeight * i, this.webWidth, this.webHeight);
      }
      // 继续滚动
      this.webviewController.scrollBy(0, this.webHeight);
      // 延时保证滚动完成
      await CommonUtils.sleep(200);
    }
    // 截图后的操作
    await this.afterSnapshot();
    // 获取pixelMap
    this.mergedImage = offCanvasCtx.getPixelMap(0, 0, this.h5Width, this.h5Height);
    // 拼接之后修改可动画变量
    this.afterGeneratorImage();

    // 等待动画效果结束，再赋值
    setTimeout(() => {
      this.isLargePreview = true;
      this.webMaskImage = undefined;
      this.webMaskImageZIndex = -1;
    }, 600)
  }

  /**
   * 截图前获取尺寸
   */
  getWebSize() {
    const SCRIPT = '[document.documentElement.scrollWidth, document.documentElement.scrollHeight]';
    this.webviewController.runJavaScriptExt(SCRIPT).then((result) => {
      try {
        switch (result.getType()) {
          case webview.JsMessageType.ARRAY:
            this.h5Width = (result.getArray() as number[])[0]; // 单位是vp
            this.h5Height = (result.getArray() as number[])[1];
            Logger.info(TAG, `h5Width = ${this.h5Width}, h5Height = ${this.h5Height}`);
            break;
          default:
            Logger.error(TAG, `Get web page size tyep error.`);
            break;
        }
      } catch (e) {
        const err = e as BusinessError;
        Logger.error(TAG,
          `Run script to get web page size failed. ErrorCode: ${err.code}, Message: ${err.message}`);
      }
    });
  }

  /**
   * 截图开始前的操作。
   * - 保存网页当前位置，用于恢复状态
   * - 截图当前页面作为遮罩层，避免用户察觉组件的滚动，提高用户体验
   * - Web页面滚动到顶部，准备开始截图
   * - 设置截图后小弹窗的位置，提示用户暂时不要操作，等待截图
   * - 开启提示小弹窗
   */
  async beforeSnapshot() {
    // 保存网页当前位置，用于恢复
    this.xOffsetBefore = this.curXOffset;
    this.yOffsetBefore = this.curYOffset;
    this.h5Height = this.curYOffset + Math.ceil(this.webHeight);
    // 使用componentSnapshot.get接口直接获取组件的渲染结果，而不需要将屏幕截图
    this.webMaskImage = await WindowUtil.uiContext.getComponentSnapshot().get(WEB_ID);
    this.webMaskImageZIndex = 2;
    this.webviewController.scrollTo(0, 0);
    ToastDialog.showToast({
      message: '正在截图，请勿操作...',
      duration: 2000
    });
    this.snapPopupPosition = PopupUtils.calcPopupCenter(
      this.displayWidth,
      this.displayHeight,
      this.snapPopupWidth,
      this.snapPopupHeight
    );
    this.isShowPreview = true;
    // 延时确保已经滚动到了顶部
    await CommonUtils.sleep(200);
  }

  /**
   * 截图之后的操作。
   * - 恢复web页面到截图之前的位置
   * - 取消遮罩层
   */
  async afterSnapshot() {
    this.webviewController.scrollTo(this.xOffsetBefore, this.yOffsetBefore);
    await CommonUtils.sleep(200);
    this.webMaskImageZIndex = -1;
    this.webMaskImage = undefined;
  }

  /**
   * 生成拼接后图片的操作。用于窗口形成移动的动画。
   */
  async afterGeneratorImage() {
    // 小窗在屏幕中间短暂停留，避免位置突变，无法形成动画
    await CommonUtils.sleep(200);
    // 修改弹窗位置，形成移动动画
    this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.displayHeight, this.snapPopupHeight)
  }
}