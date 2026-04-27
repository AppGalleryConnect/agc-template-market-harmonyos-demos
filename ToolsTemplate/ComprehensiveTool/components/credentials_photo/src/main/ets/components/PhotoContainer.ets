import { matrix4 } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { PhotoContainerController } from '../model/Index';


@ComponentV2
export struct PhotoContainer {
  @Param controller: PhotoContainerController = new PhotoContainerController();
  // 人像
  @Param photoUrl: image.PixelMap | ResourceStr = '';
  // 衣服
  @Param dressUrl: ResourceStr | undefined = undefined;
  // 背景色
  @Param backColor: ResourceColor = $r('sys.color.icon_on_primary');
  // 长宽比
  @Param ratio: number = 1;
  // 外层容器宽高
  @Local containerWidth: number = 240;
  @Local containerHeight: number = this.containerWidth * this.ratio;
  @Local mScale: number = 1.0;
  @Local mBaseScale: number = 1.0;
  @Local matrix: matrix4.Matrix4Transit = matrix4.identity();
  @Local offsetX: number = 0;
  @Local offsetY: number = 0;
  @Local startOffsetX: number = 0;
  @Local startOffsetY: number = 0;
  @Local sensitivity: number = 1;
  // 图片宽高
  private componentWidth: number = 0;
  private componentHeight: number = 0;
  private MAX_SCALE: number = 1.6;
  private MIN_SCALE: number = 0.7;
  // 容器id
  private containerId: string = 'PhotoContainer';
  // 截图完成
  @Event onSnapshot: (pixmap: image.PixelMap) => void = () => {

  };

  aboutToAppear(): void {
    this.controller.snip = this.snip;
  }

  handlePinchUpdate(event: PinchGestureEvent) {
    let currentScale: number = this.mBaseScale * event.scale;
    if (currentScale > this.MAX_SCALE) {
      this.mScale = this.MAX_SCALE;
    } else if (currentScale < this.MIN_SCALE) {
      this.mScale = this.MIN_SCALE;
      this.startOffsetX = 0;
      this.startOffsetY = 0;
      this.offsetX = 0;
      this.offsetY = 0;
    } else {
      this.mScale = currentScale;
    }
    this.getUIContext().animateTo({ duration: 100, curve: Curve.EaseOut }, () => {
      this.updateMatrix();
    });
  }

  // 限制移动偏移
  handleOffset(event: PanGestureEvent) {
    let distanceX: number = this.startOffsetX + event.offsetX;
    let distanceY: number = this.startOffsetY + event.offsetY;
    // 内容缩放后的实际尺寸
    const scaledWidth = this.componentWidth * this.mScale;
    const scaledHeight = this.componentHeight * this.mScale;
    // x轴方向最多出去1/2
    if (distanceX >= 0) {
      distanceX = Math.min(distanceX, this.containerWidth - scaledWidth / 2);
    }
    if (distanceX < 0) {
      distanceX = Math.max(distanceX, scaledWidth / 2 - this.containerWidth);
    }

    if (distanceY >= 0) {
      distanceY = Math.min(distanceY, scaledHeight / 2);
    }

    if (distanceY < 0) {
      distanceY = Math.max(distanceY, this.componentHeight - this.containerHeight - scaledHeight / 2);
    }

    return [distanceX, distanceY];
  }

  public updateMatrix(): void {
    this.matrix = matrix4.identity()
      .scale({
        x: this.mScale,
        y: this.mScale,
      })
      .translate({ x: this.getUIContext().vp2px(this.offsetX), y: this.getUIContext().vp2px(this.offsetY) });
  }

  build() {
    Stack() {
      Image(this.photoUrl).width('100%');
      if (this.dressUrl) {
        Image(this.dressUrl)
          .objectFit(ImageFit.Contain)
          .transform(this.matrix)
          .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
            this.componentWidth = newValue.width as number;
            this.componentHeight = newValue.height as number;
          })
          .width('100%')
          .gesture(
            GestureGroup(GestureMode.Exclusive, // 互斥模式
              PinchGesture({ fingers: 2, distance: 1 }) // 双指最小5vp触发
                .onActionStart(() => {
                  this.mBaseScale = this.mScale;
                })
                .onActionUpdate((event: PinchGestureEvent) => {
                  this.handlePinchUpdate(event); // 缩放事件处理
                }),
              PanGesture({ fingers: 1 }) // 单指拖动
                .onActionUpdate((event: PanGestureEvent) => {
                  const res = this.handleOffset(event);
                  this.offsetX = res[0];
                  this.offsetY = res[1];
                  this.getUIContext().animateTo({
                    duration: 100,
                    curve: Curve.Friction,
                    playMode: PlayMode.Normal,
                    expectedFrameRateRange: {
                      min: 10,
                      max: 120,
                      expected: 60,
                    },
                  }, () => {
                    this.updateMatrix();
                  });
                })
                .onActionEnd((event: PanGestureEvent) => {
                  const res = this.handleOffset(event);
                  this.startOffsetX = res[0];
                  this.startOffsetY = res[1];
                }),
            ),
          );
      }

    }
    .id(this.containerId)
    .alignContent(Alignment.Bottom)
    .clip(true)
    .width(this.containerWidth)
    .height(this.containerHeight)
    .backgroundColor(this.backColor);
  }

  private snip = () => {
    this.getUIContext()
      .getComponentSnapshot()
      .get(this.containerId, { scale: 1, waitUntilRenderFinished: true })
      .then((pixmap: image.PixelMap) => {
        this.onSnapshot(pixmap);
      });
  };
}