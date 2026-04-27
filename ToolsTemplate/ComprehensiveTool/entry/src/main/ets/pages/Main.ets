import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Home, ShortCutParam } from 'home';
import { Mine } from 'mine';
import { PushActionParams, TabBarType } from '../model/Index';
import { RouterUtils } from '../utils/RouterUtils';
import { CommentUtil } from '../utils/CommentUtil';

@Builder
export function MainBuilder() {
  Main();
}

@ComponentV2
export struct Main {
  @Local pushActionParams: PushActionParams = AppStorageV2.connect(PushActionParams, () => new PushActionParams())!;
  @Local homeTabIndex: number = 0;

  requestForNotificationPermission() {
    notificationManager.requestEnableNotification(this.getUIContext().getHostContext() as common.UIAbilityContext)
      .then(() => {
        UtilLog.info(`requestEnableNotification success`);
      })
      .catch((err: BusinessError) => {
        UtilLog.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      });
  }

  aboutToAppear(): void {
    this.requestForNotificationPermission();
    if (this.pushActionParams.name?.length) {
      RouterUtils.pushPathByName(this.pushActionParams.name, null);
    }
    let shortCutKey: ShortCutParam = AppStorageV2.connect(ShortCutParam, () => new ShortCutParam())!;
    // 桌面快捷方式重定向
    if (shortCutKey.key) {
      RouterUtils.pushPathByName(shortCutKey.key, null);
    }
  }

  @Builder
  mainTabBar(title: ResourceStr, targetIndex: number, selectedImg: ResourceStr, normalImg: ResourceStr) {
    Column({ space: 4 }) {
      Image(this.homeTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 });
      Text(title)
        .fontSize(10)
        .fontColor(this.homeTabIndex === targetIndex ? $r('sys.color.font_emphasize') :
          $r('sys.color.font_secondary'))
        .opacity(this.homeTabIndex === targetIndex ? 1 : 0.6);
    }
    .onClick(() => {
      this.homeTabIndex = targetIndex;
    })
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(241, 243, 245, 0.8)');
  }

  build() {
    NavDestination() {
      Tabs({ index: this.homeTabIndex }) {
        TabContent() {
          Home({ pathStack: RouterUtils.getStack() });
        }
        .tabBar(this.mainTabBar('首页', TabBarType.HOME, $r('app.media.home_active'), $r('app.media.home_inactive')));

        TabContent() {
          Mine({ pathStack: RouterUtils.getStack() });
        }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .tabBar(this.mainTabBar('我的', TabBarType.MINE, $r('app.media.mine_active'), $r('app.media.mine_inactive')));
      }
      .clip(true)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .animationDuration(0)
      .barPosition(BarPosition.End)
      .barBackgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onChange((value: number) => {
        this.homeTabIndex = value;
      });
    }.hideTitleBar(true)
    .onShown(() => {
      // 延迟执行顺序在onForeground生命周期后
      let timer = setTimeout(() => {
        CommentUtil.toComment(this.getUIContext().getHostContext() as common.UIAbilityContext);
        clearTimeout(timer);
      }, 0);
    });
  }
}