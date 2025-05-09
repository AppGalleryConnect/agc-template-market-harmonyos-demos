import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { FrameworkUtil } from 'commonlib';
import { CommonHeader } from '../../components/CommonHeader/Index';
import { BindPhoneUtil } from './BindPhoneUtil';

@Builder
export function bindPhonePageBuilder() {
  BindPhonePage();
}

@ComponentV2
export struct BindPhonePage {
  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '绑定手机号' });

        Column() {
          Image($r('app.media.img_bind_account'))
            .width($r('app.string.width_percent_40'));
          Text('绑定手机号后体验更多功能')
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(500)
            .fontSize($r('app.string.font_size_18'));
          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
              label: '快速验证手机号',
              styleOption: {
                plain: true,
                styleConfig: new functionalButtonComponentManager
                  .ButtonConfig()
                  .fontColor($r('app.color.font_color_level1_invert'))
                  .backgroundColor($r('app.color.system_theme_color'))
                  .width($r('app.string.width_percent_full'))
                  .margin({ top: $r('app.string.margin_l') }),
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onGetPhoneNumber((err, data) => {
                BindPhoneUtil.handleFunctionalButtonClick(err, data?.code);
              }),
          }).margin($r('app.string.margin_l'));
        }
        .height($r('app.string.height_percent_75'))
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.Center);

        Blank();

        Text('回到首页')
          .fontColor($r('app.color.font_color_level2'))
          .fontSize($r('app.string.font_size_14'))
          .onClick(() => {
            FrameworkUtil.backToHome();
          });
      }
      .height($r('app.string.height_percent_full'));

    }
    .hideTitleBar(true);
  }
}