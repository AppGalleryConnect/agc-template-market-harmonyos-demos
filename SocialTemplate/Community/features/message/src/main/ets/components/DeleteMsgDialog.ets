import { OHDialogModel } from 'common';

@ComponentV2
struct DeleteMsgDialog {
  @Param @Require dialogVM: DeleteMsgModel;

  build() {
    Row() {
      Radio({
        value: 'Radio1', group: 'radioGroup',
        indicatorType: RadioIndicatorType.TICK
      }).checked($$this.dialogVM.isDelete)
        .height($r('app.float.vp_20'))
        .width($r('app.float.vp_20'))
        .hitTestBehavior(HitTestMode.None)
      Blank().height($r('app.float.vp_8'))
      Text(this.dialogVM.message)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.color_666'))
        .lineHeight($r('app.float.vp_20'))
    }
    .height($r('app.float.vp_20'))
    .onClick(() => {
      this.dialogVM.isDelete = !this.dialogVM.isDelete;
    })
  }
}

@Builder
export function dialogDeleteMsgBuilder(vm: Object) {
  DeleteMsgDialog({
    dialogVM: vm as DeleteMsgModel
  })
}

@ObservedV2
export class DeleteMsgModel extends OHDialogModel {
  @Trace title: string = '是否删除当前聊天会话';
  @Trace message: string = '清空聊天记录';
  @Trace isDelete: boolean = false;
  confirmTitle: string = '删除';
  confirmFontColor: ResourceColor = $r('sys.color.warning');
}