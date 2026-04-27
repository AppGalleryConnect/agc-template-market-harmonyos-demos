import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, MessageJumpManager, RouterMap } from 'common';
import { CMChatFriendInfo } from 'instant_messaging';
import { AddressBookPageViewModel, ContactToppingItem, FriendGroup } from '../viewmodel/AddressBookPageViewModel';
import { AddressBookNavigationBar } from '../components/AddressBookNavigationBar';
import { FriendInfoRow } from '../components/FriendInfoRow';
import { phoneRouterControl } from 'oh_router';
import { MyGroupListPageBuilder } from './MyGroupListPage';

@Builder
export function AddressBookPageBuilder() {
  AddressBookPage()
}

/**
 * @usage: 通讯录主页面，支持查看我创建的群、我管理的群以及我加入的群，支持好友分组列表（按字母分组）、字母索引器快速跳转，查看好友详情。
 * @layout: 页面采用 RelativeContainer 布局，顶部是横向渐变背景 Row，下方是纵向 Column（包含导航栏 AddressBookNavigationBar
 * 和纵向滚动 List），List 内包含置顶功能项分组（3个固定项左对齐）和字母分组好友列表（分组标题左对齐、好友项左对齐），
 * 右侧叠加垂直居中右对齐的字母索引器 AlphabetIndexer
 * @constraints: 通讯录页面使用 @ComponentV2，addressbookVM 和 @Local 装饰的 breakPointModel 不允许外部修改，
 * toppingItems 置顶项配置（固定3项）不可修改，friendList 好友数据只能通过 ViewModel 的监听器方法操作，
 * 渐变背景高度（104 + staBarH）、分隔线样式和字母索引器位置不应随意调整
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 通讯录主页面
 * @subPage: MyGroupListPage,AvatarUrlView
 * @component: AddressBookNavigationBar,FriendInfoRow
 * @image: screenshot/contact_page.png
 */

@ComponentV2
struct AddressBookPage {
  addressbookVM: AddressBookPageViewModel = new AddressBookPageViewModel()
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    RelativeContainer() {
      Row()
        .height(104 + BarVM.instance.staBarH)
        .linearGradient({
          angle: 0,
          colors: [['#00b8d1fe', 0.0], ['#ffcfd2ff', 1.0]]
        })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })

      Column() {
        AddressBookNavigationBar()

        List({ scroller: this.addressbookVM.scroller }) {
          ListItemGroup() {
            Repeat<ContactToppingItem>(this.addressbookVM.toppingItems)
              .each((ri: RepeatItem<ContactToppingItem>) => {
                ListItem() {
                  FriendInfoRow({ imgSrc: ri.item.image, title: ri.item.title })
                    .onClick(() => {
                      phoneRouterControl.jumpPage({
                        pageName: RouterMap.MY_GROUP_LIST_PAGE,
                        builder: wrapBuilder(MyGroupListPageBuilder),
                        param: ri.index
                      })
                    })
                }
              })
              .key((item: ContactToppingItem, index: number): string => item.title + index)
              .virtualScroll({
                totalCount: 3
              })
              .templateId((_groupInfoVM: ContactToppingItem): string => {
                return '';
              })
          }
          .divider({ strokeWidth: '1px', color: $r('sys.color.comp_divider') })

          ForEach(this.addressbookVM.friendGroupList, (group: FriendGroup) => {
            ListItemGroup({
              header: this.headerBuilder(group.name)
            }) {
              Repeat<CMChatFriendInfo>(group.list)
                .each((ri: RepeatItem<CMChatFriendInfo>) => {
                  ListItem() {
                    FriendInfoRow({
                      imgSrc: $r('app.media.' + ri.item.avatarUrl),
                      title: (ri.item.friendRemark.length > 0) ? ri.item.friendRemark : ri.item.nickName
                    })
                      .onClick(() => {
                        MessageJumpManager.gotoContactInfo(ri.item.userId)
                      })
                  }
                })
                .key((item: CMChatFriendInfo, index: number): string => item.userId.toString() + index)
                .virtualScroll({
                  totalCount: group.list.length
                })
                .templateId((_groupInfoVM: CMChatFriendInfo): string => {
                  return '';
                })
            }
            .divider({ strokeWidth: '1px', color: $r('sys.color.comp_divider') })
          }, (group: FriendGroup, index: number) => group.name + '_' + index)

          ListItem().height(BarVM.instance.aiBarH)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .layoutWeight(1)
        .onScrollIndex((start: number) => {
          this.addressbookVM.handleScrollIndex(start - 1)
        })
      }
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        right: { anchor: '__container__', align: HorizontalAlign.End },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })

      this.alphaIndexBuilder()
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  headerBuilder(title: string) {
    Text(title)
      .textAlign(TextAlign.Start)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('app.color.color_99000000'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .height($r('app.float.vp_46'))
      .width('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
  }

  @Builder
  alphaIndexBuilder() {
    AlphabetIndexer({ arrayValue: this.addressbookVM.alphaIndexList, selected: this.addressbookVM.selectIndex })
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        right: { anchor: '__container__', align: HorizontalAlign.End },
      })
      .onSelect((tabIndex: number) => {
        this.addressbookVM.handleAlphaSelect(tabIndex + 1);
      })
  }
}
