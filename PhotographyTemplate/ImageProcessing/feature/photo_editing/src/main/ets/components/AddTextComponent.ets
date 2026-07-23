import { ComponentContent, LevelMode, matrix4 } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CanvasTextItem } from '../model/BeautificationParam';
import { textEditDialog } from './TextEditDialog';
import { TextEditDialogParams } from '../model/ImageModel';
import { OperateType } from 'commonlib';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct AddTextComponent {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  private panGestureFlag: boolean = false;
  private selectedCanvasItem: CanvasTextItem = new CanvasTextItem();
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

  build() {
    Stack() {
      Column() {
        Text(this.vm.canvasText.text ? this.vm.canvasText.text : '点击输入文字')
          .fontSize(this.vm.canvasText.fontSize)
          .fontColor(this.vm.canvasText.currentColor)
          .opacity(this.vm.canvasText.opacity)
          .fontWeight(this.vm.canvasText.isBold ? FontWeight.Bold : FontWeight.Normal)
          .fontStyle(this.vm.canvasText.isItalics ? FontStyle.Italic : FontStyle.Normal)
          .fontFamily(this.vm.canvasText.font)
          .decoration({
            type: this.vm.canvasText.isUnderline ? TextDecorationType.Underline : TextDecorationType.None,
            color: this.vm.canvasText.currentColor,
          })
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderColor(this.vm.saveText ? Color.Transparent : Color.White)
          .borderWidth(1)
          .borderStyle(BorderStyle.Dashed)

        Image($r('app.media.ic_close'))
          .width(24)
          .height(24)
          .borderRadius(12)
          .position({ top: -12, right: -12 })
          .visibility(this.vm.saveText ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            this.vm.showCanvasText = false;
            this.vm.canvasText = new CanvasTextItem();
          })

        Image($r('app.media.ic_rotate'))
          .width(24)
          .height(24)
          .borderRadius(12)
          .position({ bottom: -12, left: -12 })
          .visibility(this.vm.saveText ? Visibility.None : Visibility.Visible)
          .gesture(
            PanGesture()
              .onActionStart(() => {
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
      .padding(4)
      .borderColor(this.vm.saveText ? Color.Transparent : Color.White)
      .borderWidth(1)
      .borderStyle(BorderStyle.Solid)
      .borderRadius(4)
      .transform(this.matrix)
      .offset({ x: this.vm.canvasText.dx, y: this.vm.canvasText.dy })
      .onAreaChange((_value: Area, newVal: Area) => {
        this.initStackWidth = newVal.width as number;
        this.initStackHeight = newVal.height as number;
        this.initR = Math.sqrt((this.initStackWidth >> 1) * (this.initStackWidth >> 1) +
          (this.initStackHeight >> 1) * (this.initStackHeight >> 1));
        this.initAngle = Math.atan2((this.initStackHeight), (this.initStackWidth)) * 180 / Math.PI;
      })
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          // 单击
          TapGesture({ count: 1 }).onAction(() => {
            if (this.vm.operateType === OperateType.TEXT) {
              let uiContext = this.getUIContext();
              let textEditContentNode =
                new ComponentContent(uiContext, wrapBuilder<[TextEditDialogParams]>(textEditDialog), {
                  cloneText: this.vm.canvasText.text,
                  canvasText: this.vm.canvasText,
                  close: () => {
                    uiContext.getPromptAction().closeCustomDialog(textEditContentNode);
                  },
                } as TextEditDialogParams);

              uiContext.getPromptAction().openCustomDialog(textEditContentNode, {
                levelMode: LevelMode.EMBEDDED,
                onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                  hilog.info(0xFF00, 'TextEditDialog', JSON.stringify(dismissDialogAction.reason));
                },
              })
                .then(() => {
                  hilog.info(0xFF00, 'TAG', 'OpenCustomDialog complete');
                })
                .catch((error: BusinessError) => {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.info(0xFF00, 'TAG', `OpenCustomDialog args error code is ${code}, message is ${message}`);
                });
            }
          }),
          // 滑动
          PanGesture().onActionStart(() => {
            this.panGestureFlag = true;
          })
            .onActionUpdate((event: GestureEvent) => {
              if (event && this.panGestureFlag && this.selectedCanvasItem && this.vm.operateType === OperateType.TEXT) {
                this.vm.canvasText.dx = this.selectedCanvasItem.dx + event.offsetX;
                this.vm.canvasText.dy = this.selectedCanvasItem.dy + event.offsetY;
              }
            })
            .onActionEnd((event: GestureEvent) => {
              this.panGestureFlag = false;
              if (event && this.selectedCanvasItem && this.vm.operateType === OperateType.TEXT) {
                this.vm.canvasText.dx = this.selectedCanvasItem.dx + event.offsetX;
                this.vm.canvasText.dy = this.selectedCanvasItem.dy + event.offsetY;
                this.selectedCanvasItem.dx = this.selectedCanvasItem.dx + event.offsetX;
                this.selectedCanvasItem.dy = this.selectedCanvasItem.dy + event.offsetY;
              }
            }),
        ),
      );
    }
    .width('100%')
    .height('100%');
  }
}