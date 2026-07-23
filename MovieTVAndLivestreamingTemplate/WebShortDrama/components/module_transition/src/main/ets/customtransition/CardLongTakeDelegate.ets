import { image } from '@kit.ImageKit';
import { curves } from '@kit.ArkUI';
import { SnapShotImage } from '../utils/SnapShotImage';
import { CustomTransition } from '../utils/CustomNavigationUtils';
import { LongTakeAnimationProperties } from '../sessions/LongTakeAnimationProperties';
import { LongTakeTransitionConstants } from '../constants/LongTakeTransitionConstants';

const MIN_SCALE_VALUE: number = 0.5;
const RETURN_TO_PRE_PAGE_SCALE_VALUE = 0.85;

@ComponentV2
export struct CardLongTakeDelegate {
  @BuilderParam contentBuilder: () => void;
  @Param @Require longTakeSession: LongTakeAnimationProperties;
  @Local snapShotImage: image.PixelMap | undefined = undefined;
  @Local windowSizeChangedTime: number = 0;
  private rectWidth: number = 0;
  private scaleValue: number = 0;
  private animationCount: number = 0;
  private isChanged: boolean = false;

  aboutToAppear(): void {
    if (!this.snapShotImage) {
      this.snapShotImage = SnapShotImage.pixelMap;
    }
  }

  unRegisterNavParam(): void {
    CustomTransition.getInstance().unRegisterNavParam(this.longTakeSession.getNavDestinationId());
  }

  @Styles
  ExitGestureStyle() {
    .gesture(
      PanGesture({ direction: PanDirection.Right })
        .onActionStart((event: GestureEvent) => {
          if (this.longTakeSession.getTransitionParam().options?.isGestureEnabled !== undefined &&
            !this.longTakeSession.getTransitionParam().options?.isGestureEnabled) {
            return;
          }
          CustomTransition.getInstance().interactive = true;
          this.longTakeSession.options?.pop();
          this.rectWidth = event.target.area.width as number;
          this.longTakeSession.radius = 9;
          this.longTakeSession.options?.onBackGestureStart?.();
          let deltaX = event.offsetX;
          let deltaY = event.offsetY;
          this.scaleValue =
            Math.max(1 - (1 - MIN_SCALE_VALUE) * Math.abs(deltaX) / this.rectWidth, MIN_SCALE_VALUE);
          this.getUIContext().animateTo({
            curve: curves.responsiveSpringMotion(),
          }, () => {
            this.longTakeSession.translateX = deltaX;
            this.longTakeSession.translateY = deltaY;
            this.longTakeSession.scaleValue = this.scaleValue;
          })
          ++this.animationCount;
        })
        .onActionUpdate((event: GestureEvent) => {
          if (this.longTakeSession.getTransitionParam().options?.isGestureEnabled !== undefined &&
            !this.longTakeSession.getTransitionParam().options?.isGestureEnabled) {
            return;
          }
          if (CustomTransition.getInstance().interactive) {
            let deltaX = event.offsetX;
            let deltaY = event.offsetY;
            this.scaleValue =
              Math.max(1 - (1 - MIN_SCALE_VALUE) * Math.abs(deltaX) / this.rectWidth, MIN_SCALE_VALUE);
            this.getUIContext().animateTo({
              curve: curves.responsiveSpringMotion(),
            }, () => {
              this.longTakeSession.translateX = deltaX;
              this.longTakeSession.translateY = deltaY;
              this.longTakeSession.scaleValue = this.scaleValue;
            })
          }
        })
        .onActionEnd((event: GestureEvent) => {
          if (this.longTakeSession.getTransitionParam().options?.isGestureEnabled !== undefined &&
            !this.longTakeSession.getTransitionParam().options?.isGestureEnabled) {
            return;
          }
          if (CustomTransition.getInstance().interactive) {
            let currentTransitionProxy = CustomTransition.getInstance().proxy;
            let deltaX = event.offsetX;
            this.scaleValue =
              Math.max(1 - (1 - MIN_SCALE_VALUE) * Math.abs(deltaX) / this.rectWidth, MIN_SCALE_VALUE);
            if (this.scaleValue > RETURN_TO_PRE_PAGE_SCALE_VALUE) {
              this.longTakeSession.options?.onRecoverStart?.();
              let animationCount = ++this.animationCount;
              this.getUIContext().animateTo({
                curve: curves.springMotion(),
                onFinish: () => {
                  if (currentTransitionProxy?.cancelTransition) {
                    currentTransitionProxy?.cancelTransition();
                  }
                  if (animationCount === this.animationCount) {
                    this.longTakeSession.radius = 0;
                    this.longTakeSession.options?.onRecoverEnd?.();
                  }
                },
              }, () => {
                this.longTakeSession.translateX = 0;
                this.longTakeSession.translateY = 0;
                this.longTakeSession.scaleValue = 1;
              })
            } else {
              this.longTakeSession.doBackAnimation(currentTransitionProxy, this.isChanged);
            }
            CustomTransition.getInstance().interactive = false;
          }
        })
        .onActionCancel(() => {
          if (this.longTakeSession.getTransitionParam().options?.isGestureEnabled !== undefined &&
            !this.longTakeSession.getTransitionParam().options?.isGestureEnabled) {
            return;
          }
          this.longTakeSession.translateX = 0;
          this.longTakeSession.translateY = 0;
          this.longTakeSession.scaleValue = 1;
          this.longTakeSession.radius = 0;
          CustomTransition.getInstance().proxy?.cancelTransition?.();
          CustomTransition.getInstance().interactive = false;
        }),
    )
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 弹出页原本展示的内容，添加透明度控制其动画过程中的显示
      Stack({ alignContent: Alignment.Top }) {
        this.contentBuilder()
      }
      .opacity(this.longTakeSession.postPageOpacity)
      .position({ x: this.longTakeSession.positionXValue, y: this.longTakeSession.positionYValue })
      .size({ width: this.longTakeSession.navDestSize.width, height: this.longTakeSession.navDestSize.height })

      if (this.longTakeSession) {
        Stack({ alignContent: Alignment.Top }) {
          // 用于显示上一页所点击的卡片的截图
          Image(this.snapShotImage)
            .size(this.longTakeSession.snapShotSize)
            .objectFit(ImageFit.Auto)
            .syncLoad(true)// 等待截图同步加载，这样不会出现闪白或跳变的问题
            // 此处的position要给的是从截图位置到展开页图片位置的距离
            .position({
              x: this.longTakeSession.snapShotPositionX,
              y: this.longTakeSession.snapShotPositionY,
            })
            .focusable(false)
            .enabled(false)
        }
        .accessibilityLevel('no')
        .focusable(false)
        .enabled(false)
        .id(this.longTakeSession.getNavDestinationId() + LongTakeTransitionConstants.POST_PAGE_SNAPSHOT_STACK_ID)
        .width('100%')
        .position({ x: this.longTakeSession.positionXValue, y: this.longTakeSession.positionYValue })
        .opacity(this.longTakeSession.snapShotOpacity)
      }
    }
    .accessibilityLevel('no')
    .id(this.longTakeSession.getNavDestinationId() + LongTakeTransitionConstants.POST_PAGE_STACK_ID)
    .scale({ x: this.longTakeSession.scaleValue, y: this.longTakeSession.scaleValue })
    .translate({
      x: this.longTakeSession.translateX,
      y: this.longTakeSession.translateY,
    })
    .width(this.longTakeSession.clipWidth)
    .height(this.longTakeSession.clipHeight)
    .borderRadius(this.longTakeSession.radius)
    // expandSafeArea使得Stack做沉浸式效果，向上扩到状态栏，向下扩到导航条
    .expandSafeArea([SafeAreaType.SYSTEM])
    // 对高度进行裁切
    .clip(true)
    .onDisAppear(() => {
      this.unRegisterNavParam();
    })
    .ExitGestureStyle()
  }
}