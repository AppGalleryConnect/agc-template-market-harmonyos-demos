import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';

/**
 * @usage: 好友信息组件，支持图片与标题横向排列。
 * @layout: 页面采用 Row 布局，依次是Image和Text横向排列，整体左对齐
 * @constraints:
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 好友信息组件
 * @subPage:
 * @component:
 * @image: screenshot/contact_page.png
 */

// 好友信息row
@ComponentV2
export struct FriendInfoRow {
  @Param @Require imgSrc: ResourceStr;
  @Param @Require title: ResourceStr;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Row() {
      Image(this.imgSrc)
        .objectFit(ImageFit.Fill)
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .borderRadius($r('sys.float.corner_radius_level6'))

      Blank().width($r('app.float.vp_12'));

      Text(this.title)
        .textAlign(TextAlign.Start)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .height('100%')
        .layoutWeight(1)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_64'))
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
  }
}