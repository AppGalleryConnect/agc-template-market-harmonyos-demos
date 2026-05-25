import { AppStorageV2, CustomContentDialog, window } from '@kit.ArkUI';
import { AccountUtil, CommonModel, PreferencesUtil } from '@ohos_agcit/driver_license_exam_commonlib';
import { CommonConstants } from '@ohos_agcit/driver_license_exam_guide';
import {
  AboutModel,
  SettingItem,
  SettingGroup,
  SettingType,
  SettingView,
  SupportedSetting,
  WebModel,
  IFontModel,
} from 'app_setting'
import { checkUpdateAndShowDialog } from 'check_app_update';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { FontModel } from 'app_setting'
import { ExamController} from 'exam'

@Builder
export function PersonalSettingBuilder() {
  PersonalSetting();
}

@Entry
@ComponentV2
struct PersonalSetting {
  topRectHeight: number = AppStorage.get('topRectHeight') || 0;
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') || 0;
  vm: CommonModel = CommonModel.instance;
  examController:ExamController = ExamController.instance;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local followSys:boolean = AppStorage.get('followSys') || false;

  @Local group1: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('个人信息')
        .setRouterParam({ routerName: 'PersonalInfo' }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('隐私设置')
        .setRouterParam({ routerName: 'SettingPrivacy' })
        .setClickEvent(() => {
          this.vm.navStack.pushPathByName('SettingPrivacy',true);
        })
    ])

  @Local group2: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.FONT_SIZE)
        .setExtraParams({
          followSystem: this.followSys,
          fontSizeRatio: this.examController.fontSizeRatio,
          onChange: (followSystem: boolean, fontSizeRatio: number, sysFontSizeScale: number) => {
            // 回调调整后的字体大小设置值
            AppStorage.setOrCreate('followSys', followSystem)
            // this.followSys = followSystem;
            const follow = !followSystem;
            (AppStorage.get('windowStage') as window.WindowStage).setDefaultDensityEnabled(follow);
             this.examController.fontSizeRatio = fontSizeRatio;
             this.examController.sysFontSizeScale = sysFontSizeScale;

          },
        } as IFontModel),
      new SettingItem()
        .setSupportedType(SupportedSetting.LIGHT_DARK_MODE)
        .setSelectIndex(AppStorage.get('lightDarkMode') as number)
        .setOnChange((isOn) => {
          let value  = 0;
          if (isOn === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
            value = 0
          } else if (isOn === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
            value = 1
          } else if (isOn === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
            value = 2
          }
          const preferencesUtil = PreferencesUtil.getInstance();
          const preference = preferencesUtil.getPreferences(this.getUIContext().getHostContext() as Context)
          preferencesUtil.preferencesPut(preference, 'lightDarkMode', value);
          AppStorage.setOrCreate('lightDarkMode', value)
        }),
      new SettingItem()
        .setSupportedType(SupportedSetting.PUSH_SWITCH)
        .setOnChange((isOn) => {
          // 获取推送开关情况：isOn as boolean
        }),
    ])

  @Local group3: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('检测版本')
        .setRouterParam({ routerName: 'SettingPrivacy' })
        .setClickEvent(() => {
          checkUpdateAndShowDialog(this.getUIContext())
        }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('关于我们')
        .setRouterParam({ routerName: 'SettingPrivacy' })
        .setClickEvent(() => {
          this.vm.navStack.pushPathByName('SettingAbout',true);
        })
    ])


  build() {
    NavDestination() {
      Column() {
        SettingView({
          isLogin: true,
          pathStack: this.vm.navStack,
          settingList: [this.group1, this.group2,this.group3],
          signOutApi:() => {
            return new Promise(() => {
              AccountUtil.loginOut();
              this.vm.navStack.pop();
            })
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('设置')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight) + 10,
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
  }
}



@Extend(Text)
function textExtend() {
  .fontSize(16)
  .fontFamily('鸿蒙黑体')
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
  .fontColor($r('sys.color.black'));
}
