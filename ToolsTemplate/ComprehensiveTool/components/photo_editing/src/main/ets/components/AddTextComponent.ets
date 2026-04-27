import { ComponentContent, LevelMode } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { BusinessError } from '@kit.BasicServicesKit';
import { CanvasTextItem } from '../model/BeautificationParam';
import { textEditDialog } from './TextEditDialog';
import { TextEditDialogParams } from '../model/Index';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct AddTextComponent {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  private panGestureFlag: boolean = false;
  private selectedCanvasItem: CanvasTextItem | undefined = undefined;

  onDidBuild(): void {
    this.selectedCanvasItem = this.vm.canvasItemStack.clone();
    this.vm.saveText = false;
  }

  build() {
    Stack() {
      Text(this.vm.canvasItemStack.text ? this.vm.canvasItemStack.text : '点击输入文字')
        .fontSize(this.vm.canvasItemStack.fontSize)
        .fontColor(this.vm.canvasItemStack.currentColor)
        .opacity(this.vm.canvasItemStack.opacity)
        .fontWeight(this.vm.canvasItemStack.isBold ? FontWeight.Bold : FontWeight.Normal)
        .fontStyle(this.vm.canvasItemStack.isItalics ? FontStyle.Italic : FontStyle.Normal)
        .position({ x: this.vm.canvasItemStack.dx, y: this.vm.canvasItemStack.dy })
        .decoration({
          type: this.vm.canvasItemStack.isUnderline ? TextDecorationType.Underline : TextDecorationType.None,
          color: this.vm.canvasItemStack.currentColor,
        })
        .padding(10)
        .borderColor(this.vm.saveText ? Color.Transparent : Color.White)
        .borderWidth(2)
        .borderStyle(BorderStyle.Solid)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            // 单击
            TapGesture({ count: 1 }).onAction(() => {
              if (this.vm.barIndex === 1) {
                let uiContext = this.getUIContext();
                let textEditContentNode =
                  new ComponentContent(uiContext, wrapBuilder<[TextEditDialogParams]>(textEditDialog), {
                    cloneText: this.vm.canvasItemStack.text,
                    canvasItemStack: this.vm.canvasItemStack,
                    close: () => {
                      uiContext.getPromptAction().closeCustomDialog(textEditContentNode);
                    },
                  } as TextEditDialogParams);

                uiContext.getPromptAction().openCustomDialog(textEditContentNode, {
                  levelMode: LevelMode.EMBEDDED,
                  onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                    UtilLog.info(0xFF00, 'TextEditDialog', JSON.stringify(dismissDialogAction.reason));
                  },
                })
                  .then(() => {
                    UtilLog.info('OpenCustomDialog complete');
                  })
                  .catch((error: BusinessError) => {
                    let message = (error as BusinessError).message;
                    let code = (error as BusinessError).code;
                    UtilLog.info(`OpenCustomDialog args error code is ${code}, message is ${message}`);
                  });
              }
            }),
            // 滑动
            PanGesture().onActionStart(() => {
              this.panGestureFlag = true;
            })
              .onActionUpdate((event: GestureEvent) => {
                if (event && this.panGestureFlag && this.selectedCanvasItem && this.vm.barIndex === 1) {
                  this.vm.canvasItemStack.dx = this.selectedCanvasItem.dx + event.offsetX;
                  this.vm.canvasItemStack.dy = this.selectedCanvasItem.dy + event.offsetY;
                }
              })
              .onActionEnd((event: GestureEvent) => {
                this.panGestureFlag = false;
                if (event && this.selectedCanvasItem && this.vm.barIndex === 1) {
                  this.vm.canvasItemStack.dx = this.selectedCanvasItem.dx + event.offsetX;
                  this.vm.canvasItemStack.dy = this.selectedCanvasItem.dy + event.offsetY;
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