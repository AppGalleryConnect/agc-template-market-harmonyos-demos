import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { iData, WindowUtil } from 'lib_foundation';
import { NavTitleBar } from 'lib_widget';
import { MemberStatusUtil } from 'membership';
import { BindPhoneUtil } from 'module_global_feature';
import { common } from '@kit.AbilityKit';

@Builder
export function buildBindPhonePage() {
  BindPhonePage();
}

@ComponentV2
export struct BindPhonePage {
  build() {
    NavDestination() {
      Column() {
        NavTitleBar({ title: '绑定手机号' })

        Column() {
          Image($r('app.media.img_bind_account'))
            .width('40%')
            .constraintSize({ maxHeight: '60%' })
            .objectFit(ImageFit.Contain)
          Text('绑定手机号后体验更多功能')
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(500)

          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
              label: '关联手机号',
              styleOption: {
                plain: true,
                styleConfig: new functionalButtonComponentManager
                  .ButtonConfig()
                  .type(ButtonType.Capsule)
                  .fontColor($r('app.color.font_color_level1_invert'))
                  .backgroundColor($r('app.color.theme_color'))
                  .width($r('app.string.size_percent_full'))
                  .height(40)
                  .constraintSize({ maxWidth: 400 })
                  .margin({ top: $r('app.float.space_l') }),
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onGetPhoneNumber((err, data) => {
                BindPhoneUtil.handleBind({
                  err,
                  code: data?.code,
                  needBack: true,
                  callback:()=>{
                    MemberStatusUtil.queryPurchase(WindowUtil.globalContext as common.UIAbilityContext).then((list) => {
                      if (list.nonRenewList.length) {
                        iData.global.userInfo.isMember = true;
                      }
                    });
                  }
                });
              }),
          }).margin($r('app.float.space_l'));
        }
        .height($r('app.string.size_percent_75'))
        .width($r('app.string.size_percent_full'))
        .justifyContent(FlexAlign.Center);
      }
      .height($r('app.string.size_percent_full'));
    }
    .hideTitleBar(true);
  }
}