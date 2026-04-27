import { PathShape } from '@kit.ArkUI';
import { CollageVM } from '../viewmodel/CollageVM';

// 固定拼接视图
@ComponentV2
export struct FixedCollage {
  vm: CollageVM = CollageVM.instance;
  @Local activeIndex: number = -1;
  @Local dragStartX: number = 0;
  @Local dragStartY: number = 0;
  @Local scaleStart: number = 0;
  @Local rotateStart: number = 0;

  build() {
    if (!this.vm.layout) {
      Text('请选择拼接模板').fontSize(20);
    } else {
      Stack() {
        Repeat(this.vm.fixedImages)
          .each((image) => {
            if (image.index < this.vm.layout!.regions.length) {
              Stack() {
                Stack() {
                  Image(image.item.src)
                    .objectFit(ImageFit.Contain)
                    .rotate({ angle: image.item.rotate })
                    .scale({ x: image.item.scale, y: image.item.scale, z: 1 });
                }
                .translate({ x: image.item.x, y: image.item.y });
              }
              .width(this.vm.layout!.width)
              .height(this.vm.layout!.height)
              .clipShape(new PathShape().commands(this.vm.layout!.regions[image.index].path));
            }
          });

        // 手势层（覆盖整个拼接画布）
        Column()
          .width(this.vm.layout!.width)
          .height(this.vm.layout!.height)
          .backgroundColor(Color.Transparent)
          .gesture(
            GestureGroup(GestureMode.Parallel,
              PanGesture()
                .onActionStart((e: GestureEvent) => {
                  // 从最上层区域往下找（Repeat 渲染顺序决定 z 序；一般后渲更上）
                  this.activeIndex = -1;
                  for (let i = this.vm.layout!.regions.length - 1; i >= 0; i--) {
                    if (e.fingerList[0]) {
                      const px = this.getUIContext().vp2px(e.fingerList[0].localX);
                      const py = this.getUIContext().vp2px(e.fingerList[0].localY);
                      if (this.vm.isPointInPolygon(px, py, this.vm.polygons[i])) {
                        this.activeIndex = i;
                        // 记录起点
                        this.dragStartX = this.vm.fixedImages[i].x;
                        this.dragStartY = this.vm.fixedImages[i].y;
                        break;
                      }
                    }
                  }
                })
                .onActionUpdate((e: GestureEvent) => {
                  if (this.activeIndex >= 0) {
                    this.vm.fixedImages[this.activeIndex].x = this.dragStartX + e.offsetX;
                    this.vm.fixedImages[this.activeIndex].y = this.dragStartY + e.offsetY;
                  }
                })
                .onActionEnd(() => {
                  this.activeIndex = -1;
                }),
              PinchGesture()
                .onActionStart((e: GestureEvent) => {
                  // 从最上层区域往下找（Repeat 渲染顺序决定 z 序；一般后渲更上）
                  this.activeIndex = -1;
                  for (let i = this.vm.layout!.regions.length - 1; i >= 0; i--) {
                    if (e.fingerList[0]) {
                      const px = this.getUIContext().vp2px(e.fingerList[0].localX);
                      const py = this.getUIContext().vp2px(e.fingerList[0].localY);
                      if (this.vm.isPointInPolygon(px, py, this.vm.polygons[i])) {
                        this.activeIndex = i;
                        // 记录起点
                        this.scaleStart = this.vm.fixedImages[i].scale;
                        break;
                      }
                    }
                  }
                })
                .onActionUpdate((e: GestureEvent) => {
                  if (this.activeIndex >= 0) {
                    this.vm.fixedImages[this.activeIndex].scale = this.scaleStart * e.scale;
                  }
                })
                .onActionEnd(() => {
                  this.activeIndex = -1;
                }),
              RotationGesture()
                .onActionStart((e: GestureEvent) => {
                  this.activeIndex = -1;
                  for (let i = this.vm.layout!.regions.length - 1; i >= 0; i--) {
                    if (e.fingerList[0]) {
                      const px = this.getUIContext().vp2px(e.fingerList[0].localX);
                      const py = this.getUIContext().vp2px(e.fingerList[0].localY);
                      if (this.vm.isPointInPolygon(px, py, this.vm.polygons[i])) {
                        this.activeIndex = i;
                        // 记录起点
                        this.rotateStart = this.vm.fixedImages[i].rotate;
                        break;
                      }
                    }
                  }
                })
                // 当旋转手势生效时，通过旋转手势的回调函数获取旋转角度，从而修改组件的旋转角度
                .onActionUpdate((event: GestureEvent | undefined) => {
                  if (event) {
                    if (this.activeIndex >= 0) {
                      this.vm.fixedImages[this.activeIndex].rotate = this.rotateStart + event.angle;
                    }
                  }
                })
                // 当旋转结束抬手时，固定组件在旋转结束时的角度
                .onActionEnd(() => {
                  this.activeIndex = -1;
                }),
            ),
          );
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width(this.vm.layout!.width)
      .height('calc(100% - 150vp)')
      .clip(true);
    }
  }
}