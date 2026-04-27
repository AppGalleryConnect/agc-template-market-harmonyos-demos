import { BusinessError } from '@kit.BasicServicesKit'
import { cameraPicker as picker } from '@kit.CameraKit'
import { fileUri } from '@kit.CoreFileKit'
import { GlobalContext, OHDialog, RouterMap, TCLogger, UserInfo } from 'common'
import { CMChatConversationOperationResult, CMChatFactory, CMChatGroupInfo } from 'instant_messaging'
import { phoneRouterControl } from 'oh_router'
import { BulletinViewPageBuilder } from '../view/BulletinView'
import { GroupIntroductionViewPageBuilder } from '../view/GroupIntroductionView'
import { dialogMsgInputBuilder, MsgInputModel } from '../components/MsgInputDialog'
import { DeleteMsgModel } from '../components/DeleteMsgDialog'
import { MemberRoleViewPageBuilder } from '../view/MemberRoleView'
import { AddGroupMemberViewPageBuilder } from '../view/AddGroupMemberView'
import { DeleteGroupMemberViewPageBuilder } from '../view/DeleteGroupMemberView'
import { ChatHistorySearchPageBuilder } from '../view/ChatHistorySearchPage'
import { CustomActionSheet } from '../view/DialogPage'
import { ChatInputComponentViewModel } from 'chat_input'
import { MessageUtil } from '../utils/MessageUtil'

const TAG = 'ChatSettingsViewModel';

@ObservedV2
export class ChatSettingsViewModel {
  @Trace conversationID: string = '';
  @Trace isFix: boolean = false;
  @Trace groupId: string = '';

  /**
   * 跳转群公告页面方法
   * @param pames
   */
  bulletinView(pames: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.BULLETIN_VIEW,
      param: pames,
      builder: wrapBuilder(BulletinViewPageBuilder)
    })
  }

  /**
   * 跳转群简介页面方法
   * @param pames
   */
  groupIntroductionView(pames: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.GROUP_INTRODUCTION_VIEW,
      param: pames,
      builder: wrapBuilder(GroupIntroductionViewPageBuilder)
    })
  }

  /**
   * 修改群聊名称方法
   * @param memberInfoList
   */
  groupNameView(memberInfoList: CMChatGroupInfo) {
    let dialogVM = new MsgInputModel();
    dialogVM.title = `群聊名称`;
    dialogVM.value = memberInfoList.groupName ? memberInfoList.groupName : '请输入';
    dialogVM.onValueConfirmClick = (model: Object) => {
      let msgModel: MsgInputModel | undefined;
      try {
        msgModel = model as MsgInputModel;
      } catch (err) {
      }

      if (memberInfoList.groupName === msgModel?.value) {
        return;
      }

      if (msgModel?.value === undefined ||
        msgModel?.value?.length === 0) {
        return;
      }

      if (MessageUtil.strOverByteLength(msgModel?.value, 30)) {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '群名称最长30字节'
        })
        return;
      }

      memberInfoList.groupName = msgModel?.value ?? ''
      CMChatFactory.instance.setGroupInfo(memberInfoList).then(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '修改成功'
        })
        this.isFix = true;
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
   * 群聊备注弹窗
   * @param memberInfoList
   */
  groupNotesNameView(memberInfoList: CMChatGroupInfo) {
    let dialogVM = new MsgInputModel();
    dialogVM.title = `群聊备注`;
    dialogVM.value = memberInfoList.groupRemark ? memberInfoList.groupRemark : '请输入';
    dialogVM.onValueConfirmClick = (model: Object) => {
      let msgModel: MsgInputModel | undefined;
      try {
        msgModel = model as MsgInputModel;
      } catch (err) {
      }

      if (memberInfoList.groupRemark === msgModel?.value) {
        return;
      }

      if (msgModel?.value === undefined ||
        msgModel?.value?.length === 0) {
        return;
      }
      memberInfoList.groupRemark = msgModel?.value ?? ''
      CMChatFactory.instance.setGroupInfo(memberInfoList).then(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '修改成功'
        })
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
   * 我在群里昵称弹窗
   * @param memberInfoList
   */
  miNameView(memberInfoList: CMChatGroupInfo, userInfo: UserInfo) {
    let dialogVM = new MsgInputModel();
    dialogVM.title = `我在本群昵称`;
    dialogVM.value = memberInfoList.groupMiRemark ? memberInfoList.groupMiRemark : userInfo.nickName;
    dialogVM.onValueConfirmClick = (model: Object) => {
      let msgModel: MsgInputModel | undefined;
      try {
        msgModel = model as MsgInputModel;
      } catch (err) {
      }

      if (memberInfoList.groupMiRemark === msgModel?.value) {
        return;
      }

      if (msgModel?.value === undefined ||
        msgModel?.value?.length === 0) {
        return;
      }
      memberInfoList.groupMiRemark = msgModel?.value ?? ''
      CMChatFactory.instance.setGroupInfo(memberInfoList).then(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '修改成功'
        })
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
   * 修改群头像
   */
  setfaceURL(memberInfoList: CMChatGroupInfo, context: Context) {
    let chatInputComponentViewModel: ChatInputComponentViewModel = new ChatInputComponentViewModel()
    CustomActionSheet.show({
      title: '选择图片',
      sheets: [
        {
          title: '拍照',
          action: async () => {
            let pathDir = context.cacheDir;
            let fileName = `${Date.now()}`;
            let filePath = pathDir + `/${fileName}.png`;
            let result = await chatInputComponentViewModel.takePhoto(context, filePath)
            if (result.mediaType === picker.PickerMediaType.PHOTO) {
              const sendContent = await chatInputComponentViewModel.getImageInfo(filePath)
              let fileUriObject = new fileUri.FileUri(sendContent.pictureUrl);
              memberInfoList.faceURL = fileUriObject.toString()
              CMChatFactory.instance.setGroupInfo(memberInfoList).then(() => {
                GlobalContext.getUIContext().getPromptAction().showToast({
                  message: '修改成功'
                })
              }).catch(() => {
                GlobalContext.getUIContext().getPromptAction().showToast({
                  message: '修改失败'
                })
              })
            }
          }
        },
        {
          title: '从手机相册选择',
          action: () => {
            chatInputComponentViewModel.selectPhoto(context).then(async (result: string) => {
              const sendContent = await chatInputComponentViewModel.getImageInfo(result)
              let fileUriObject = new fileUri.FileUri(sendContent.pictureUrl);
              //将沙箱里面的URL转换成image组件可以识别的URL
              memberInfoList.faceURL = fileUriObject.toString()
              CMChatFactory.instance.setGroupInfo(memberInfoList).then(() => {
                GlobalContext.getUIContext().getPromptAction().showToast({
                  message: '修改成功'
                })
              }).catch(() => {
                GlobalContext.getUIContext().getPromptAction().showToast({
                  message: '修改失败'
                })
              })
            })
          }
        }
      ],
      confirm: {
        value: '取消',
        action: () => {

        }
      },
      cancel: () => {

      }
    })
  }

  /**
   * 删除聊天记录方法
   */
  deleteImConversation(conversationID: string) {
    let dialogVM = new DeleteMsgModel();
    dialogVM.title = `确定删除聊天记录吗？`;
    dialogVM.message = '';
    dialogVM.onValueConfirmClick = (_model: Object) => {
      CMChatFactory.instance.deleteConversationList([conversationID], true)
        .then((result: CMChatConversationOperationResult[]) => {
          if (result[0].resultCode === 0) {
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除成功' })
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

  async getGroupMemberList() {
    let result = await CMChatFactory.instance.getGroupMemberList(this.groupId, 0, 0);
    return result.memberInfoList;
  }

  /**
   * 退出群聊方法
   * @param groupID
   */
  async quitGroupData(groupID: string) {
    CMChatFactory.instance.quitGroup(groupID).then(() => {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '退出群聊成功'
      })
      phoneRouterControl.popPage({ popData: 'fixContact' });
    }).catch(() => {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '退出群聊失败'
      })
    })
  }

  /**
   * 群管理跳转页面
   */
  groupMemberRoleView(pames: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MEMDER_ROLE_VIEW,
      param: pames,
      builder: wrapBuilder(MemberRoleViewPageBuilder)
    })
  }

  /**
   * 添加群成员跳转
   */
  addGroupMember(pames: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.ADD_GROUP_MEMBER_VIEW,
      param: pames,
      builder: wrapBuilder(AddGroupMemberViewPageBuilder)
    })
  }

  /**
   * 移除群成员跳转
   */
  deleteGroupMember(pames: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.DELETE_GROUP_MEMBER_VIEW,
      param: pames,
      builder: wrapBuilder(DeleteGroupMemberViewPageBuilder)
    })
  }

  /**
   * 添加好友
   */
  async addFriend(userId: string, nickName: string) {
    let result = await CMChatFactory.instance.addFriend(userId, nickName);
    if (result.resultCode === 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '添加成功'
      })
    } else {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '添加失败'
      })
    }
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