import { ComponentContent } from '@kit.ArkUI';
import { GlobalContext } from '../basic/GlobalContext';
import { TCLogger } from '../basic/TCLogger';
import { BarVM } from '../model/BarVM';
import { MsgDialogModel } from '../model/MsgDialogModel';
import { HMPromptAction } from '../util/HMPromptAction';
import { UnitConverter } from '../util/UnitConverter';

const TAG: string = 'MessageReminderDialog';

export class MessageReminderDialog {
  private constructor() {
  }

  static ShowMsgReminderPopup(vm: MsgDialogModel) {
    if (HMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildMsgReminderPopup), vm);
        HMPromptAction.uiContext = uiContext;
        HMPromptAction.contentNode = contentNode;
        HMPromptAction.options = {
          alignment: DialogAlignment.Top,
          maskRect: {
            x: 0,
            y: UnitConverter.px2vp(BarVM.instance.statusBarHeight.value),
            width: '100%',
            height: 140
          },
          maskColor: Color.Transparent,
          autoCancel: false
        };
        HMPromptAction.openDialog();
        setTimeout(() => {
          HMPromptAction.closeDialog();
        }, 2000);
      } else {
        TCLogger.info(TAG, `GlobalContext uiContext is empty`);
      }
    }
  }

  static CloseMsgReminderPopup() {
    HMPromptAction.closeDialog();
  }
}

@Builder
function buildMsgReminderPopup(vm: MsgDialogModel) {
  Row() {

    Image(vm.img)
      .width($r('app.float.vp_34'))
      .height($r('app.float.vp_34'))

    Blank().width($r('app.float.vp_12'))

    Column() {

      Row() {
        Text(vm.title)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFE84026')
          .lineHeight($r('app.float.vp_20'))

        Text(vm.time)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height($r('app.float.vp_20'))

      Blank().height($r('app.float.vp_6'))

      Text(vm.subtitle)
        .fontSize($r('sys.float.Body_S'))
        .fontColor('#E6000000')
        .lineHeight($r('app.float.vp_18'))
        .maxLines(1)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .height($r('app.float.vp_56'))
  }
  .backgroundColor(0xffffff)
  .alignItems(VerticalAlign.Top)
  .width('90%')
  .height(76)
  .borderRadius($r('sys.float.corner_radius_level8'))
  .margin({ top: 32 + UnitConverter.px2vp(BarVM.instance.statusBarHeight.value) })
  .padding($r('app.float.vp_16'))
  .shadow({
    radius: 32,
    color: '#1A000000'
  })
}