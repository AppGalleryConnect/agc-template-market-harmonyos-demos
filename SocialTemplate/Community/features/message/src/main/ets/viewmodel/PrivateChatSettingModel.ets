import { BusinessError } from '@kit.BasicServicesKit';
import { Constants, GlobalContext, OHDialog, RouterMap, TCLogger, TValueType } from 'common';
import { CMChatConversationOperationResult, CMChatFactory } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { DeleteMsgModel } from '../components/DeleteMsgDialog';
import { dialogMsgInputBuilder, MsgInputModel } from '../components/MsgInputDialog';
import { ChatBackgroundSkillUtil } from '../utils/ChatBackgroundSkillUtil';
import { PrivateChatSettingEnum, PrivateChatSettingSingleEnum } from '../utils/MessageEnum';
import { MessageUtil } from '../utils/MessageUtil';
import { AvatarUrlViewPageBuilder } from '../view/AvatarUrlView';
import { ChatHistorySearchPageBuilder } from '../view/ChatHistorySearchPage';
import { StartGroupPageBuilder } from '../view/StartGroupPage';
import { PrivateChatSettingSingleModel } from './PrivateChatSettingSingleModel';

const TAG = 'PrivateChatSettingModel';

@ObservedV2
export class PrivateChatSettingModel {
  @Trace pageTitle: string = '聊天设置';
  @Trace pageType: PrivateChatSettingEnum = PrivateChatSettingEnum.C2C;
  @Trace userId: string = '';
  @Trace conversationID: string = '';
  @Trace avatar: string = '';
  @Trace showName: string = '';
  @Trace isBlackList: boolean = false;
  @Trace isFix: boolean = false;
  @Trace isFriend: boolean = false;
  @Trace pageData: PrivateChatSettingSingleModel[] = [];

  setPageData() {
    this.pageData = [];
    if (this.pageType === PrivateChatSettingEnum.C2C) {
      let avatarGroup = new PrivateChatSettingSingleModel($r('app.float.vp_44'));
      avatarGroup.type = PrivateChatSettingSingleEnum.GROUP;
      avatarGroup.title = '发起群聊';
      this.pageData.push(avatarGroup);
      let avatar = new PrivateChatSettingSingleModel($r('app.float.vp_72'));
      avatar.type = PrivateChatSettingSingleEnum.AVATAR;
      avatar.icon = Constants.getMockAvatar(this.userId);
      avatar.isTopBorderRadius = true;
      avatar.isBottomBorderRadius = true;
      this.pageData.push(avatar);
      this.pageData.push(new PrivateChatSettingSingleModel());
      let search = new PrivateChatSettingSingleModel($r('app.float.vp_60'));
      search.type = PrivateChatSettingSingleEnum.TITLE;
      search.title = '查找聊天记录';
      search.isTopBorderRadius = true;
      this.pageData.push(search);
      let background = new PrivateChatSettingSingleModel($r('app.float.vp_60'));
      background.type = PrivateChatSettingSingleEnum.TITLE;
      background.title = '设置当前聊天背景';
      this.pageData.push(background);
      let deleteVM = new PrivateChatSettingSingleModel($r('app.float.vp_60'));
      deleteVM.type = PrivateChatSettingSingleEnum.TITLE;
      deleteVM.title = '删除聊天记录';
      deleteVM.isBottomBorderRadius = true;
      this.pageData.push(deleteVM);
    }

    if (this.isFriend) {
      this.pageData.push(new PrivateChatSettingSingleModel());
      let remark = new PrivateChatSettingSingleModel($r('app.float.vp_60'));
      remark.type = PrivateChatSettingSingleEnum.TITLE;
      remark.title = '修改备注';
      remark.isTopBorderRadius = true;
      this.pageData.push(remark);
      let blacklist = new PrivateChatSettingSingleModel($r('app.float.vp_60'));
      blacklist.type = PrivateChatSettingSingleEnum.SWITCH;
      blacklist.title = '加入黑名单';
      blacklist.isBottomBorderRadius = true;
      this.pageData.push(blacklist);
    }

    if (this.pageType === PrivateChatSettingEnum.FRIEND) {
      this.pageData.push(new PrivateChatSettingSingleModel());
      let deleteFriend = new PrivateChatSettingSingleModel($r('app.float.vp_46'));
      deleteFriend.type = PrivateChatSettingSingleEnum.BUTTON;
      deleteFriend.title = '删除好友';
      this.pageData.push(deleteFriend);
    }
  }

  // 点击联系人头像，跳转到联系人详情
  gotoContactAvatar() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.AVATAR_URL_VIEW,
      builder: wrapBuilder(AvatarUrlViewPageBuilder),
      param: this.userId as TValueType,
    })
  }

  gotoStartGroup() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.START_GROUP_PAGE,
      builder: wrapBuilder(StartGroupPageBuilder),
      param: this.userId as TValueType
    })
  }

  onSettingsClick(settingVM: PrivateChatSettingSingleModel, context: Context, uIContext: UIContext) {
    if (settingVM.title === '删除聊天记录') {
      this.deleteConversation();
    } else if (settingVM.title === '修改备注') {
      this.setFriendInfo();
    } else if (settingVM.title === '查找聊天记录') {
      this.chatHistorySearch(this.userId, undefined);
    } else if (settingVM.title === '设置当前聊天背景') {
      let chatBackgroundSkillUtil: ChatBackgroundSkillUtil = new ChatBackgroundSkillUtil()
      chatBackgroundSkillUtil.chatBackgroundSkill(context, uIContext)
    }
  }

  /**
   * 删除会话
   */
  deleteConversation() {
    let dialogVM = new DeleteMsgModel();
    dialogVM.title = `确定删除和${this.showName}的聊天记录吗？`;
    dialogVM.onValueConfirmClick = (_model: Object) => {
      CMChatFactory.instance.deleteConversationList([this.conversationID], true)
        .then((result: CMChatConversationOperationResult[]) => {
          if (result[0].resultCode === 0) {
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除成功' });
            this.isFix = true;
          } else {
            TCLogger.error(TAG, `delete conversation fail ` + JSON.stringify(result));
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除失败' })
          }
        }).catch((err: BusinessError) => {
        TCLogger.error(TAG, `delete conversation err ` + JSON.stringify(err));
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除失败' })
      });
    };
    OHDialog.showPopup(dialogVM);
  }

  /**
   * 添加用户到黑名单
   */
  async addToBlackList() {
    let dialogVM = new DeleteMsgModel();
    dialogVM.title = `加入黑名单，你将不再收到对方消息`;
    dialogVM.confirmTitle = '确认';
    dialogVM.confirmFontColor = $r('sys.color.font_emphasize');
    dialogVM.onValueConfirmClick = async (_model: Object) => {
      let result = await CMChatFactory.instance.addToBlackList([this.userId]);
      const response = result[0];
      if (response.resultCode === 0) {
        this.isBlackList = true;
        this.isFix = true;
      } else {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '加入失败'
        })
      }
    };
    OHDialog.showPopup(dialogVM);
  }

  /**
   * 把用户从黑名单中删除
   */
  async deleteFromBlackList() {
    let result = await CMChatFactory.instance.deleteFromBlackList([this.userId]);
    const response = result[0];
    if (response.resultCode === 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '移除成功'
      })
      this.isBlackList = false;
      await CMChatFactory.instance.addFriend(this.userId, this.showName);
      this.isFix = true;
    } else {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '移除失败'
      })
    }
  }

  /**
   * 获取黑名单列表
   */
  async getBlackList() {
    let result = await CMChatFactory.instance.getBlackList();
    const memberIds = new Set(result.map(item => item.userId));
    this.isBlackList = memberIds.has(this.userId);
  }

  /**
   * 删除好友
   */
  async deleteFromFriendList() {
    let dialogVM = new DeleteMsgModel();
    dialogVM.title = `确定要删除联系人“${this.showName}”`;
    dialogVM.onValueConfirmClick = async (_model: Object) => {
      let result = await CMChatFactory.instance.deleteFromFriendList([this.userId]);
      const response = result[0];
      if (response.resultCode === 0) {
        this.isFix = true;
        phoneRouterControl.popPage({ popData: 'fixContact' });
      } else {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '删除失败'
        })
      }
    };
    OHDialog.showPopup(dialogVM);
  }

  /**
   * 设置指定好友备注
   */
  setFriendInfo() {
    let dialogVM = new MsgInputModel();
    dialogVM.title = `备注`;
    dialogVM.placeholder = '修改好友备注';
    dialogVM.value = this.showName;
    dialogVM.onValueConfirmClick = (model: Object) => {
      let msgModel: MsgInputModel | undefined;
      try {
        msgModel = model as MsgInputModel;
      } catch (err) {
      }

      if (this.showName === msgModel?.value) {
        return;
      }

      if (msgModel?.value === undefined ||
        msgModel?.value?.length === 0) {
        return;
      }


      if (MessageUtil.strOverByteLength(msgModel?.value, 96)) {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '好友备注长度最长不得超过96个字节'
        })
        return;
      }

      CMChatFactory.instance.setFriendInfo(this.userId, msgModel?.value ?? '').then(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '修改成功'
        })
        this.isFix = true;
        this.showName = msgModel?.value ?? '';
      }).catch(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '修改失败'
        })
      })
    };
    dialogVM.childBuilder = dialogMsgInputBuilder;
    OHDialog.showPopup(dialogVM);
  }

  /**
   * 搜索跳转方法
   */
  chatHistorySearch(userId?: string, groupId?: string) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.CHAT_HISTORY_SEARCH_PAGE,
      builder: wrapBuilder(ChatHistorySearchPageBuilder),
      param: { 'userId': userId, 'groupId': groupId } as Record<string, string | undefined>,
    })
  }
}

