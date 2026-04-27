import { MineVM } from '../viewmodel/MineVM';

@Builder
export function SettingPageBuilder() {
  SettingPage();
}

@ComponentV2
export struct SettingPage {
  vm: MineVM = MineVM.instance;

  build() {
    NavDestination() {
      Column() {

        Column({ space: 12 }) {
          Row() {
            Text('个人信息').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
            Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(20)
          .padding(12)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onClick(() => {
            this.vm.pathStack.pushPathByName('ProfilePage', null);
          });

          Row() {
            Text('关于').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
            Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(20)
          .padding(12)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onClick(() => {
            this.vm.pathStack.pushPathByName('AboutPage', null);
          });
        };


        Button('退出登录')
          .width('100%')
          .padding({ top: 10, bottom: 10 })
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.vm.signOut();
          });
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }.backgroundColor($r('sys.color.background_secondary')).title('设置').onReady((ctx) => {
      this.vm.pathStack = ctx.pathStack;
    });
  }
}