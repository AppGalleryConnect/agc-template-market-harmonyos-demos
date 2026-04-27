export interface sheetsOption {
  title: string;
  action: () => void;
}

export interface cancelOption {
  value: string;
  action: () => void;
}

export interface ActionSheetOption {
  title: string;
  titleStyle?: MethodDecorator;
  message?: string;
  sheets: sheetsOption[];
  confirm: cancelOption;
  alignment?: DialogAlignment;
  offset?: Offset;
  cancel?: () => void;
}

//自定义列表弹窗
@CustomDialog
struct CustomActionSheetDialog {
  controller: CustomDialogController;
  option: ActionSheetOption = {
    title: '',
    sheets: [],
    confirm: {} as cancelOption,
    cancel: () => {
    }
  }

  build() {
    Column() {
      Column() {
        ForEach(this.option.sheets, (item: sheetsOption) => {
          Text(item.title)
            .fontSize(16)
            .fontColor(Color.Black)
            .padding({ top: 15, bottom: 15 })
            .width('100%')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.controller.close();
              item.action();
            })
        }, (item: sheetsOption, index: number) => item.title + '_' + index)
      }
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: $r('sys.float.corner_radius_level16'),
        topRight: $r('sys.float.corner_radius_level16') })
      .margin({ bottom: 10 })

      Text(this.option.confirm.value)
        .fontSize(16)
        .fontColor($r('app.color.color_66000000'))
        .width('100%')
        .height('8%')
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(Color.White)
        .onClick(() => {
          this.option.confirm.action();
          this.controller.close();
        })
    }
    .width('100%')
  }
}

//内部实例化弹窗
@ComponentV2
struct CustomActionSheetDialogPage {
  static dialogController: CustomDialogController = new CustomDialogController({ builder: CustomActionSheetDialog() })

  show(option: ActionSheetOption) {
    CustomActionSheetDialogPage.dialogController = new CustomDialogController({
      builder: CustomActionSheetDialog({ option }),
      alignment: option.alignment ? option.alignment : DialogAlignment.Bottom,
      offset: option.offset || { dx: 0, dy: 0 },
      customStyle: true,
      autoCancel: true,
      gridCount: 12,
      cancel: option.cancel
    })
    CustomActionSheetDialogPage.dialogController?.open();
  }

  build() {
  }
}

//外部调用
export class CustomActionSheet {
  static show(option: ActionSheetOption) {
    new CustomActionSheetDialogPage().show(option)
  }
}