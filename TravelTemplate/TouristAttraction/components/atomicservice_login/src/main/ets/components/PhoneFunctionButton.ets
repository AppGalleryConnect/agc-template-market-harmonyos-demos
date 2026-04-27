import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const DOMAIN = 0xff00;
const TAG = '[FunctionButton]';

@ComponentV2
export struct PhoneFunctionButton {
  /**
   * 获取手机号的回调
   */
  @Event bindPhone: (data: string | undefined) => void;
  /**
   * 获取失败的回调
   */
  @Event onGetPhoneError: (err: BusinessError) => void = () => {
  };

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
        label: '关联账户',
        // 调整Button样式
        styleOption: {
          plain: true,
          hoverClass: functionalButtonComponentManager.HoverClassType.NONE,
          styleConfig: new functionalButtonComponentManager
            .ButtonConfig()
            .type(ButtonType.Normal)
            .padding(0)
            .backgroundColor(Color.Transparent)
            .size({ height: 16 })
            .fontColor($r('sys.color.font_primary'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width(76)
            .align(Alignment.End),
        },
      },
      // 当OpenType为“GET_PHONE_NUMBER”时，回调必须选择“onGetPhoneNumber”
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onGetPhoneNumber((err, data) => {
          if (err) {
            // 错误日志处理。
            UtilLog.error(DOMAIN, TAG, 'fail to get phone number, error: ' + err.code, err.message);
            this.onGetPhoneError(err);
            return;
          }
          // 成功日志处理。
          UtilLog.info(DOMAIN, TAG, 'succeeded in getting phone number. data.code = ' + data.code);
          this.bindPhone(data.code);
        }),
    })
  }
}