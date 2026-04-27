import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BarVM,
  BreakpointModel,
  CommonHeader,
  GlobalContext,
  OHDialog,
  OHDialogModel,
  TCLogger,
  TimeUtil,
  UserInfo
} from 'common';
import { ChooseDateModel } from '../viewmodel/ChooseDateModel';
import { SkipStepModel } from '../viewmodel/SkipStepModel';
import { phoneRouterControl } from 'oh_router';
import { commonDialogBuilder } from '../comp/CommonDialogBuilder';

const TAG = 'PersonInfoBirthdayPage';

@Builder
export function PersonInfoBirthdayPageBuilder(): void {
  PersonInfoBirthdayPage()
}

@ComponentV2
export struct PersonInfoBirthdayPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local selectDate: Date = new Date();
  @Local onReturnClick: () => void = () => {
  }

  @Builder
  dataPickerDialogBuilder(vm: OHDialogModel) {
    DatePicker({
      selected: vm.selected,
      start: new Date('1900-02-01'),
      end: new Date(),
    })
      .height(200)
      .width('100%')
      .selectedTextStyle({ color: $r('sys.color.font_emphasize') })
      .onDateChange((date: Date) => {
        vm.selected = date;
      })

    Blank().height($r('app.float.vp_12'))
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
      Text('请选择你的出生年月')
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_L'))
      Blank().height($r('app.float.vp_24'));

      Row() {
        Text(this.userInfo.birthday.length > 0 ? this.userInfo.birthday : '出生年月日选择')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.color_66000000'))
        Blank().width($r('app.float.vp_2'));
        Image($r('app.media.iconRight'))
          .width($r('app.float.vp_20'))
          .aspectRatio(1)
          .objectFit(ImageFit.Contain)
      }
      .justifyContent(FlexAlign.Center)
      .height($r('app.float.vp_60'))
      .width($r('app.float.vp_220'))
      .onClick(() => {
        let dialogVM = new ChooseDateModel();
        dialogVM.selected = this.selectDate;
        dialogVM.onValueConfirmClick = (model: OHDialogModel) => {
          this.selectDate = model.selected;
          this.userInfo.birthday = TimeUtil.formatDate(model.selected.getTime(), TimeUtil.PATTERN_DATE_HYPHEN);
          let tempTime = TimeUtil.getDuration(new Date().getTime(), model.selected.getTime());
          this.userInfo.age = Math.floor(tempTime / 1000 / 60 / 60 / 24 / 30 / 12).toString();
        }
        dialogVM.childBuilder = this.dataPickerDialogBuilder
        OHDialog.ShowPopup(dialogVM)
      })

      Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).width($r('app.float.vp_220'))

      Blank().height($r('app.float.vp_38'));
      Text('你的年龄')
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_L'))
      Blank().height($r('app.float.vp_12'));

      Row() {
        Text(this.userInfo.age.length > 0 ? this.userInfo.age : '0')
          .fontColor(Color.Black)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
        Blank().width($r('app.float.vp_4'));
        Text('岁')
          .fontColor($r('app.color.color_99000000'))
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Regular)
      }
      .justifyContent(FlexAlign.Center)
      .height($r('app.float.vp_60'))
      .width($r('app.float.vp_220'))

      Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).width($r('app.float.vp_220'))

      Blank().layoutWeight(1)

      Button('开启你的健康之旅')
        .type(ButtonType.Capsule)
        .width('100%')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor($r('app.color.color_0A59F7'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          TCLogger.info(TAG, `on confirm next`);
          if (this.userInfo.birthday.length === 0) {
            GlobalContext.getUIContext().getPromptAction().showToast({
              message: '请选择您的出生年月日',
            });
            return;
          }
          this.userInfo.isEditOk = true;
          phoneRouterControl.popPage({ popData: 'loginSuccess' })
        })
      Blank().height($r('app.float.vp_16'))

      Button('跳过')
        .type(ButtonType.Capsule)
        .width('100%')
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          TCLogger.info(TAG, `on confirm go`);
          let dialogVM = new SkipStepModel();
          dialogVM.subtitle = '跳过后会影响展现真实身体数据'
          dialogVM.onValueConfirmClick = () => {
            this.userInfo.isEditOk = true;
            phoneRouterControl.popPage({ popData: 'loginSuccess' })
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
