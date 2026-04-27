import { HintParam } from '../model/Index';

@Builder
export function privacyCheckHint(param: HintParam) {
  Column({ space: 24 }) {
    Text('请先阅读并勾选会员服务协议').fontColor($r('sys.color.font_primary'));
    Text('我知道了').fontWeight(FontWeight.Medium).fontColor($r('sys.color.multi_color_07')).onClick(() => {
      param.uiContext.getPromptAction().closeCustomDialog(param.node);
    });
  }
  .width('90%')
  .padding(24)
  .backgroundColor($r('sys.color.comp_background_primary'))
  .borderRadius(32)
  .constraintSize({ maxWidth: 360 })
}