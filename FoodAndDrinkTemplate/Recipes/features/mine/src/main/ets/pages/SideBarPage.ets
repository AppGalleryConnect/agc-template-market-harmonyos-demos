import { AccountUtil, BaseHeader, GlobalContextUtils, RouterMap, RouterModule } from 'commonlib';
import { promptAction } from '@kit.ArkUI';

@Builder
export function SideBarPageBuilder() {
  SideBarPage()
}

@ComponentV2
struct SideBarPage {
  build() {
    NavDestination() {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .onClick(() => {
            RouterModule.pop()
          })
        Column() {
          BaseHeader({ title: '服务', showLeftMenu: true, showBgColor: true })
          Divider().strokeWidth('1px')
          Column() {
            Row() {
              Row({ space: 15 }) {
                Image($r('app.media.icon_record')).width(24).height(24);
                Text('浏览记录')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'));
              };

              Image($r('app.media.ic_right')).width(12).height(24);
            }.width('100%').padding(12).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
              this.jumpUrl(RouterMap.BROWSING_HISTORY)
            })

            Divider()
              .strokeWidth('1px')
              .margin({
                left: 52,
                right: 12,
                top: 12,
                bottom: 12
              })
            Row() {
              Row({ space: 15 }) {
                Image($r('app.media.icon_setting')).width(24).height(24);
                Text('设置')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'));
              };

              Image($r('app.media.ic_right')).width(12).height(24);
            }.width('100%').padding(12).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
              this.jumpUrl(RouterMap.SETTINGS_PAGE)
            })
          }
          .margin({ top: 16, left: 12, right: 12 })
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(20)
        }
        .width(290)
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .backgroundBlurStyle(BlurStyle.Thin)
        .alignItems(HorizontalAlign.Start)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }.alignContent(Alignment.Start)
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .systemTransition(NavigationSystemTransitionType.FADE)
  }

  jumpUrl(url: string) {
    if (AccountUtil.getUserInfo().isLogin) {
      RouterModule.replace(url);
    } else {
      GlobalContextUtils.showToast({ message: '未登录，请登录后重试！' });
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }
}