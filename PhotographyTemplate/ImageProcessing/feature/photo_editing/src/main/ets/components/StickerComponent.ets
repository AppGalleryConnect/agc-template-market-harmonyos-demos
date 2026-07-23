import { matrix4 } from '@kit.ArkUI';
import { StickerModel } from '../model/BeautificationParam';

@ComponentV2
export struct StickerComponent {
  @Param @Require item: StickerModel;
  @Param index: number = 0;
  @Param currentStickerIndex: number = 0;
  @Event $currentStickerIndex: (index: number) => void = (index: number) => {}
  @Event onDelete: (id: string) => void;
  @Local showBorder: boolean = false;
  // 声明平移矩阵
  @Local matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  // 声明手势前的矩阵
  private rotateAndScaleMatrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  // 声明初始宽高
  private initStackWidth: number = 0;
  private initStackHeight: number = 0;
  // 声明初始半径
  private initR: number = 0;
  // 声明初始角度
  private initAngle: number = 0;
  // 声明手势开始时的坐标
  private startStackX: number = 0;
  private startStackY: number = 0;
  // 声明当前位置
  @Local currentX: number = 0;
  @Local currentY: number = 0;
  // 声明缩放比例
  @Local stackScale: number = 1;
  // 声明当前旋转角度
  @Local stickerRotate: number = 0;
  // 声明移动时手指的初始坐标
  private initFingerX: number = -1;
  private initFingerY: number = -1;


  aboutToAppear(): void {
    this.showBorder = this.index === this.currentStickerIndex;
  }

  @Monitor('currentStickerIndex')
  onIndexChange() {
    this.showBorder = this.index === this.currentStickerIndex;
  }

  build() {
    Column() {
      Column() {
        Image(this.item.img)
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain);
      }
      .width(100)
      .height(100)
      .border({
        width: this.showBorder ? 1 : 0,
        color: $r('sys.color.comp_foreground_primary'),
        style: BorderStyle.Solid,
      })

      Image($r('app.media.ic_close'))
        .width(22)
        .height(22)
        .borderRadius(12)
        .position({ top: -10, right: -10 })
        .visibility(this.showBorder ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete(this.item.id);
          }
        })

      Image($r('app.media.ic_rotate'))
        .width(22)
        .height(22)
        .borderRadius(12)
        .position({ bottom: -10, left: -10 })
        .visibility(this.showBorder ? Visibility.Visible : Visibility.None)
        .gesture(
          PanGesture()
            .onActionStart(event => {
              // 记录上一次的矩阵
              this.rotateAndScaleMatrix = this.matrix.copy();
              // 获取手指位置
              this.initFingerX = (this.initStackWidth >> 1);
              this.initFingerY = (this.initStackHeight >> 1);
            })
            .onActionUpdate(event => {
              // 获取当前坐标手指
              let currentFingerX: number = this.initFingerX + event.offsetX;
              let currentFingerY: number = this.initFingerY + event.offsetY;
              // 映射手指坐标
              let point = this.rotateAndScaleMatrix.copy().transformPoint([currentFingerX, currentFingerY]);
              currentFingerX = point[0];
              currentFingerY = point[1];
              // 获取半径
              let r: number = Math.sqrt(currentFingerX * currentFingerX + currentFingerY * currentFingerY);
              // 获取cos和sin，判断象限
              this.stackScale = (r / this.initR);
              // 声明角度
              this.stickerRotate = Math.atan2(currentFingerY, currentFingerX) * 180 / Math.PI - this.initAngle;
              this.matrix = matrix4.identity().copy()
                .rotate({ z: 1, angle: this.stickerRotate });
            })
        );
    }
    .transform(this.matrix)
    .offset({ x: this.currentX, y: this.currentY })
    .onClick(() => {
      this.$currentStickerIndex(this.index);
    })
    .onAreaChange((_value: Area, newVal: Area) => {
      this.initStackWidth = newVal.width as number;
      this.initStackHeight = newVal.height as number;
      this.initR = Math.sqrt((this.initStackWidth >> 1) * (this.initStackWidth >> 1) +
        (this.initStackHeight >> 1) * (this.initStackHeight >> 1));
      this.initAngle = Math.atan2((this.initStackHeight), (this.initStackWidth)) * 180 / Math.PI;
    })
    .gesture(
      PanGesture()
        .onActionStart(() => {
          this.$currentStickerIndex(this.index);
          this.startStackX = this.currentX;
          this.startStackY = this.currentY;
        })
        .onActionUpdate(event => {
          // 获取手指位置
          let point = this.matrix.copy().transformPoint([event.offsetX, event.offsetY]);
          this.currentX = this.startStackX + point[0];
          this.currentY = this.startStackY + point[1];
        })
    );
  }
}
