import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, MessageJumpManager, TValueType } from 'common';
import { MyGroupListPageViewModel } from '../viewmodel/MyGroupListPageViewModel';
import { ChatBreakpoint } from 'chat_base';
import { OHPage, phoneRouterControl } from 'oh_router';
import { MyGroupRow } from './MyGroupRow';
import { CMChatGroupInfo } from 'instant_messaging';

@Builder
export function MyGroupListPageBuilder(value: TValueType) {
  MyGroupListPage({groupRelationShip: value as number})
}

/**
 * @usage: 我的群列表页面，按关系类型（创建/管理/加入）展示群列表，支持点击进入群聊页面。
 * @layout: Top/Content：
 *  - 顶部（Top）：自定义导航栏 Row，左侧返回按钮，右侧为标题 `myGroupVM.navTitle`，居中对齐。
 *  - 内容（Content）：List 纵向列表，Repeat 渲染 `CMChatGroupInfo`，每行由 MyGroupRow 构成，点击跳转群聊。
 *  页面宽高 100%，顶层为 OHPage 包裹，背景色灰白，顶部预留状态栏高度。
 * @constraints: 导航栏和列表样式固定不可修改，页面通过 groupRelationShip 参数（必需且不可变）来展示对应关系类型的群列表，
 * 点击群组行跳转到群聊页面
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 我的群列表页面
 * @subPage: MessageChatPage
 * @component:
 * @image: screenshot/contact/contact_add_group.png
 */

// 我的群列表（创建、管理、加入）
@ComponentV2
struct MyGroupListPage {
  @Param @Require groupRelationShip: number
  myGroupVM: MyGroupListPageViewModel = new MyGroupListPageViewModel()
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.myGroupVM.initialWithRelationShip(this.groupRelationShip)
  }

  @Builder
  navbarBuilder() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize($r('app.float.vp_24'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .type(ButtonType.Circle)
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .margin({ left: this.chatBreakpoint.pagePadding })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length)
      })

      Text(this.myGroupVM.navTitle)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .layoutWeight(1)
        .height($r('app.float.vp_40'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({
          left: this.chatBreakpoint.pagePadding / 2,
          right: this.chatBreakpoint.pagePadding
        })
    }
    .height(40)
    .width('100%')
    .margin({bottom: $r('app.float.vp_12')})
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  render() {
    Column() {
      this.navbarBuilder()

      if (this.myGroupVM.contentIsEmpty) {
        this.contentEmpty()
      } else {
        this.contentList()
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.color_F1F3F5'))
    .justifyContent(FlexAlign.Start)
    .padding({top: BarVM.instance.staBarH})
  }

  @Builder
  contentList() {
    List() {
      Repeat<CMChatGroupInfo>(this.myGroupVM.groupList)
        .each((ri: RepeatItem<CMChatGroupInfo>) => {
          ListItem() {
            MyGroupRow({ groupInfo: ri.item })
              .onClick(() => {
                MessageJumpManager.gotoGroupChatPage(ri.item.groupId, false)
              })
          }
        })
        .key((item: CMChatGroupInfo): string => item.groupId)
        .virtualScroll({
          totalCount: this.myGroupVM.groupList.length
        })
        .templateId((_chatVM: CMChatGroupInfo): string => {
          return '';
        })
    }
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: this.breakPointModel.pagePadding,
      endMargin: this.breakPointModel.pagePadding,
    })
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  contentEmpty() {
    Column() {
      Image($r('app.media.addressbook_empty'))
        .size({width: $r('app.float.vp_120'), height: $r('app.float.vp_120')})
        .objectFit(ImageFit.Contain)

      Text($r('app.string.address_book_empty_text'))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight($r('app.float.vp_14'))
        .margin({ top: $r('app.float.vp_18') })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .layoutWeight(1)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
    })
  }
}
