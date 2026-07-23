import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../constants/CommonConstants'
import { GridRowColSetting } from '../constants/GridRowColSetting'
import { RouterMap } from '../constants/RouterMap'
import { PopViewUtils } from '../utils/PopViewUtils'
import { RouterModule } from '../utils/RouterModule'
import { SafeUtil } from '../utils/SafeUtil'
import { Logger } from '../utils/Logger'

@Builder
export function agreeDialogBuilder() {
  AgreeDialog()
}

const TAG = '[AgreeDialog]';

@ComponentV2
struct AgreeDialog {
  build() {
    NavDestination() {
      Column() {
        Column() {
          Text('您需要同意协议才能体验天气模板')
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
          Text() {
            Span('本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
              .fontColor($r('sys.color.font_secondary'))
            Span('XX业务与隐私的声明、权限使用说明')
              .fontColor($r('app.color.common_theme_color'))
              .onClick(() => {
                PopViewUtils.closePopView();
                RouterModule.push({ url: RouterMap.PRIVACY_POLICY });
              })
            Span('。')
              .fontColor($r('sys.color.font_secondary'))
          }
          .fontSize($r('sys.float.Caption_M'))
          .margin({ top: 16, bottom: 16 })

          Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
          Row({ space: CommonConstants.SPACE_16 }) {
            Button('退出应用')
              .fontColor($r('sys.color.font_emphasize'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                (this.getUIContext().getHostContext() as common.UIAbilityContext).terminateSelf()
                  .catch((e: BusinessError) => {
                    Logger.error(TAG, 'Fail to terminateSelf, error: ' + JSON.stringify(e));
                  });
              })
            Button('同意并继续')
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                SafeUtil.setAgreed();
              })
          }
          .margin({ top: 24 })
        }
        .backgroundColor($r('sys.color.comp_background_primary'))
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius(32)
        .padding(CommonConstants.SPACE_16)
      }
      .justifyContent(FlexAlign.Center)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
      .padding({
        left: CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16,
      })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .backgroundColor('rgba(0,0,0,0.5)')
    .onBackPressed(() => {
      return true;
    })
  }
}