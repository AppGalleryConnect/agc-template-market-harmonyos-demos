import { inspector, matrix4, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../constants/LongTakeTransitionConstants';

enum Status {
  IDLE,
  PINCHING,
  PAN_ONLY,
  READY_TO_BACK
}

@ComponentV2
export struct ImageLongTakeDelegate {
  @Param componentId: string = ''
  @Param newsId: string = ''
  @Local status: Status = Status.IDLE;
  @Local panDirection: PanDirection = PanDirection.Vertical;
  @Local imageScale: number = 1;
  @Local imagePullingDownScale: number = 1;
  @Local imageTranslateX: number = 0;
  @Local imageTranslateY: number = 0;
  @Local centerX: number = 0;
  @Local centerY: number = 0;
  @Local maxOffsetX: number = 0;
  @Local minOffsetX: number = 0;
  @Local maxOffsetY: number = 0;
  @Local minOffsetY: number = 0;
  @Local gestureDisabled: boolean = false;
  @Local gestureCount: number = 0;

  @Monitor('gestureCount')
  onAllGestureFinishFn() {
    this.onAllGestureFinish()
  }

  @Local geometryPositionX: number = 0;
  @Local geometryPositionY: number = 0;
  @Local geometryScale: number = 1;
  @Param imageUrl: string = '';
  private photoId: string = 'myCat';
  private photoListener: inspector.ComponentObserver =
    this.getUIContext().getUIInspector().createComponentObserver(this.photoId);
  private imagePositionX: number = 0;
  private imagePositionY: number = 600;
  @Local imageWidth: number = 1260;

  @Monitor('imageWidth')
  getImageWidthFn() {
    this.getImageWidth()
  }

  private imageHeight: number = 1680;
  private lastCenterX: number = 0;
  private lastCenterY: number = 0;
  private startGestureOffsetX: number = 0;
  private startGestureOffsetY: number = 0;
  private startGestureScale: number = 1;
  private displayLeft: number = 0;
  private displayTop: number = 126;
  private displayRight: number = 1260;
  private displayBottom: number = 2629;
  private realDisplayBoundsLeft: number = 0;
  private realDisplayBoundsTop: number = 0;
  private realDisplayBoundsRight: number = 0;
  private realDisplayBoundsBottom: number = 0;
  private firstStarted = true;
  @Event backToFirstPage: () => void = () => {
  };

  init(): void {
    try {
      let photoInfo = this.getUIContext().getComponentUtils().getRectangleById(this.photoId);
      this.imagePositionX = photoInfo.windowOffset.x;
      this.imagePositionY = photoInfo.windowOffset.y;
    } catch (err) {
      UtilLog.error(LOG_TAG, 'init failed. error:' + JSON.stringify(err))
    }
  }

  getImageWidth() {
    window.getLastWindow(this.getUIContext().getHostContext()).then((data) => {
      let properties = data?.getWindowProperties();
      this.imageWidth = properties.windowRect.width
    }).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'get lastWindowFailed. error: ' + JSON.stringify(err))
    })
  }

  onAllGestureFinish(): void {
    if (this.firstStarted) {
      this.firstStarted = false;
      return;
    }

    if (this.gestureCount !== 0) {
      return;
    }

    if (this.status === Status.IDLE) {
      this.disableGesture();
      this.getUIContext().animateTo({
        duration: 200,
        onFinish: () => {
          this.updatePanDirection();
          this.resumeGesture();
        },
      }, () => {
        this.imagePullingDownScale = 1;
        let leftTop = this.calculateLeftTopPoint();
        let rightBottom = this.calculateRightBottomPoint();
        let imageWidth = this.imageWidth * this.imageScale;
        if (imageWidth < this.displayRight - this.displayLeft) {
          this.centerX = 0;
          this.imageTranslateX = 0;
        } else if (leftTop[0] > this.displayLeft) {
          this.imageTranslateX += (this.displayLeft - leftTop[0]);
        } else if (rightBottom[0] < this.displayRight) {
          this.imageTranslateX += (this.displayRight - rightBottom[0]);
        }

        let imageHeight = this.imageHeight * this.imageScale;
        if (imageHeight < this.displayBottom - this.displayTop) {
          this.centerY = 0;
          this.imageTranslateY = 0;
        } else if (leftTop[1] > this.displayTop) {
          this.imageTranslateY += (this.displayTop - leftTop[1]);
        } else if (rightBottom[1] < this.displayBottom) {
          this.imageTranslateY += (this.displayBottom - rightBottom[1]);
        }
      })
    }

    if (this.status === Status.READY_TO_BACK) {
      this.status = Status.IDLE;
      this.disableGesture();
      this.getUIContext().animateTo({
        duration: 200,
        onFinish: () => {
          this.resumeGesture();
          this.updatePanDirection();
        },
      }, () => {
        let leftTopPoint = this.calculateLeftTopPoint();
        this.geometryPositionX = leftTopPoint[0] - this.imagePositionX;
        this.geometryPositionY = leftTopPoint[1] - this.imagePositionY;
        this.geometryScale = this.imageScale * this.imagePullingDownScale;
        this.resetTransform();
        this.backToFirstPage();
      })
    }
  }

  disableGesture(): void {
    this.gestureDisabled = true;
  }

  resumeGesture(): void {
    this.gestureDisabled = false;
  }

  calculateLeftTopPoint(): [number, number] {
    let matrix = matrix4.identity()
      .scale({
        x: this.imageScale * this.imagePullingDownScale,
        y: this.imageScale * this.imagePullingDownScale,
        centerX: this.centerX,
        centerY: this.centerY,
      })
      .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
    let leftTop = matrix.transformPoint([-this.imageWidth / 2, -this.imageHeight / 2]);
    let leftTopPointX = leftTop[0] + this.imageWidth / 2 + this.imagePositionX;
    let leftTopPointY = leftTop[1] + this.imageHeight / 2 + this.imagePositionY;
    return [leftTopPointX, leftTopPointY];
  }

  calculateRightBottomPoint(): [number, number] {
    let matrix = matrix4.identity()
      .scale({
        x: this.imageScale * this.imagePullingDownScale,
        y: this.imageScale * this.imagePullingDownScale,
        centerX: this.centerX,
        centerY: this.centerY,
      })
      .translate({
        x: this.imageTranslateX,
        y: this.imageTranslateY,
      })
    let rightBottom = matrix.transformPoint([this.imageWidth / 2, this.imageHeight / 2]);
    let rightBottomPointX = rightBottom[0] + this.imageWidth / 2 + this.imagePositionX;
    let rightBottomPointY = rightBottom[1] + this.imageHeight / 2 + this.imagePositionY;
    return [rightBottomPointX, rightBottomPointY];
  }

  updateCenter(gestureCenterPoint: [number, number]) {
    this.lastCenterX = this.centerX;
    this.lastCenterY = this.centerY;
    let matrix = matrix4.identity()
      .scale({
        x: this.imageScale * this.imagePullingDownScale,
        y: this.imageScale * this.imagePullingDownScale,
        centerX: this.lastCenterX,
        centerY: this.lastCenterY,
      })
      .translate({
        x: this.imageTranslateX,
        y: this.imageTranslateY,
      })
    let leftTop = matrix.transformPoint([-this.imageWidth / 2, -this.imageHeight / 2]);
    let leftTopPointX = leftTop[0] + this.imageWidth / 2;
    let leftTopPointY = leftTop[1] + this.imageHeight / 2;
    this.centerX = (gestureCenterPoint[0] - leftTopPointX) / this.imageScale - this.imageWidth / 2;
    this.centerY = (gestureCenterPoint[1] - leftTopPointY) / this.imageScale - this.imageHeight / 2;
  }

  updateTranslateAccordingToCenter() {
    if (this.lastCenterX === this.centerX && this.lastCenterY === this.centerY) {
      return;
    }
    let lastTranslateX = this.imageTranslateX;
    let lastTranslateY = this.imageTranslateY;
    let matrixOld = matrix4.identity()
      .scale({
        x: this.imageScale * this.imagePullingDownScale,
        y: this.imageScale * this.imagePullingDownScale,
        centerX: this.lastCenterX,
        centerY: this.lastCenterY,
      })
      .translate({ x: lastTranslateX, y: lastTranslateY })
    let matrixNew = matrix4.identity()
      .scale({
        x: this.imageScale * this.imagePullingDownScale,
        y: this.imageScale * this.imagePullingDownScale,
        centerX: this.centerX,
        centerY: this.centerY,
      })
      .translate({
        x: this.imageTranslateX,
        y: this.imageTranslateY,
      })
    let leftTopOld = matrixOld.transformPoint([-this.imageWidth / 2, -this.imageHeight / 2]);
    let leftTopNew = matrixNew.transformPoint([-this.imageWidth / 2, -this.imageHeight / 2]);
    this.imageTranslateX += (leftTopOld[0] - leftTopNew[0]);
    this.imageTranslateY += (leftTopOld[1] - leftTopNew[1]);
  }

  updateExtremeOffset() {
    let totalScale = this.imageScale * this.imagePullingDownScale;
    let matrix = matrix4.identity()
      .scale({
        x: totalScale,
        y: totalScale,
        centerX: this.centerX,
        centerY: this.centerY,
      })

    let p = matrix.transformPoint([-this.imageWidth / 2, -this.imageHeight / 2]);
    let leftTopPointX = p[0] + this.imageWidth / 2 + this.imagePositionX;
    let leftTopPointY = p[1] + this.imageHeight / 2 + this.imagePositionY;
    let rightBottomPointX = leftTopPointX + this.imageWidth * totalScale;
    let rightBottomPointY = leftTopPointY + this.imageHeight * totalScale;

    this.realDisplayBoundsLeft = Math.max(this.displayLeft, leftTopPointX);
    this.realDisplayBoundsRight = Math.min(this.displayRight, rightBottomPointX);
    this.realDisplayBoundsTop = Math.max(this.displayTop, leftTopPointY);
    this.realDisplayBoundsBottom = Math.min(this.displayBottom, rightBottomPointY);

    this.minOffsetX = this.getUIContext().px2vp(this.realDisplayBoundsRight - rightBottomPointX);
    this.maxOffsetX = this.getUIContext().px2vp(this.realDisplayBoundsLeft - leftTopPointX);
    this.minOffsetY = this.getUIContext().px2vp(this.realDisplayBoundsBottom - rightBottomPointY);
    this.maxOffsetY = this.getUIContext().px2vp(this.realDisplayBoundsTop - leftTopPointY);
  }

  clamp(num: number, min: number, max: number): number {
    return Math.min(Math.max(num, min), max)
  }

  // 双击
  doubleClick() {
    let scale = this.imageScale === 1 ? 2 : 1
    this.imageScale = this.clamp(scale, +1, +(3 as number) + 1)
  }

  // 单击
  singleClick() {
    this.backToFirstPage()
  }

  updatePanDirection(): void {
    this.panDirection = PanDirection.Vertical;
    let leftTop = this.calculateLeftTopPoint();
    let rightBottom = this.calculateRightBottomPoint();
    if (leftTop[0] < this.displayLeft - 1) {
      this.panDirection = this.panDirection | PanDirection.Right;
    }
    if (rightBottom[0] > this.displayRight + 1) {
      this.panDirection = this.panDirection | PanDirection.Left;
    }
  }

  resetTransform(): void {
    this.imageTranslateX = 0;
    this.imageTranslateY = 0;
    this.imageScale = 1;
    this.imagePullingDownScale = 1;
    this.centerX = 0;
    this.centerY = 0;
    this.updateExtremeOffset();
  }

  cannotPan(): boolean {
    return this.gestureDisabled;
  }

  cannotPinch(): boolean {
    return this.status === Status.PAN_ONLY || this.gestureDisabled;
  }

  aboutToAppear(): void {
    this.photoListener.on('layout', () => {
      this.init();
    });
    this.updateExtremeOffset();
    this.updatePanDirection();
    this.getImageWidth()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .opacity(this.imagePullingDownScale)
        .transition(TransitionEffect.OPACITY)
      Stack() {
        Image(this.imageUrl)
          .width(this.getUIContext().px2vp(this.imageWidth) * this.geometryScale)
          .height(this.getUIContext().px2vp(this.imageHeight) * this.geometryScale)
          .transform(matrix4.identity()
            .scale({
              x: this.imageScale * this.imagePullingDownScale,
              y: this.imageScale * this.imagePullingDownScale,
              centerX: this.centerX,
              centerY: this.centerY,
            })
            .translate({
              x: this.imageTranslateX,
              y: this.imageTranslateY,
            }))
          .geometryTransition(this.newsId + this.imageUrl + this.componentId)
          .transition(TransitionEffect.OPACITY)
          .position({
            x: this.getUIContext().px2vp(this.geometryPositionX),
            y: this.getUIContext().px2vp(this.geometryPositionY),
          })
      }
      .id(this.imageUrl)
      .width(this.getUIContext().px2vp(this.imageWidth))
      .height(this.getUIContext().px2vp(this.imageHeight))
      .parallelGesture(GestureGroup(GestureMode.Exclusive,
        // 双击
        TapGesture({ fingers: 1, count: 2 }).onAction((event) => {
          this.doubleClick()
        }),
        // 单击
        TapGesture({ fingers: 1, count: 1 }).onAction(() => {
          this.singleClick()
        }),
        PinchGesture()
          .onActionStart((event: GestureEvent) => {
            this.status = Status.PINCHING;
            this.updateCenter([this.getUIContext().vp2px(event.pinchCenterX),
              this.getUIContext().vp2px(event.pinchCenterY)]);
            this.updateTranslateAccordingToCenter();
            this.startGestureScale = this.imageScale;
            this.gestureCount++;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.imageScale = this.startGestureScale * event.scale;
            this.updateExtremeOffset();
          })
          .onActionEnd(() => {
            this.status = Status.IDLE;
            if (this.imageScale < 1) {
              this.getUIContext().animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
                this.imageScale = 1;
              })
            }
            this.gestureCount--;
          }),
        PanGesture({ direction: this.panDirection })
          .onActionStart((event: GestureEvent) => {
            this.panDirection = PanDirection.All;
            let leftTop = this.calculateLeftTopPoint();
            if (leftTop[1] >= this.displayTop - 1 && this.status !== Status.PINCHING) {
              this.status = Status.PAN_ONLY;
            }
            if (this.status !== Status.PINCHING) {
              let currentX: number = event.offsetX;
              let currentY: number = event.offsetY;
              if (event.fingerList[0] !== undefined) {
                currentX = event.fingerList[0].globalX;
                currentY = event.fingerList[0].globalY;
              }
              this.updateCenter([this.getUIContext().vp2px(currentX - this.imagePositionX),
                this.getUIContext().vp2px(currentY) - this.imagePositionY]);
              this.updateTranslateAccordingToCenter();
              this.updateExtremeOffset();
            }
            this.startGestureOffsetX = this.getUIContext().px2vp(this.imageTranslateX);
            this.startGestureOffsetY = this.getUIContext().px2vp(this.imageTranslateY);
            this.gestureCount++;
          })
          .onActionUpdate((event: GestureEvent) => {
            let offsetX = event.offsetX;
            let offsetY = event.offsetY;
            if (this.status === Status.PAN_ONLY) {
              this.imageTranslateX = this.getUIContext().vp2px(this.startGestureOffsetX + offsetX);
              this.imageTranslateY = this.getUIContext().vp2px(this.startGestureOffsetY + offsetY);
              this.imagePullingDownScale = 1 - Math.abs(event.offsetY) / this.getUIContext().px2vp(2720);
            }
            if (this.status !== Status.PAN_ONLY) {
              if (offsetX + this.startGestureOffsetX > this.maxOffsetX) {
                let distance = offsetX + this.startGestureOffsetX - this.maxOffsetX;
                offsetX = this.maxOffsetX + distance * (1 - Math.exp(-distance / 300)) - this.startGestureOffsetX;
              }
              if (offsetX + this.startGestureOffsetX < this.minOffsetX) {
                let distance = this.minOffsetX - (offsetX + this.startGestureOffsetX)
                offsetX = this.minOffsetX - distance * (1 - Math.exp(-distance / 300)) - this.startGestureOffsetX;
              }
              if (offsetY + this.startGestureOffsetY > this.maxOffsetY) {
                let distance = offsetY + this.startGestureOffsetY - this.maxOffsetY;
                offsetY = this.maxOffsetY + distance * (1 - Math.exp(-distance / 300)) - this.startGestureOffsetY;
              }
              if (offsetY + this.startGestureOffsetY < this.minOffsetY) {
                let distance = this.minOffsetY - (offsetY + this.startGestureOffsetY)
                offsetY = this.minOffsetY - distance * (1 - Math.exp(-distance / 300)) - this.startGestureOffsetY;
              }
              this.imageTranslateX = this.getUIContext().vp2px(this.startGestureOffsetX + offsetX);
              this.imageTranslateY = this.getUIContext().vp2px(this.startGestureOffsetY + offsetY);
            }
          })
          .onActionEnd((event: GestureEvent) => {
            if (this.status === Status.PAN_ONLY) {
              if (event.offsetY > 100) {
                this.status = Status.READY_TO_BACK;
              } else {
                this.status = Status.IDLE;
              }
            }
            this.gestureCount--;
          }),
      ))
      .onGestureJudgeBegin((gestureInfo: GestureInfo) => {
        if (gestureInfo.type === GestureControl.GestureType.PAN_GESTURE) {
          return this.cannotPan() ? GestureJudgeResult.REJECT : GestureJudgeResult.CONTINUE;
        }
        if (gestureInfo.type === GestureControl.GestureType.PINCH_GESTURE) {
          return this.cannotPinch() ? GestureJudgeResult.REJECT : GestureJudgeResult.CONTINUE;
        }
        return GestureJudgeResult.CONTINUE;
      })
    }
    .width('100%')
    .height('100%')
  }
}