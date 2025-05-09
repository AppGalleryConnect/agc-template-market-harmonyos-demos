import { CommonConstants, EmitterConstants, FullLoading, RouterModule } from 'commonlib';
import { TAB_LIST } from '../constants';
import { TabListItem } from 'commonlib/src/main/ets/types/index';
import { emitter } from '@kit.BasicServicesKit';

@Entry
@ComponentV2
struct MainEntry {
  @Local curIndex: number = 0
  private controller: TabsController = new TabsController()

  async aboutToAppear() {
    // 网络请求模块依赖全局弹窗初始化
    FullLoading.init(this.getUIContext())
    emitter.on(EmitterConstants.TO_HOME, () => {
      this.controller.changeIndex(0)
    })
  }

  build() {
    Navigation(RouterModule.stack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: $$this.curIndex, controller: this.controller }) {
          ForEach(TAB_LIST, (item: TabListItem, index: number) => {
            TabContent() {
              item.component.builder()
            }
            .tabBar(this.TabBarBuilder(item, index))
            .clip(this.curIndex === 0)
          },(item: TabListItem, index: number) => JSON.stringify(item)+'_'+index)
        }
        .scrollable(false)
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .height(CommonConstants.FULL_HEIGHT)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)

  }

  @Builder
  TabBarBuilder(item: TabListItem, index: number) {
    Column({ space: 4 }) {
      Image(this.curIndex === index ? item.iconChecked : item.icon)
        .width(28)
        .height(28)
      Text(item.label)
        .fontColor(this.curIndex === index ? $r('app.color.icon_color_active') : $r('app.color.icon_color_frozen'))
        .fontSize($r('app.string.font_size_12'))
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .justifyContent(FlexAlign.End)
  }
}