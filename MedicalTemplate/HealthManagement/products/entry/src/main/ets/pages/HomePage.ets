import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TCLogger, BarVM } from 'common';
import { HomeModel } from '../viewmodel/HomeModel';
import { TabSingleItem } from '../viewmodel/TabSingleItem';

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
        .margin({ top: $r('app.float.vp_4') })
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.curIndex === tabItem.index ? tabItem.fontColorActive : tabItem.fontColor)
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.vp_52'))
    .width('100%')
  }

  aboutToAppear(): void {
    this.vm.addDeviceDialog();
    this.vm.addHealthRemind();
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
    .padding({
      bottom: BarVM.instance.aiBarH
    })
    .animationDuration(0)
    .scrollable(false)
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