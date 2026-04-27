import { AppStorageV2 } from '@kit.ArkUI';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { CreateGroupModel } from '../viewmodel/CreateGroupModel';
import { BarVM, BreakpointModel, CommonHeader, RouterMap, TempBarHeight, TValueType } from 'common';
import { GroupSingleRow } from '../components/GroupSingleRow';
import { CMChatGroupInfo } from 'instant_messaging';
import { ContactSingleRow } from '../components/ContactSingleRow';
import { StartGroupChatRow } from '../components/StartGroupChatRow';
import { CreateGroupFromOldGroupPageBuilder } from './CreateGroupFromOldGroupPage';
import { MessageContactModel } from '../viewmodel/MessageContactModel';
import { MessageGroupInfoModel } from '../viewmodel/MessageGroupInfoModel';

@Builder
export function CreateGroupPageBuilder() {
  CreateGroupPage()
}

/**
 * @usage: 创建群聊组件，支持从群聊里选择和从联系人里选择好友进行创建群聊
 * @layout: 页面采用纵向布局，从上到下依次为：顶部标题栏（CommonHeader）、可滚动的主内容区
 * （包含"从群聊里选择"和"从联系人里选择"两个左对齐的列表组）、底部发起群聊按钮（StartGroupChatRow）
 * @constraints: 创建群聊页面使用@ComponentV2，所有状态变量使用@Local装饰器管理（无 @Param 参数），
 * groupList和contactList数据只能通过CreateGroupModel的方法操作，不允许直接修改列表数据、回调函数签名和pageConfig配置
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 创建群聊组件
 * @subPage: CreateGroupFromOldGroupPage
 * @component: CommonHeader,GroupSingleRow,StartGroupChatRow
 * @image: screenshot/create_group_page.png
 */

@ComponentV2
export struct CreateGroupPage {
  @Local createGroupVM: CreateGroupModel = new CreateGroupModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onGroupClick: (groupInfoVM: CMChatGroupInfo) => void =
    (groupInfoVM: CMChatGroupInfo) => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CREATE_GROUP_FROM_OLD_GROUP_PAGE,
        builder: wrapBuilder(CreateGroupFromOldGroupPageBuilder),
        param: groupInfoVM as TValueType
      })
    }
  @Local onFriendClick: (friendInfoVM: MessageContactModel) => void =
    (friendInfoVM: MessageContactModel) => {
      this.createGroupVM.selectContactCreateGroup(friendInfoVM);
    }
  @Local onStartGroupChatClick: () => void = () => {
    this.createGroupVM.startGroupChat();
  }

  @Builder
  setHeaderBuilder(title: ResourceStr) {
    Text(title)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('app.color.color_99000000'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Start)
      .width('100%')
      .height($r('app.float.vp_42'))
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
  }

  @Builder
  render() {
    CommonHeader({
      title: this.createGroupVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List({ scroller: this.createGroupVM.scroller }) {
        ListItemGroup({
          header: this.setHeaderBuilder('从群聊里选择')
        }) {
          Repeat<MessageGroupInfoModel>(this.createGroupVM.groupList)
            .each((ri: RepeatItem<MessageGroupInfoModel>) => {
              ListItem() {
                GroupSingleRow({
                  groupInfoVM: ri.item,
                  onGroupClick: this.onGroupClick
                });
              }
            })
            .key((item: MessageGroupInfoModel, index: number): string => item.groupId.toString() + index)
            .virtualScroll({
              totalCount: this.createGroupVM.groupList.length
            })
            .templateId((_groupInfoVM: MessageGroupInfoModel): string => {
              return '';
            })
        }
        .divider({
          strokeWidth: '1px',
          color: $r('sys.color.comp_divider')
        })

        ListItemGroup({
          header: this.setHeaderBuilder('从联系人里选择')
        }) {
          Repeat<MessageContactModel>(this.createGroupVM.contactList)
            .each((ri: RepeatItem<MessageContactModel>) => {
              ListItem() {
                ContactSingleRow({
                  friendInfoVM: ri.item,
                  onFriendClick: this.onFriendClick
                });
              }
            })
            .key((item: MessageContactModel, index: number): string => item.userId.toString() + index)
            .virtualScroll({
              totalCount: this.createGroupVM.contactList.length
            })
            .templateId((_friendInfoVM: MessageContactModel): string => {
              return '';
            })
        }
        .divider({
          strokeWidth: '1px',
          color: $r('sys.color.comp_divider')
        })
        ListItem().height(this.createGroupVM.isShowBottom ? $r('app.float.vp_12') : BarVM.instance.aiBarH)
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')

    StartGroupChatRow({
      onStartGroupChatClick: this.onStartGroupChatClick
    })
      .visibility(this.createGroupVM.isShowBottom ? Visibility.Visible : Visibility.None)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}

