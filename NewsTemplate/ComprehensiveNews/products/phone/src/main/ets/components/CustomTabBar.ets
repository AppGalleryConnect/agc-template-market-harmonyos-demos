import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { CommonConstants, TabModel, TabBarType, EventEnum } from 'lib_common';
import { SearchControllerMng } from 'lib_search';
import { TabBarItem } from '../common/Constants';

@ComponentV2
export struct CustomTabBar {
  @Require @Param item: TabBarItem;
  @Param fontSizeRatio: number = 1;
  @Consumer() selectedIndex: number = TabBarType.HOME;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;

  build() {
    Column() {
      Image(this.item.activeIcon)
        .width($r('app.float.normal_img_size'))
        .draggable(false)
        .fillColor(this.getTabColor(this.item.id))
        .objectFit(ImageFit.Contain)
      Text(this.item.title)
        .fontSize(10 * this.fontSizeRatio)
        .fontColor(this.getTabColor(this.item.id))
        .margin({
          top: CommonConstants.PADDING_XS,
        })
    }
    .width(this.tabItemWidth)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        // 双击
        TapGesture({ count: 2 }).onAction(() => {
          // 如果当前选中的不是这个tab，先切换tab
          if (this.selectedIndex !== this.item.id) {
            this.changeTab();
            // 如果双击的是首页，切换后还要置顶刷新
            if (this.item.id === TabBarType.HOME) {
              setTimeout(() => {
                emitter.emit(EventEnum.TAB_HOME_DOUBLE_CLICK);
              }, 100);
            }
            return;
          }
          if (this.item.id === TabBarType.HOME) {
            emitter.emit(EventEnum.TAB_HOME_DOUBLE_CLICK);
          }
        }),
        // 单击
        TapGesture({ count: 1 }).onAction(() => {
          // 如果当前选中的是首页，单击首页则置顶刷新
          if (this.selectedIndex === TabBarType.HOME && this.item.id === TabBarType.HOME) {
            emitter.emit(EventEnum.TAB_HOME_DOUBLE_CLICK);
          }
          this.changeTab();
        }),
      ),
    )
  }

  changeTab() {
    this.selectedIndex = this.item.id;
    setTimeout(() => {
      SearchControllerMng.closeAllPop();
    }, 100);
  }

  getTabColor(id: number): ResourceColor {
    if (this.selectedIndex === id) {
      return $r('app.color.app_theme')
    }
    return $r('sys.color.font_primary')
  }

  @Computed
  get tabItemWidth(): Length {
    return CommonConstants.FULL_PERCENT;
  }
}