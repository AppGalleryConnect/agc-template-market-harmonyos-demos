import { PathShape } from '@kit.ArkUI';
import { CommonConstants } from 'commonlib';
import { CollageVM } from '../viewmodel/CollageVM';
import { DESIGN_H, DESIGN_W } from '../constant/Constants';


// 海报拼接视图
@ComponentV2
export struct PosterCollage {
  vm: CollageVM = CollageVM.instance;
  @Local activeIndex: number = -1;
  @Local dragStartX: number = 0;
  @Local dragStartY: number = 0;
  @Local scaleStart: number = 0;
  @Local rotateStart: number = 0;
  @Local dispW: number = 0;
  @Local dispH: number = 0;
  @Local offX: number = 0;
  @Local offY: number = 0;
  @Local scaleX: number = 1;
  @Local scaleY: number = 1;

  build() {
    if (!this.vm.poster) {
      Text('请选择海报模板').fontSize(20);
    } else {
      Stack() {
        Repeat(this.vm.posterImages)
          .each((image) => {
            if (image.index < this.vm.poster!.regions.length) {
              Stack() {
                Stack() {
                  Image(image.item.src)
                    .objectFit(ImageFit.TOP_START)
                    .rotate({ angle: image.item.rotate })
                    .scale({ x: image.item.scale, y: image.item.scale, z: 1 });
                }
                .translate({
                  x: image.item.x + 'px',
                  y: image.item.y + 'px',
                });
              }
              .width(this.dispW + 'px')
              .height(this.dispH + 'px')
              .clipShape(new PathShape().commands(this.vm.poster?.regions[image.index].path));
            }
          });

        // 背景
        Image(this.vm.poster.background)
          .objectFit(ImageFit.Contain)
          .aspectRatio(DESIGN_W/DESIGN_H)
          .onAreaChange((_ov: Area, nv: Area) => {
            const uiContext = this.getUIContext()
            const width = uiContext.vp2px(nv.width as number)
            const height = uiContext.vp2px(nv.height as number)
            this.dispW = width
            this.dispH = height
            this.vm.postImageWidth = width;
            this.vm.postImageHeight = height;
            // 线性映射比（设计 -> 显示）
            this.scaleX = this.dispW / DESIGN_W;
            this.scaleY = this.dispH / DESIGN_H;
            let offX = this.getUIContext().vp2px(nv.position.x as number);
            let offY = this.getUIContext().vp2px(nv.position.y as number);
            this.offX = Math.floor(offX);
            this.offY = Math.floor(offY);
            this.vm.postImageOffsetX = Math.floor(offX);
            this.vm.postImageOffsetY = Math.floor(offY);
            this.vm.processPoster(this.scaleX, this.scaleY, this.offX, this.offY);
          })

        // 手势层（覆盖整个拼接画布）
        Column()
          .width(this.dispW + 'px')
          .height(this.dispH + 'px')
          .backgroundColor(Color.Transparent)
          .gesture(
            GestureGroup(GestureMode.Parallel,
              PanGesture()
                .onActionStart((e: GestureEvent) => {
                  // 从最上层区域往下找（Repeat 渲染顺序决定 z 序；一般后渲更上）
                  this.activeIndex = -1;
                  for (let i = this.vm.poster!.regions.length - 1; i >= 0; i--) {
                    if (e.fingerList[0]) {
                      const px = this.getUIContext().vp2px(e.fingerList[0].localX);
                      const py = this.getUIContext().vp2px(e.fingerList[0].localY);
                      if (this.vm.isPointInPolygon(px, py, this.vm.polygons[i])) {
                        this.activeIndex = i;
                        // 记录起点
                        this.dragStartX = this.vm.posterImages[i].x;
                        this.dragStartY = this.vm.posterImages[i].y;
                        break;
                      }
                    }
                  }
                })
                .onActionUpdate((e: GestureEvent) => {
                  if (this.activeIndex >= 0) {
                    this.vm.posterImages[this.activeIndex].x = this.dragStartX + this.getUIContext().vp2px(e.offsetX);
                    this.vm.posterImages[this.activeIndex].y = this.dragStartY + this.getUIContext().vp2px(e.offsetY);
                  }
                })
                .onActionEnd(() => {
                  this.activeIndex = -1;
                }),
              PinchGesture()
                .onActionStart((e: GestureEvent) => {
                  // 从最上层区域往下找（Repeat 渲染顺序决定 z 序；一般后渲更上）
                  this.activeIndex = -1;
                  for (let i = this.vm.poster!.regions.length - 1; i >= 0; i--) {
                    if (e.fingerList[0]) {
                      const px = this.getUIContext().vp2px(e.fingerList[0].localX);
                      const py = this.getUIContext().vp2px(e.fingerList[0].localY);
                      if (this.vm.isPointInPolygon(px, py, this.vm.polygons[i])) {
                        this.activeIndex = i;
                        // 记录起点
                        this.scaleStart = this.vm.posterImages[i].scale;
                        break;
                      }
                    }
                  }
                })
                .onActionUpdate((e: GestureEvent) => {
                  if (this.activeIndex >= 0) {
                    this.vm.posterImages[this.activeIndex].scale = this.scaleStart * e.scale;
                  }
                })
                .onActionEnd(() => {
                  this.activeIndex = -1;
                }),
              RotationGesture()
                .onActionStart((e: GestureEvent) => {
                  this.activeIndex = -1;
                  for (let i = this.vm.poster!.regions.length - 1; i >= 0; i--) {
                    if (e.fingerList[0]) {
                      const px = this.getUIContext().vp2px(e.fingerList[0].localX);
                      const py = this.getUIContext().vp2px(e.fingerList[0].localY);
                      if (this.vm.isPointInPolygon(px, py, this.vm.polygons[i])) {
                        this.activeIndex = i;
                        // 记录起点
                        this.rotateStart = this.vm.posterImages[i].rotate;
                        break;
                      }
                    }
                  }
                })
                // 当旋转手势生效时，通过旋转手势的回调函数获取旋转角度，从而修改组件的旋转角度
                .onActionUpdate((event: GestureEvent | undefined) => {
                  if (event) {
                    if (this.activeIndex >= 0) {
                      this.vm.posterImages[this.activeIndex].rotate = this.rotateStart + event.angle;
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
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
      .clip(true);
    }
  }
}