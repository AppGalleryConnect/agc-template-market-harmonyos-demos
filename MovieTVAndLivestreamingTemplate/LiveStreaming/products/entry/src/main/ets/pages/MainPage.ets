import { display } from '@kit.ArkUI';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { TabListItem } from '../model/TabListItem';
import { MainVM } from '../viewmodels/MainVM';
import { BarVM } from '@agctemplate/widgets';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';

const permissions: Array<Permissions> = ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'];
const TAG = '[MainPage]';

enum isCommit {
  onChange = 0,
  fail = 1,
  success = 2
}

class TabStyle {
  static readonly BAR_HEIGHT = 48;
  static readonly ANIMATION_DURATION = 0;
  static readonly ICON_SIZE = 24;
}

@ComponentV2
struct MainPage {
  vm: MainVM = MainVM.instance;
  @Local selectedIndex: number = 0
  @Local isPermission: isCommit = isCommit.onChange
  context: common.UIAbilityContext =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local isLandscapeTablet: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
      deviceInfo.deviceType === 'tablet';
  callback: Callback<number> = (data: number) => {
    console.info(data.toString())
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
        deviceInfo.deviceType === 'tablet') {
      this.isLandscapeTablet = true
    } else {
      this.isLandscapeTablet = false
    }
  };

  aboutToAppear(): void {
    try {
      display.on('change', this.callback);
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback)
    } catch (e) {
    }
  }

  @Monitor('isPermission')
  onPermissionChange() {
    if (this.isPermission === isCommit.success) {
      RouterModule.push({ url: RouterMap.Camera_Page })
    } else if (this.isPermission === isCommit.fail) {
      this.isPermission = isCommit.onChange
      this.vm.curIndex = 0
    }
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Column({ space: 2 }) {
        SymbolGlyph(item.icon)
          .fontSize(item.label === '开直播' ? 40 : TabStyle.ICON_SIZE)
          .fontColor([this.vm.curIndex === index || item.label === '开直播' ? '#EE5D1A' :
            $r('sys.color.icon_tertiary')])
        if (item.label !== '开直播') {
          Text(item.label)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Caption_M'))
            .fontColor(this.vm.curIndex === index ?
              '#EE5D1A' : $r('sys.color.font_secondary'))
        }
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(this.isLandscapeTablet ? 133 : TabStyle.BAR_HEIGHT)
    }
    .padding({ bottom: BarVM.instance.aiBarH })
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({
          barPosition: this.isLandscapeTablet ? BarPosition.Start : BarPosition.End,
          index: $$this.vm.curIndex,
          controller: this.vm.controller
        }) {
          ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
            TabContent() {
              if (index !== 1) {
                item.component?.builder();
              }
            }
            .tabBar(this.tabBarBuilder(item, index))
          }, (item: TabListItem, index) => JSON.stringify(item) + '_' + index)
        }
        .onChange((index: number) => {
          if (index === 1) {
            this.selectedIndex = index
            if (this.isPermission === isCommit.success) {
              RouterModule.push({ url: RouterMap.Camera_Page })
            } else {
              this.reqPermissionsFromUser(permissions, this.context)
            }
          }
        })
        .vertical(this.isLandscapeTablet ? true : false)
        .scrollable(false)
        .barMode(this.isLandscapeTablet ? BarMode.Scrollable : BarMode.Fixed)
        .barHeight('auto')
        .barWidth(this.isLandscapeTablet ? 96 : 'auto')
        .animationDuration(TabStyle.ANIMATION_DURATION)
        .barOverlap(this.isLandscapeTablet ? false : true)
      }
    }
    .onWillShow(() => {
      if (this.selectedIndex === 1) {
        this.vm.curIndex = 0
      }
    })
  }

  // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
  reqPermissionsFromUser(permissions: Array<Permissions>,
    context: common.UIAbilityContext) {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗。
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      let isFirstTime: Array<boolean> = data.dialogShownResults!
      let length: number = grantStatus.length;
      if (isFirstTime[0]) {
        if (!grantStatus[0] && !grantStatus[1]) {
          this.isPermission = isCommit.success
        } else {
          this.isPermission = isCommit.fail
        }
      } else {
        if (!grantStatus[0] && !grantStatus[1]) {
          this.isPermission = isCommit.success
        } else {
          atManager.requestPermissionOnSetting(context, ['ohos.permission.CAMERA']).then((data1) => {
            atManager.requestPermissionOnSetting(context, ['ohos.permission.MICROPHONE']).then((data2) => {
              if (!data1[0] && !data2[0]) {
                this.isPermission = isCommit.success
              } else {
                this.isPermission = isCommit.fail
              }
            }).catch(() => {
              if (!data1[0]) {
                this.isPermission = isCommit.success
              } else {
                this.isPermission = isCommit.fail
              }
            })
          }).catch(() => {
            atManager.requestPermissionOnSetting(context, ['ohos.permission.MICROPHONE']).then((data2) => {
              if (!data2[0]) {
                this.isPermission = isCommit.success
              } else {
                this.isPermission = isCommit.fail
              }
            })
          })
        }
      }
    }).catch((e: Error) => {
      console.info(TAG, `reqPermissionsFromUser failed: ${e.message}`);
      this.isPermission = isCommit.fail;
    })
  }
}

@Builder
export function MainPageBuilder() {
  MainPage()
}