import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, Constants, RouterMap, TCLogger, TValueType } from 'common';
import { MessageNavigationBar } from '../components/MessageNavigationBar';
import { MessageListModel } from '../viewmodel/MessageListModel';
import { MessageSingleRow } from '../components/MessageSingleRow';
import { MessageSwipeRow } from '../components/MessageSwipeRow';
import { phoneRouterControl } from 'oh_router';
import { MessageChatPageBuilder } from './MessageChatPage';
import { CMChatConversation } from 'instant_messaging';
import { CreateGroupPageBuilder } from './CreateGroupPage';
import { AddFriendPageBuilder } from './AddFriendPage';
import { ChatHistorySearchPageBuilder } from './ChatHistorySearchPage';

@Builder
export function MessageListPageBuilder() {
  MessageListPage()
}

const TAG = 'MessageListPage';

/**
 * @usage: 消息会话列表，支持搜索、创建群聊、添加朋友
 * @layout: 页面整体采用垂直布局（Column），顶部是MessageNavigationBar导航栏，下方是List列表布局；
 * @constraints: 消息列表页面使用 @ComponentV2和@Local状态管理，所有数据操作必须通过ViewModel进行，
 * 不允许直接修改conversationList会话数据
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 消息列表页
 * @subPage:
 * @component: MessageSwipeRow,MessageNavigationBar,MessageSingleRow
 * @image: screenshot/message_page.png
 */

@ComponentV2
export struct MessageListPage {
  @Local messageListVM: MessageListModel = new MessageListModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local menuList: MenuElement[] = [
    {
      value: '创建群聊',
      action: () => {
        TCLogger.info(TAG, `on create a group chat click`)
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CREATE_GROUP_PAGE,
          builder: wrapBuilder(CreateGroupPageBuilder)
        })
      }
    },
    {
      value: '添加朋友',
      action: () => {
        TCLogger.info(TAG, `on add friend click`);
        phoneRouterControl.jumpPage({
          pageName: RouterMap.ADD_FRIEND_PAGE,
          builder: wrapBuilder(AddFriendPageBuilder)
        })
      }
    }
  ];
  @Local onSearchClick: () => void = () => {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.CHAT_HISTORY_SEARCH_PAGE,
      builder: wrapBuilder(ChatHistorySearchPageBuilder),
      param: { 'userId': undefined, 'groupId': undefined } as Record<string, string | undefined>,
    })
  }
  @Local onChatClick: (messageVM: CMChatConversation) => void = (messageVM: CMChatConversation) => {
    TCLogger.info(TAG, `on chat click ` + JSON.stringify(messageVM));
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CHAT_PAGE,
      builder: wrapBuilder(MessageChatPageBuilder),
      param: messageVM as TValueType
    })
  }
  @Local onMessagePageShowChange: () => void = () => {
    this.messageListVM.getConversationListByFilter(true)
  }

  aboutToAppear(): void {
    this.getUIContext().getHostContext()?.eventHub.on(Constants.onMessagePageShowChange,
      this.onMessagePageShowChange);
    this.messageListVM.addConversationListener();
    this.messageListVM.getConversationListByFilter(true);
  }

  @Builder
  setSwipeBuilder(ri: RepeatItem<CMChatConversation>) {
    MessageSwipeRow({
      messageVM: ri.item,
      onDeleteClick: () => {
        this.messageListVM.deleteConversation(ri);
      },
      onTopClick: () => {
        this.messageListVM.pinConversation(ri);
      }
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row().width('100%').height(104 + BarVM.instance.staBarH)
        .linearGradient({
          angle: 0,
          colors: [['#00b8d1fe', 0.0], ['#ffcfd2ff', 1.0]]
        })
        .hitTestBehavior(HitTestMode.None)

      Column() {
        MessageNavigationBar({
          menuList: this.menuList,
          onSearchClick: this.onSearchClick
        });

        Column() {
          List({ scroller: this.messageListVM.scroller }) {
            Repeat<CMChatConversation>(this.messageListVM.conversationList)
              .each((ri: RepeatItem<CMChatConversation>) => {
                ListItem() {
                  MessageSingleRow({
                    messageVM: ri.item,
                    onChatClick: this.onChatClick
                  });
                }.swipeAction({
                  end: {
                    builder: () => {
                      this.setSwipeBuilder(ri);
                    }
                  }
                })
              })
              .key((item: CMChatConversation): string => item.conversationID)
              .virtualScroll({
                totalCount: this.messageListVM.conversationList.length
              })
              .templateId((_chatVM: CMChatConversation): string => {
                return '';
              })
          }
          .height('100%')
          .width('100%')
          .divider({
            strokeWidth: '1px',
            color: $r('sys.color.comp_divider'),
            startMargin: this.breakPointModel.pagePadding,
            endMargin: this.breakPointModel.pagePadding,
          })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Color.White)
    .height('100%')
    .width('100%')
  }
}
