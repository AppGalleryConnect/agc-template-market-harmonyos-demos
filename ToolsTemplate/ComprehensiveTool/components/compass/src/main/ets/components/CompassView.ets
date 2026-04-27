import { CompassItem } from '../model/Index';

@ComponentV2
export struct CompassView {
  @Param @Require compassBg: CompassItem;
  @Param @Require angle: number;
  @Local geometryScale: number = 1
  @Local geometryOffsetX: number = 0
  @Local geometryOffsetY: number = 0
  @Local imageWidth: number = 0
  @Local imageHeight: number = 0
  @Local pointWidth: number = 0
  @Local pointHeight: number = 0
  private preGeometryScale: number = 1

  build() {
    Stack() {
      Image(this.compassBg.name)
        .width(326)
        .height(326)
        .onComplete((e) => {
          this.imageWidth = (e?.width || 0)
          this.imageHeight = (e?.height || 0)
        })
        .objectFit(ImageFit.Cover)
        .width(this.imageWidth + 'px')
        .height(this.imageHeight + 'px')
        .scale({
          x: this.geometryScale,
          y: this.geometryScale,
        })
        .focusable(true)
        .objectFit(ImageFit.Cover)
        .autoResize(false)
        .sharedTransition('sharedImage', {
          duration: 200,
          curve: Curve.Linear,
        })
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          angle: -this.angle,
        });
      Image($r('app.media.point'))
        .width(56)
        .height(280)
        .hitTestBehavior(HitTestMode.Transparent)
        .onComplete((e) => {
          this.pointWidth = (e?.width || 0)
          this.pointHeight = (e?.height || 0)
        })
        .objectFit(ImageFit.Cover)
        .width(this.pointWidth + 'px')
        .height(this.pointHeight + 'px')
        .margin({ top: 14 })
        .scale({
          x: this.geometryScale,
          y: this.geometryScale,
        })
    }.width(this.imageWidth + 'px')
    .height(this.imageHeight + 'px')
    .alignContent(Alignment.Center)
    .parallelGesture( // 在组件上绑定二指触发的捏合手势
      GestureGroup(GestureMode.Exclusive,
        PinchGesture({ fingers: 2 })
          .onActionStart((event: GestureEvent) => {
          })// 当捏合手势触发时，可以通过回调函数获取缩放比例，从而修改组件的缩放比例
          .onActionUpdate((event: GestureEvent) => {
            const s = this.preGeometryScale * event.scale;
            this.geometryScale = Math.max(0.6, Math.min(2, s))
          })
          .onActionEnd(async () => {
            this.preGeometryScale = this.geometryScale
            this.geometryOffsetY = this.geometryScale
            if (this.preGeometryScale < 1) {
              await this.reset()
            }
          }),
      ),
    )
  }

  reset(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.preGeometryScale = 1
      if (this.geometryScale === 1) {
        reject()
      }
      this.getUIContext().animateTo({ duration: 200, onFinish: resolve }, () => {
        this.geometryScale = 1
        this.geometryOffsetX = 0
        this.geometryOffsetY = 0
      })
    })
  }
}