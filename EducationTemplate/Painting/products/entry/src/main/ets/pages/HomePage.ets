import { HomeModel } from '../viewmodels/HomeModel';
import { TabSingleItem } from '../viewmodels/TabSingleItem';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@Builder
export function HomePageBuilder() {
  HomePage()
}

const TAG = 'HomePage';


@ComponentV2
export struct HomePage {
  vm: HomeModel = HomeModel.instance;

  @Builder
  tabBuilder(tabItem: TabSingleItem) {
    Column() {
      Image(this.vm.curIndex === tabItem.index ? tabItem.iconActive : tabItem.icon)
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .objectFit(ImageFit.Contain)
      Text(tabItem.label)
        .margin({ top: $r('app.float.vp_6') })
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.curIndex === tabItem.index ? tabItem.fontColorActive : tabItem.fontColor)
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.vp_52'))
    .width('100%')
  }


  aboutToAppear(): void {
  }

  // 页面内容渲染
  @Builder
  render() {
    Tabs({
      barPosition: BarPosition.End,
      index: $$this.vm.curIndex,
      controller: this.vm.controller
    }) {
      ForEach(this.vm.tabList, (item: TabSingleItem) => {
        TabContent() {
          item.component.builder('');
        }
        .tabBar(this.tabBuilder(item))
      }, (item: TabSingleItem, index) => JSON.stringify(item) + '_' + index)
    }
    .clip(true)
    .width('100%')
    .backgroundColor($r('app.color.background_color_page'))
    .barHeight($r('app.float.vp_50'))
    .barMode(BarMode.Fixed)
    .animationDuration(0)
    .scrollable(false)
  }

  build() {
    NavDestination() {
      NavDestination() {
        this.render();
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .hideTitleBar(true)
      .onBackPressed(() => {
        let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        context.terminateSelf((err: BusinessError) => {
        });
        return true
      })
    }
  }
}
