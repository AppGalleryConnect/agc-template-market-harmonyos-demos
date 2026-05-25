import { AppUtil, NotificationUtil, WantUtil } from '@ohos_agcit/notes_utils';
import { SettingController } from '../controller/SettingController';
import { setAutoColorMode, setDarkColorMode, setLightColorMode, ThemeController } from '../controller/ThemeController';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { rightArrow } from 'login';

@ComponentV2
export struct SingleArrow {
  @Param @Once @Require text: string;
  build() {
    Row() {
      Text(this.text)
        .textExtend()
        .fontColor($r('sys.color.font_primary'));
      Blank();
      rightArrow()
    }
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }
}


@ComponentV2
export struct SingleToggle {
  @Param @Once @Require text: string;
  @Param @Require toggleSwitch: boolean;
  @Param @Once @Require toggleClick: VoidCallback;

  build() {
    Row() {
      Text(this.text)
        .textExtend()
        .fontColor($r('sys.color.font_primary'));
      Blank();
      Toggle({
        type: ToggleType.Switch,
        isOn: this.toggleSwitch,
      })
        .onClick(() => {
          this.toggleClick();
        });
    }
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }
}

/**
 * 通知开关
 */
@ComponentV2
export struct NoticeToggle {
  settingController: SettingController = SettingController.instance
  @Param @Once @Require text: string;
  @Local isNoticeGrant: boolean = false;

  aboutToAppear(): void {
    // 进入设置页时刷新一次系统通知权限，保证与系统设置一致
    NotificationUtil.isNotificationEnabled().then((grant: boolean) => {
      this.isNoticeGrant = grant;
      this.settingController.isNoticeGrant = grant;
    }).catch((_e: Error) => {
      this.isNoticeGrant = false;
      this.settingController.isNoticeGrant = false;
    });
  }

  build() {
    Row() {
      Text(this.text)
        .textExtend()
        .fontColor($r('sys.color.font_primary'));
      Blank();
      Toggle({
        type: ToggleType.Switch,
        // 只绑定“系统通知权限”状态：与首次安装弹窗、系统设置保持同步
        isOn: this.isNoticeGrant,
      })
        .onClick(() => {
          // 点击开关：统一跳转系统通知设置页，让用户直接调整系统权限
          NotificationUtil.clearBadge();
          WantUtil.toSetting('application_info_entry');
        });

    }
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }
}


@ComponentV2
export struct DarkModeToggle {
  private themeController: ThemeController = ThemeController.instance;
  build() {
    Column(){
      Row() {
        Text('跟随系统')
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        Toggle({
          type: ToggleType.Switch,
          isOn: this.themeController.isFollowSystemSetting
        })
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.themeController.isFollowSystemSetting = true;
              this.themeController.enableDarkMode = false;
              setAutoColorMode(AppUtil.getContext());
            } else {
              this.themeController.isFollowSystemSetting = false;
              if (this.themeController.enableDarkMode) {
                setDarkColorMode(AppUtil.getContext());
              } else {
                setLightColorMode(AppUtil.getContext());
              }
            }
          })
      }
      .width('100%')
      .height(56);

      Divider()
        .height(0.5)
        .width('100%')
        .color($r('sys.color.comp_divider'))

      Row() {
        Text('夜间模式')
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        Toggle({
          type: ToggleType.Switch,
          isOn: this.themeController.enableDarkMode
        })
          .onChange((isOn: boolean) => {
            this.themeController.enableDarkMode = isOn;
            if (isOn) {
              this.themeController.isFollowSystemSetting = false;
              this.themeController.currentColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
              setDarkColorMode(AppUtil.getContext());
            } else if (!this.themeController.isFollowSystemSetting) {
              setLightColorMode(AppUtil.getContext());
              this.themeController.currentColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
            }
          })
      }
      .width('100%')
      .height(56);
    }
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .height(112.5)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
  }
}

@ComponentV2
export struct MergeArrow {
  @Param @Once @Require text1: string;
  @Param @Once @Require text1Click: VoidCallback;
  @Param @Once @Require text2: string;
  @Param @Once @Require text2Click: VoidCallback;

  build() {
    Column(){
      Row() {
        Text(this.text1)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text1Click();
      })
      Divider()
        .height(0.5)
        .width('100%')
        .color($r('sys.color.comp_divider'))
      Row(){
        Text(this.text2)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text2Click();
      })
    }
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .height(112.5)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
  }
}

@Extend(Text)
function textExtend() {
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
}