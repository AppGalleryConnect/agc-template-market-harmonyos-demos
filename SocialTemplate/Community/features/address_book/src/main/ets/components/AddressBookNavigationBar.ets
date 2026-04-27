import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel, TempBarHeight } from 'common';

/**
 * @usage: 导航栏组件，支持展示标题。
 * @layout: 页面采用 Column 布局，Text组件，水平方向左对齐
 * @constraints:
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 导航栏组件
 * @subPage:
 * @component:
 * @image: screenshot/contact_page.png
 */

@ComponentV2
export struct AddressBookNavigationBar {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Text($r('app.string.addressbook_main_title'))
        .fontSize(26)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .lineHeight($r('app.float.vp_30'))
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({top: this.tempBarHeight.topTempValue, left: this.breakPointModel.pagePadding})
    .height(56 + this.tempBarHeight.topTempValue)
  }
}