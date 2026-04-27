import { image } from '@kit.ImageKit';
import { CommonUtils } from '../utils/CommonUtils';
import { ImageUtils } from '../utils/ImageUtils';
import { PopupUtils } from '../utils/PopupUtils';
import { WindowUtil } from '../utils/WindowUtil';


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

  constructor(snapShotId: string, scroller: Scroller) {
    this.snapShotId = snapShotId;
    this.scroller = scroller;
  }

  onceSnapshot = async () => {
    this.showScrollBar = BarState.Off;
    await this.beforeSnapshot();
    await this.snapAndMerge();
    await this.afterSnapshot();
    this.afterGeneratorImage();
  };

  async beforeSnapshot() {
    this.yOffsetBefore = this.curYOffset;
    // Take a screenshot of the loaded List component as a cover image for the List component
    this.componentMaskImage = await WindowUtil.uiContext.getComponentSnapshot().get(this.snapShotId);
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation:
      {
        duration: 200,
      },
    });
    this.snapPopupPosition = PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, 100, 200);
    this.isShowPreview = true;
    // Delay ensures that the scroll has reached the top
    await CommonUtils.sleep(200);
  }

  async snapAndMerge() {
    this.scrollYOffsets.push(this.curYOffset);
    // Call the component screenshot interface to obtain the current screenshot
    const pixelMap = await WindowUtil.uiContext.getComponentSnapshot().get(this.snapShotId);
    // Gets the number of bytes per line of image pixels.
    let area: image.PositionArea =
      await ImageUtils.getSnapshotArea(pixelMap, this.scrollYOffsets, this.listComponentWidth,
        this.listComponentHeight);
    this.areaArray.push(area);
    // Determine whether the bottom has been reached during the loop process
    if (!this.scroller.isAtEnd()) {
      CommonUtils.scrollAnimation(this.scroller, 200, this.scrollHeight);
      await CommonUtils.sleep(200);
      await this.snapAndMerge();
    } else {
      this.mergedImage =
        await ImageUtils.mergeImage(this.areaArray, this.scrollYOffsets[this.scrollYOffsets.length - 1],
          this.listComponentWidth, this.listComponentHeight);
    }
  }

  async afterSnapshot() {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: this.yOffsetBefore,
      animation: {
        duration: 200,
      },
    });
    await CommonUtils.sleep(200);
  }

  async afterGeneratorImage() {
    // Delay for transition animation
    await CommonUtils.sleep(200);
    this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenHeight, 200);
    this.componentMaskImage = undefined;
    this.scrollYOffsets.length = 0;
    this.areaArray.length = 0;
    this.showScrollBar = BarState.On;
  }
}