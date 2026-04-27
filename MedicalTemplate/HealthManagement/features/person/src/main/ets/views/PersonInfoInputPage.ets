import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, CommonHeader, GlobalContext, OHDialog,
  OHDialogModel,
  RouterMap, TCLogger, UserInfo } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PersonInfoBirthdayPageBuilder } from './PersonInfoBirthdayPage';
import { SkipStepModel } from '../viewmodel/SkipStepModel';
import { commonDialogBuilder } from '../comp/CommonDialogBuilder';

const TAG = 'PersonInfoInputPage';

@Builder
export function PersonInfoInputPageBuilder(): void {
  PersonInfoInputPage()
}

@ComponentV2
export struct PersonInfoInputPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local onReturnClick: () => void = () => {
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '个人信息',
        onReturnClick: this.onReturnClick,
        backgroundColorParam: Color.Transparent,
        rowFlexAlign: FlexAlign.SpaceBetween,
      })

      Blank().height($r('app.float.vp_38'));

      Text('请选择你的性别')
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_L'))
      Blank().height($r('app.float.vp_16'));
      Row() {
        Row() {
          Image(this.userInfo.gender === '男' ?
          $r('app.media.person_sex_man_select') :
          $r('app.media.person_sex_man_unselect'))
            .width(14)
            .aspectRatio(1)
          Blank().width($r('app.float.vp_4'));
          Text('男')
            .fontColor(this.userInfo.gender === '男' ? Color.White : Color.Black)
            .fontSize($r('sys.float.Body_S'))
        }
        .width($r('app.float.vp_72'))
        .height($r('app.float.vp_28'))
        .backgroundColor(this.userInfo.gender === '男' ? $r('app.color.color_0A59F7') : '#f6f6f6')
        .borderRadius($r('sys.float.corner_radius_level7'))
        .clip(true)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.userInfo.gender = '男')

        Blank().width($r('app.float.vp_76'));
        Row() {
          Image(this.userInfo.gender === '女' ?
          $r('app.media.person_sex_woman_select') :
          $r('app.media.person_sex_woman_unselect'))
            .width($r('app.float.vp_14'))
            .aspectRatio(1)
          Blank().width($r('app.float.vp_4'));
          Text('女')
            .fontColor(this.userInfo.gender === '女' ? Color.White : Color.Black)
            .fontSize($r('sys.float.Body_S'))
        }
        .width($r('app.float.vp_72'))
        .height($r('app.float.vp_28'))
        .backgroundColor(this.userInfo.gender === '女' ? $r('app.color.color_0A59F7') : '#f6f6f6')
        .borderRadius($r('sys.float.corner_radius_level7'))
        .clip(true)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.userInfo.gender = '女')
      }
      .height($r('app.float.vp_60'))
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Blank().height($r('app.float.vp_50'));
      Text('请输入你的身高')
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_L'))
      Blank().height($r('app.float.vp_12'));

      Row() {
        TextInput({
          text: this.userInfo.height > 0 ? this.userInfo.height.toString() : '',
          placeholder: '0'
        })
          .type(InputType.NUMBER_DECIMAL)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(Color.Black)
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .placeholderColor($r('sys.color.font_secondary'))
          .backgroundColor(Color.Transparent)
          .textAlign(TextAlign.Center)
          .height($r('app.float.vp_60'))
          .onChange((value: string) => {
            const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(value);
            if (isValidInput) {
              this.userInfo.height = Number(value);
            } else {
              GlobalContext.getUIContext().getPromptAction().showToast({
                message: '请输入正确数据，不要包含其他字符',
              });
            }
          })

        Text('厘米')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.mask_secondary'))

      }
      .height($r('app.float.vp_60'))
      .width($r('app.float.vp_220'))

      Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).width($r('app.float.vp_260'))

      Blank().height($r('app.float.vp_50'));
      Text('请输入你的体重')
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_L'))
      Blank().height($r('app.float.vp_12'));

      Row() {
        TextInput({
          text: this.userInfo.weight > 0 ? this.userInfo.weight.toString() : '',
          placeholder: '0'
        })
          .type(InputType.NUMBER_DECIMAL)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(Color.Black)
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .placeholderColor($r('sys.color.font_secondary'))
          .backgroundColor(Color.Transparent)
          .textAlign(TextAlign.Center)
          .height($r('app.float.vp_60'))
          .onChange((value: string) => {
            const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(value);
            if (isValidInput) {
              this.userInfo.weight = Number(value);
            } else {
              GlobalContext.getUIContext().getPromptAction().showToast({
                message: '请输入正确数据，不要包含其他字符',
              });
            }
          })

        Text('公斤')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.mask_secondary'))

      }
      .height($r('app.float.vp_60'))
      .width($r('app.float.vp_220'))

      Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).width($r('app.float.vp_260'))
      Blank().layoutWeight(1)

      Button('下一步')
        .width('100%')
        .type(ButtonType.Capsule)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor($r('app.color.color_0A59F7'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          TCLogger.info(TAG, `on confirm next`);
          if (this.userInfo.gender.length === 0) {
            GlobalContext.getUIContext().getPromptAction().showToast({
              message: '请选择您的性别',
            });
            return;
          }
          if (this.userInfo.height === 0) {
            GlobalContext.getUIContext().getPromptAction().showToast({
              message: '请输入您的身高',
            });
            return;
          }
          if (this.userInfo.weight === 0) {
            GlobalContext.getUIContext().getPromptAction().showToast({
              message: '请输入您的体重',
            });
            return;
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PERSONAL_INFO_BIRTHDAY_PAGE,
            builder: wrapBuilder(PersonInfoBirthdayPageBuilder),
            onPop: (_popInfo: PopInfo) => {
              phoneRouterControl.popPage({ popData: 'loginSuccess' })
            }
          })
        })
      Blank().height($r('app.float.vp_16'))

      Button('跳过')
        .width('100%')
        .type(ButtonType.Capsule)
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          TCLogger.info(TAG, `on confirm go`);
          let dialogVM = new SkipStepModel();
          dialogVM.subtitle = '跳过后会影响展现真实身体数据'
          dialogVM.onValueConfirmClick = () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.PERSONAL_INFO_BIRTHDAY_PAGE,
              builder: wrapBuilder(PersonInfoBirthdayPageBuilder),
              onPop: (_popInfo: PopInfo) => {
                phoneRouterControl.popPage({ popData: 'loginSuccess' })
              }
            })
          }
          dialogVM.childBuilder = commonDialogBuilder
          OHDialog.ShowPopup(dialogVM)
        })

      Blank().height(BarVM.instance.aiBarH)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding
    })
  }

  build() {
    NavDestination() {
      this.render();
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      context.terminateSelf((err: BusinessError) => {
        if (err !== undefined) {
          TCLogger.error(TAG, 'terminate self failed. error:' + JSON.stringify(err));
        } else {
          TCLogger.info(TAG, 'terminate self success');
        }
      });
      return true
    })
  }
}
