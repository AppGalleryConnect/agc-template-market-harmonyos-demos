import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, TabModel } from 'lib_common';
import { PhoneConstants, TabBarItem, TabBarType } from '../common/Constants';

@ComponentV2
export struct CustomTabBar {
  @Require @Param item: TabBarItem;
  @Param fontSizeRatio: number = 1;
  @Consumer() selectedIndex: number = TabBarType.HOME;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;

  build() {
    Column({ space: CommonConstants.SPACE_XS }) {
      Text(){
        SymbolSpan(this.selectedIndex === this.item.id ? this.item.activeIcon : this.item.defaultIcon)
      }
      .fontSize($r('app.float.normal_img_size'))
      .fontColor(this.getTabColor(this.item.id))

      Text(this.item.title)
        .fontSize(10 * this.fontSizeRatio)
        .fontColor(this.getTabColor(this.item.id))
    }
    .width(this.tabItemWidth)
    .height(this.tabItemHeight)
    .justifyContent(FlexAlign.Center)
    .padding({ top: CommonConstants.PADDING_XS, bottom: CommonConstants.PADDING_XS })
    .onClick(() => {
      this.selectedIndex = this.item.id;
    })
  }

  getTabColor(id: number): ResourceColor {
    if (this.selectedIndex === id) {
      return $r('app.color.app_theme')
    }
    return $r('sys.color.font_tertiary')
  }

  @Computed
  get tabItemWidth(): Length {
    if (this.tabModel.isTabVertical) {
      return CommonConstants.FULL_PERCENT;
    }
    return CommonConstants.QUARTER_PERCENT;
  }

  @Computed
  get tabItemHeight(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }
}