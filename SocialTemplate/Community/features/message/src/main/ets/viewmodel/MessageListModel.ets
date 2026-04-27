import { BusinessError } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { GlobalContext, MessageReminderUtil, OHDialog, TCLogger, UserInfo } from 'common';
import {
  CMChatConversation,
  CMChatConversationOperationResult,
  CMChatConversationResult,
  CMChatConversationType,
  CMChatFactory
} from 'instant_messaging';
import { DeleteMsgModel, dialogDeleteMsgBuilder } from '../components/DeleteMsgDialog';
import { MessageUtil } from '../utils/MessageUtil';
import { chatParseMessageModel } from './MessageChatModel';
import { SearchDataMock, ConversationCacheModel } from 'chat_history_search';

const TAG = 'MessageListModel';

@ObservedV2
export class MessageListModel extends CMChatConversationResult {
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace topCount: number = 0;
  scroller: ListScroller = new ListScroller();
  reminderTimerId: number = 0;
  reminderClickCount: number = 0;

  /**
   * 获取会话列表
   */
  async getConversationListByFilter(isFresh?: boolean) {
    let result = await CMChatFactory.instance.getConversationListByFilter(0);
    this.nextSeq = result.nextSeq;
    this.isFinished = result.isFinished;
    for (let index = 0; index < result.conversationList.length; index++) {
      const element = result.conversationList[index];
      if (element.type === CMChatConversationType.CHAT_GROUP) {
        try {
          element.memberInfoList = await this.getGroupMemberList(element);
          element.memberAvatarList = MessageUtil.parseGroupAvatar(element.memberInfoList);
        } catch (err) {
          element.memberInfoList = [];
          element.memberAvatarList = [];
        }
      }
    }
    this.conversationList = result.conversationList;
    this.scroller.closeAllSwipeActions();

    if (isFresh !== undefined && isFresh) {
      this.getAllMessage();
    }
  }

  /**
   * 获取全部会话和消息数据，用于mock搜索的数据源
   */
  async getAllMessage() {
    let list: ConversationCacheModel[] = [];
    for (let index_ = 0; index_ < this.conversationList.length; index_++) {
      let conversation: CMChatConversation = this.conversationList[index_];
      let conversationCacheModel = new ConversationCacheModel();
      conversationCacheModel.userId = conversation.userId;
      conversationCacheModel.groupID = conversation.groupID;
      conversationCacheModel.conversationID = conversation.conversationID;
      let result =
        await CMChatFactory.instance.getHistoryMessageList(conversation.userId, conversation.groupID);
      for (let index = 0; index < result.length; index++) {
        const element = result[index];
        let chatVM = chatParseMessageModel(element, conversation.type, this.userInfo);
        conversationCacheModel.allCachedMsgList.push(chatVM);
      }
      list.push(conversationCacheModel);
    }
    SearchDataMock.allMessageList = list;

    this.getAllContact().then();
  }

  /**
   * 获取全部联系人数据，用于mock搜索联系人的数据源
   */
  async getAllContact() {
    SearchDataMock.allContactList = []
    let result = await CMChatFactory.instance.getFriendList();
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      SearchDataMock.addContact(element.userId, element.nickName, element.avatarUrl);
    }
  }

  /**
   * 添加会话监听器
   */
  addConversationListener() {
    CMChatFactory.instance.addConversationListener({
      onNewConversation: (conversations: CMChatConversation[]) => {
        this.messageReminder(conversations);
      },
      onConversationChanged: (conversations: CMChatConversation[]) => {
        this.messageReminder(conversations);
      }
    })
  }

  messageReminder(conversations: CMChatConversation[]) {
    let timestamp = conversations[0]?.lastMessage?.timestamp;
    let currentTime = new Date().getTime() / 1000;
    if (currentTime - timestamp > 50) {
      return;
    }
    clearTimeout(this.reminderTimerId);
    this.reminderClickCount++;
    if (this.reminderClickCount >= 2) {
      this.reminderClickCount = 0;
      return;
    } else {
      this.reminderTimerId = setTimeout(() => {
        this.reminderClickCount = 0;
      }, 300);
    }

    const element = conversations[0];
    let reminder = new MessageReminderUtil();
    reminder.messageReminderMethod(element?.userId, element?.type, element.lastMessage.sender,
      element.lastMessage.msgID);
    this.getConversationListByFilter();
  }

  /**
   * 会话置顶
   */
  pinConversation(ri: RepeatItem<CMChatConversation>) {
    CMChatFactory.instance.pinConversation(ri.item.conversationID, !ri.item.isPinned).then(() => {
      TCLogger.info(TAG, `pin conversation success ` + !ri.item.isPinned);
      this.scroller.closeAllSwipeActions();
      this.getConversationListByFilter();
    }).catch((err: BusinessError) => {
      TCLogger.error(TAG, `pin conversation err ` + JSON.stringify(err));
    });
  }

  /**
   * 删除会话
   */
  deleteConversation(ri: RepeatItem<CMChatConversation>) {
    let dialogVM = new DeleteMsgModel();
    dialogVM.onValueConfirmClick = (model: Object) => {
      let msgModel: DeleteMsgModel | undefined;
      try {
        msgModel = model as DeleteMsgModel;
      } catch (err) {
      }
      CMChatFactory.instance.deleteConversationList([ri.item.conversationID], msgModel?.isDelete ?? false)
        .then((result: CMChatConversationOperationResult[]) => {
          if (result[0].resultCode === 0) {
            this.getConversationListByFilter();
          } else {
            TCLogger.error(TAG, `delete conversation fail ` + JSON.stringify(result));
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除失败' })
          }
        }).catch((err: BusinessError) => {
        TCLogger.error(TAG, `delete conversation err ` + JSON.stringify(err));
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除失败' })
      });

    };
    dialogVM.childBuilder = dialogDeleteMsgBuilder;
    OHDialog.showPopup(dialogVM);
  }

  /**
   * 获取群成员列表
   */
  async getGroupMemberList(conversation: CMChatConversation) {
    let result = await CMChatFactory.instance.getGroupMemberList(conversation.groupID, 0, 0);
    return result.memberInfoList;
  }
}