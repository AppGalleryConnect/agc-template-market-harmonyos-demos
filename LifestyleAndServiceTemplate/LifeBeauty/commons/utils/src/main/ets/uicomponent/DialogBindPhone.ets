import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { CommonConstants } from '../common/Constant';
import { Logger } from '../common/Logger';
import { bindPhone } from './Login';
import { PopViewUtils } from '../common/PopViewUtils';
import { CommonUtils } from '../common/Utils';

export class BindParams {
  onBind?: () => void = () => {
  };

  constructor(onBinded?: () => void) {
    this.onBind = onBinded;
  }
}

/**
 * 判断未登录后，拉起关联手机号公共弹窗
 */
@Builder
export function DialogBindPhoneBuilder(parma: BindParams) {
  Column() {
    Column({ space: 20 }) {
      Text($r('app.string.bind_phone_title')).fontSize(18).fontWeight(FontWeight.Medium)
      Text($r('app.string.bind_phone_subtitle')).fontSize(16)
      Row() {
        Button($r('app.string.bind_phone_no'))
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .fontColor($r('sys.color.font_tertiary'))
          .onClick(() => {
            PopViewUtils.closePopView();
          })
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
            label: $r('app.string.bind_phone_yes'),
            styleOption: {
              plain: true,
              styleConfig: new functionalButtonComponentManager
                .ButtonConfig()
                .type(ButtonType.Normal)
                .borderWidth(0)
                .fontColor($r('app.color.common_theme_color')),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController()
            .onGetPhoneNumber((err, data) => {
              if (err) {
                CommonUtils.showErrorMessage(err);
                return;
              }
              Logger.info('succeeded in getting phone number. data.code = ' + data.code);
              bindPhone(data.code, parma.onBind);
            }),
        }).id('phoneFunctionalButtonId').clip(true)
      }.width(CommonConstants.FULL_PERCENT).justifyContent(FlexAlign.SpaceEvenly)
    }
    .padding(20)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(14)
  }
  .padding(10)
  .width(CommonConstants.FULL_PERCENT)
}
