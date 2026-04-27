import { OHDialogModel } from 'common';

@ComponentV2
struct MsgInputDialog {
  @Param @Require dialogVM: MsgInputModel;

  build() {
    TextInput({
      text: this.dialogVM.value,
      placeholder: this.dialogVM.placeholder
    })
      .type(InputType.Normal)
      .cancelButton({
        style: CancelButtonStyle.INPUT,
        icon: {
          size: $r('app.float.vp_16'),
          color: $r('sys.color.font_secondary')
        }
      })
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.mask_secondary'))
      .placeholderFont({ size: $r('sys.float.Body_L') })
      .placeholderColor($r('sys.color.font_secondary'))
      .backgroundColor(Color.Transparent)
      .height($r('app.float.vp_48'))
      .width('100%')
      .onChange((value: string) => {
        this.dialogVM.value = value;
      })
  }
}

@Builder
export function dialogMsgInputBuilder(vm: Object) {
  MsgInputDialog({
    dialogVM: vm as MsgInputModel
  })
}

@ObservedV2
export class MsgInputModel extends OHDialogModel {
  @Trace value: string = '';
  @Trace placeholder: string = '';
}