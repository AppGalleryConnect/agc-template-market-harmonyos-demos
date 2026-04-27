import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { Constants, TempBarHeight } from 'common';
import { HomeModel } from '../viewmodels/HomeModel';
import { TabSingleItem } from '../viewmodels/TabSingleItem';
import { TCLogger } from 'common';

@Builder
export function HomePageBuilder() {
  HomePage()
}

const TAG = 'HomePage';

/**
 * @usage: tab 页面控制类，包括消息、通讯录、我的
 * @layout:
 * @constraints: tab 页面控制类 tab页面控制类包括消息（message）、通讯录（address_book）和我的（person）。
 * 根据用户实际需求仅修改代码中,tabBuilder调用的变量，当前仅支持删除变量中的元素，以及修改index从0开始
 * 并保证index顺序，其他元素不允许修改。根据用户需求删除多余的import依赖，仅从message、address_book和person
 * 依赖中删除，Constants依赖需保留。
 * @isGen: ture
 * @fileType: tab
 */

@ComponentV2
export struct HomePage {
  vm: HomeModel = HomeModel.instance;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;

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
          item.component?.builder('');
        }
        .tabBar(this.tabBuilder(item))
      }, (item: TabSingleItem, index) => JSON.stringify(item) + '_' + index)
    }
    .clip(true)
    .width('100%')
    .backgroundColor('#F3F4F5')
    .barHeight($r('app.float.vp_48'))
    .barMode(BarMode.Fixed)
    .animationDuration(0)
    .scrollable(false)
    .onChange((index: number) => {
      TCLogger.info(TAG, `on tab change click ` + index);
      if (index === 0) {
        this.getUIContext().getHostContext()?.eventHub.emit(Constants.onMessagePageShowChange);
      }
    })
  }

  build() {
    NavDestination() {
      this.render();
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onShown(() => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = this.tempBarHeight.bottomTempValue;
      TCLogger.info(TAG, `on navigation show click ` + this.vm.curIndex);
      if (this.vm.curIndex === 0) {
        this.getUIContext().getHostContext()?.eventHub.emit(Constants.onMessagePageShowChange);
      }
    })
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
