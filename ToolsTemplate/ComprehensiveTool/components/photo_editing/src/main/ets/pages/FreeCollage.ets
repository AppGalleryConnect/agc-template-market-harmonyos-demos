import { CollageVM } from '../viewmodel/CollageVM';

@ComponentV2
export struct FreeCollage {
  vm: CollageVM = CollageVM.instance
  @Local dragStartX: Array<number> = Array<number>(this.vm.freeImages.length);
  @Local dragStartY: Array<number> = Array<number>(this.vm.freeImages.length);
  @Local scaleStart: Array<number> = Array<number>(this.vm.freeImages.length);
  @Local rotateStart: Array<number> = Array<number>(this.vm.freeImages.length);
  @Local actualHeight: Array<number> = Array<number>(this.vm.freeImages.length);
  @Local actualWidth: Array<number> = Array<number>(this.vm.freeImages.length);
  @Local dispW: Array<number> = new Array<number>(this.vm.freeImages.length).fill(600);
  @Local dispH: Array<number> = Array<number>(this.vm.freeImages.length).fill(600);

  build() {
    Stack() {
      if (this.vm.free) {
        Image(this.vm.free.background)
          .height('100%')
          .objectFit(ImageFit.Contain);

        Repeat(this.vm.freeImages)
          .each((image) => {
            Stack() {
              Image(image.item.src)
                .width(this.dispW[image.index] + 'px')
                .height(this.dispH[image.index] + 'px')
                .objectFit(ImageFit.Contain)
                .scale({ x: image.item.scale, y: image.item.scale })
                .rotate({ angle: image.item.rotate })
                .gesture(
                  GestureGroup(GestureMode.Parallel,
                    PinchGesture()
                      .onActionStart((e: GestureEvent) => {
                        this.scaleStart[image.index] = image.item.scale;
                      })
                      .onActionUpdate((event: GestureEvent) => {
                        image.item.scale = this.scaleStart[image.index] * event.scale;
                      })
                      .onActionEnd(() => {
                      }),
                    RotationGesture()
                      .onActionStart((event: GestureEvent | undefined) => {
                        this.rotateStart[image.index] = image.item.rotate;
                      })
                      // 当旋转手势生效时，通过旋转手势的回调函数获取旋转角度，从而修改组件的旋转角度
                      .onActionUpdate((event: GestureEvent | undefined) => {
                        if (event) {
                          image.item.rotate = this.rotateStart[image.index] + event.angle;
                        }
                      })
                      // 当旋转结束抬手时，固定组件在旋转结束时的角度
                      .onActionEnd(() => {
                      }),
                  ),
                )
                .onComplete((e) => {
                  if (e?.loadingStatus === 1) {
                    this.dispW[image.index] = e.contentWidth;
                    this.dispH[image.index] = e.contentHeight;
                  }
                });
            }
            .translate({ x: image.item.x, y: image.item.y })
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                PanGesture()
                  .onActionStart((e: GestureEvent) => {
                    this.dragStartX[image.index] = image.item.x;
                    this.dragStartY[image.index] = image.item.y;
                  })
                  .onActionUpdate((event: GestureEvent) => {
                    if (event) {
                      image.item.x = this.dragStartX[image.index] + event.offsetX;
                      image.item.y = this.dragStartY[image.index] + event.offsetY;
                    }
                  })
                  .onActionEnd(() => {
                  }),
              ),
            );
          });
      }
    }
    .clip(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('calc(100% - 150vp)')
  }
}