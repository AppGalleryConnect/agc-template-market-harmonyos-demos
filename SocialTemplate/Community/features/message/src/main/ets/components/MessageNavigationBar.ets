import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel, TempBarHeight } from 'common';

/**
 * @usage: 消息导航栏，支持搜索、创建群聊、添加朋友
 * @layout: 页面整体采用水平排列（Row），左侧是Text组件，右侧是Image组件；两端对齐
 * @constraints: 消息导航栏组件使用@ComponentV2，@Param装饰的menuList和title参数不允许在组件内部修改，
 * @Event装饰的onSearchClick回调函数签名不可修改
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 消息导航栏
 * @subPage: ChatHistorySearchPage,CreateGroupPage,AddFriendPage
 * @component:
 * @image: screenshot/message_page.png
 */

@ComponentV2
export struct MessageNavigationBar {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Param title: string = ''
  @Param menuList: MenuElement[] = [];
  @Local isShowMenu: boolean = false;
  @Event onSearchClick: () => void = () => {
  }

  build() {
    Column() {
      Blank().height(this.tempBarHeight.topTempValue);
      Row() {
        Text($r('app.string.message_main_title'))
          .fontSize(26)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .lineHeight($r('app.float.vp_30'))

        Blank().layoutWeight(1)
        Image($r('app.media.message_search_icon'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            this.onSearchClick();
          })

        Blank().width($r('app.float.vp_8'))
        Image($r('app.media.message_more_icon'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            this.isShowMenu = !this.isShowMenu;
          })
          .bindMenu(this.isShowMenu, this.menuList,
            {
              placement: Placement.BottomRight,
              onDisappear: () => {
                this.isShowMenu = false;
              }
            })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
    }
    .width('100%')
    .height(56 + this.tempBarHeight.topTempValue)
  }
}