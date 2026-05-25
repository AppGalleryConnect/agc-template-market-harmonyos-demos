import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { CommonUtils } from '../utils/CommonUtils';
import { ImageUtils } from '../utils/ImageUtils';
import { PopupUtils } from '../utils/PopupUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ObservedV2
export class SnapShotController {
  @Trace showScrollBar: BarState = BarState.On;
  @Trace componentMaskImage: PixelMap | undefined = undefined;
  @Trace snapPopupPosition: Position | undefined = { x: 0, y: 0 };
  @Trace mergedImage: PixelMap | undefined = undefined;
  @Trace isShowPreview: boolean = false;
  @Trace isLargePreview: boolean = false;
  yOffsetBefore: number = 0;
  @Trace curYOffset: number = 0;
  scroller: Scroller;
  screenWidth: number = AppStorage.get('screenWidth') || 0;
  screenHeight: number = AppStorage.get('screenHeight') || 0;
  scrollYOffsets: number[] = [];
  listComponentWidth: number = 0;
  listComponentHeight: number = 0;
  areaArray: image.PositionArea[] = [];
  scrollHeight: number = 0;
  snapShotId: string;
  uiContext: UIContext;

  constructor(snapShotId: string, scroller: Scroller, uiContext: UIContext) {
    this.snapShotId = snapShotId;
    this.scroller = scroller;
    this.uiContext = uiContext;
  }


  private syncViewportSize(): void {
    try {
      const host = this.uiContext.getHostContext();
      if (host) {
        const ctx = host as common.UIAbilityContext;
        const stage = ctx.windowStage;
        if (stage) {
          const win = stage.getMainWindowSync();
          const rect = win.getWindowProperties().windowRect;
          this.screenWidth = this.uiContext.px2vp(rect.width);
          this.screenHeight = this.uiContext.px2vp(rect.height);
        }
      }
    } catch (_e) {
    }
    const w = AppStorage.get<number>('screenWidth');
    const h = AppStorage.get<number>('screenHeight');
    if (typeof w === 'number' && w > 0) {
      this.screenWidth = w;
    }
    if (typeof h === 'number' && h > 0) {
      this.screenHeight = h;
    }
    if (this.screenWidth <= 0) {
      this.screenWidth = 360;
    }
    if (this.screenHeight <= 0) {
      this.screenHeight = 780;
    }
  }

  private async getSnapshotPixelMap(): Promise<PixelMap> {
    try {
      const pixelMap = await this.uiContext.getComponentSnapshot().get(this.snapShotId, {
        waitUntilRenderFinished: true,
      });
      if (!pixelMap) {
        throw new Error('getComponentSnapshot 返回空图');
      }
      return pixelMap;
    } catch (e) {
      const msg = e instanceof Error ? e.message : `${e}`;
      try {
        this.uiContext.getPromptAction().showToast({
          message: `截图失败：${msg}`,
          alignment: Alignment.Center,
          duration: 2000,
        });
      } catch (_ignore) {
      }
      throw (e instanceof Error ? e : new Error(msg));
    }
  }

  onceSnapshot = async () => {
    try {
      this.showScrollBar = BarState.Off;
      await this.beforeSnapshot();
      await this.snapAndMerge();
      await this.afterSnapshot();
      await this.afterGeneratorImage();
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `截图失败: ${JSON.stringify(error)}`);
      // 恢复UI状态
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
      this.isShowPreview = false;
      // 可以在这里添加错误提示
      // PromptUtils.showToast('截图失败，请重试');
    }
  };

  async beforeSnapshot() {
    try {
      this.syncViewportSize();
      this.yOffsetBefore = this.curYOffset;
      // Take a screenshot of the loaded List component as a cover image for the List component
      this.componentMaskImage = await this.getSnapshotPixelMap();
      if (!this.componentMaskImage) {
        throw new Error('获取组件截图失败');
      }

      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: 0,
        animation: {
          duration: 0,
          curve: Curve.Linear,
        },
      });
      await CommonUtils.sleep(80);
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `截图前置处理失败: ${JSON.stringify(error)}`);
      throw new Error(`截图前置处理失败: ${error.message}`);
    }
  }

  async snapAndMerge() {
    try {
      this.scrollYOffsets.push(this.curYOffset);
      // Call the component screenshot interface to obtain the current screenshot
      const pixelMap = await this.getSnapshotPixelMap();
      if (!pixelMap) {
        throw new Error('获取组件截图失败');
      }

      // 嵌入分栏时 onAreaChange 可能尚未给出尺寸，list 为 0 会导致滚动步长与裁剪比例错误
      if (this.listComponentWidth <= 0 || this.listComponentHeight <= 0) {
        const fi = pixelMap.getImageInfoSync();
        const fiW = fi.size.width;
        const fiH = fi.size.height;
        if (fiW > 0 && fiH > 0) {
          this.listComponentWidth = Math.max(1, Math.round(this.uiContext.px2vp(fiW)));
          this.listComponentHeight = Math.max(1, Math.round(this.uiContext.px2vp(fiH)));
          this.scrollHeight = this.listComponentHeight;
        }
      }

      // Gets the number of bytes per line of image pixels.
      let area: image.PositionArea =
        await ImageUtils.getSnapshotArea(this.uiContext, pixelMap, this.scrollYOffsets, this.listComponentWidth,
          this.listComponentHeight);
      this.areaArray.push(area);

      // Determine whether the bottom has been reached during the loop process
      if (!this.scroller.isAtEnd()) {
        CommonUtils.scrollAnimation(this.scroller, 200, this.scrollHeight);
        await CommonUtils.sleep(200);
        await this.snapAndMerge();
      } else {
        this.mergedImage =
          await ImageUtils.mergeImage(this.uiContext, this.areaArray,
            this.scrollYOffsets[this.scrollYOffsets.length - 1],
            this.listComponentWidth, this.listComponentHeight);
        this.syncViewportSize();
        this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenHeight, 200);
        this.isShowPreview = true;
      }
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `截图合并处理失败: ${JSON.stringify(error)}`);
      throw new Error(`截图合并处理失败: ${error.message}`);
    }
  }

  async afterSnapshot() {
    try {
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: this.yOffsetBefore,
        animation: {
          duration: 200,
        },
      });
      await CommonUtils.sleep(200);
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `截图后置处理失败: ${JSON.stringify(error)}`);
      throw new Error(`截图后置处理失败: ${error.message}`);
    }
  }

  async afterGeneratorImage() {
    try {
      // Delay for transition animation
      await CommonUtils.sleep(200);
      this.syncViewportSize();
      this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenHeight, 200);
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `截图后生成图片处理失败: ${JSON.stringify(error)}`);
      // 这里不需要再抛出，因为这是最后的清理步骤
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
    }
  }

  // 添加一个重置方法，用于错误恢复
  reset(): void {
    try {
      this.componentMaskImage = undefined;
      this.mergedImage = undefined;
      this.isShowPreview = false;
      this.isLargePreview = false;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
      this.snapPopupPosition = { x: 0, y: 0 };
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `重置控制器失败: ${JSON.stringify(error)}`);
    }
  }

  // 添加一个安全执行截图的方法，支持自定义错误处理
  async safeSnapshot(onError?: (error: Error) => void): Promise<boolean> {
    try {
      await this.onceSnapshot();
      return true;
    } catch (error) {
      hilog.error(0x0000, 'SnapShot', `安全执行截图失败: ${JSON.stringify(error)}`);
      onError?.(error as Error);
      this.reset();
      return false;
    }
  }
}