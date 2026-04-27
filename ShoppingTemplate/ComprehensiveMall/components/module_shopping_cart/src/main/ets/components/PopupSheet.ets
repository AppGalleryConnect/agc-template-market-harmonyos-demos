import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { BreakpointSystem } from 'lib_foundation';
import { CommonSymbol } from 'lib_widget';
import { LOG_TAG } from '../commons/Constants';
import { PopupSheetController } from '../commons/Model';

@ComponentV2
export struct PopupSheet {
  // 显示状态
  @Param @Require visible: boolean = false;
  // 蒙层高度
  @Param maskHeight: Length = '100%';
  // 弹框标题
  @Param title: ResourceStr = '标题';
  // 自定义内容
  @BuilderParam customContentBuilder: CustomBuilder;
  // 弹框打开事件
  @Event onOpen: () => void = () => {
  };
  // 弹框关闭事件
  @Event onClose: () => void = () => {
  };
  @Event $visible: (visible: boolean) => void = () => {
  };
  private popupController: PopupSheetController = new PopupSheetController();
  private promptAction = this.getUIContext().getPromptAction();
  private dialogId: number = 0;

  @Monitor('visible')
  onChangeVisible() {
    if (this.visible) {
      this.open();
    } else {
      this.popupController.hide();
      setTimeout(() => {
        try {
          this.promptAction.closeCustomDialog(this.dialogId);
        } catch (err) {
          Logger.error(LOG_TAG, 'close custom dialog failed. error:' + JSON.stringify(err))
        }
      }, 100);
    }
  }

  async open() {
    try {
      this.dialogId = await this.promptAction.openCustomDialog({
        builder: () => {
          this.ContentBuilder();
        },
        width: BreakpointSystem.isTablet ? '40%' : '100%',
        backgroundBlurStyle: BlurStyle.NONE,
        cornerRadius: BreakpointSystem.isTablet ? 32 : 0,
        alignment: BreakpointSystem.isTablet ? DialogAlignment.Center : DialogAlignment.Bottom,
        isModal: true,
        maskColor: 0x66000000,
        maskRect: {
          x: 0,
          y: 0,
          width: '100%',
          height: this.maskHeight,
        },
        onDidAppear: () => {
          this.onOpen();
        },
        onDidDisappear: () => {
          this.onClose();
        },
        onWillDismiss: (action: DismissDialogAction) => {
          // 1 点击遮罩返回  0 左滑右滑返回
          if (action.reason === DismissReason.PRESS_BACK || action.reason === DismissReason.TOUCH_OUTSIDE) {
            this.close();
          }
        },
      });
    } catch (err) {
      Logger.error(LOG_TAG, 'open custom dialog failed. error:' + JSON.stringify(err))
    }
  }

  // 关闭弹框
  close() {
    this.$visible(false);
  }

  build() {
  }

  @Builder
  ContentBuilder() {
    PopupSheetContent({
      title: this.title,
      popupController: this.popupController,
      customContentBuilder: this.customContentBuilder,
      close: () => {
        this.close();
      },
    });
  }
}

@ComponentV2
export struct PopupSheetContent {
  // 弹框标题
  @Param title: ResourceStr = '标题';
  @Param popupController: PopupSheetController = new PopupSheetController();
  // 自定义内容
  @BuilderParam customContentBuilder: CustomBuilder;
  // 关闭事件
  @Event close: () => void = () => {
  };
  // y轴偏移
  @Local translateY: string | number = '';

  aboutToAppear(): void {
    this.popupController.hide = (): void => this.init();
    this.init();
  }

  init() {
    this.translateY = '100%';
  }

  build() {
    Column() {
      Column({ space: 16 }) {
        this.Header();

        if (this.customContentBuilder) {
          this.customContentBuilder();
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('80%')
      .backgroundColor($r('app.color.background_color_primary'))
      .borderRadius({
        topLeft: $r('app.float.border_radius_xl'),
        topRight: $r('app.float.border_radius_xl'),
      })
      .padding(16)
      .translate({ x: 0, y: this.translateY })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .onAppear(() => {
        setTimeout(() => {
          this.translateY = 0;
        });
      });
    }
    .clip(true);
  }

  @Builder
  Header() {
    Row() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1);

      CommonSymbol({
        src: $r('sys.symbol.xmark'),
        fontSize: 16,
      })
        .onClick(() => {
          this.close && this.close();
        });
    }
    .padding({
      bottom: $r('app.float.space_s'),
    })
  }
}