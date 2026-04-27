import { GlobalContext, OHDialog, RouterMap } from 'common';
import { CMChatFactory, CMChatGroupInfo } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { MsgInputModel } from '../components/MsgInputDialog';
import { AddGroupMemberRoleViewPageBuilder } from '../view/AddGroupMemberRoleView';
import { DeleteGroupMemberRoleViewPageBuilder } from '../view/DeleteGroupMemberRoleView';
import { util } from '@kit.ArkTS';

@ObservedV2
export class MemberRoleViewViewModel {
  /**
   * 解散群聊方法
   */
  async disbandGroup(groupID: string) {
    let dialogVM = new MsgInputModel();
    dialogVM.title = `确定要解散群聊?`;
    dialogVM.onValueConfirmClick = (_model: Object) => {
      CMChatFactory.instance.dismissGroup(groupID).then(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '解散群聊成功'
        })
        //完成后延迟释放
        setTimeout(() => {
          phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length)
        }, 500); // 延迟到事件循环空闲时执行
      }).catch(() => {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '解散群聊失败'
        })
      })
    };
    OHDialog.showPopup(dialogVM);
  }

  /**
   * 跳转添加管理员页面
   */
  routerAddGroupMemberRole(paramData: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.ADD_GROUP_MEMBER_ROLE_VIEW,
      param: paramData,
      builder: wrapBuilder(AddGroupMemberRoleViewPageBuilder)
    })
  }

  /**
   * 跳转移除管理员页面
   */
  routerDeleteGroupMemberRole(memberRoleData: CMChatGroupInfo) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.DELETE_GROUP_MEMBER_ROLE_VIEW,
      param: memberRoleData,
      builder: wrapBuilder(DeleteGroupMemberRoleViewPageBuilder)
    })
  }

  /**
   * 添加群成员方法
   */
  async addGroupMember(groupID: string, userList: string[]) {
    CMChatFactory.instance.inviteUserToGroup(groupID, userList)
    GlobalContext.getUIContext().getPromptAction().showToast({
      message: '添加群成员成功'
    })
  }

  /**
   * 移除群成员方法
   */
  async deleteGroupMember(groupID: string, memberList: string[],
    reason: string,
    duration: number) {
    CMChatFactory.instance.kickGroupMember(groupID, memberList, reason, duration)
    GlobalContext.getUIContext().getPromptAction().showToast({
      message: '移除群成员成功'
    })
  }

  /**
   * 修改群简介
   */
  async groupIntroduction(memberInfoList: CMChatGroupInfo, plainText: string) {
    memberInfoList.introduction = plainText
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

  /*
   * 检查字符串的字节大小是否超出
   * str：待检查的字符串
   * maxLength: 最大字节长度，默认400字节
   * return boolean
   */
  strOverByteLength(str: string, maxLength: number = 400) {
    let textEncoder = new util.TextEncoder();
    let result: Uint8Array = textEncoder.encodeInto(str);
    if (result.byteLength > maxLength) {
      return true;
    }
    return false;
  }

  /**
   * 修改群公告
   */
  async setBulletin(memberInfoList: CMChatGroupInfo, plainText: string) {
    memberInfoList.notification = plainText
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

  /**
   * 超过3个管理员提示
   */
  noAddGroupMemberRole() {
    GlobalContext.getUIContext().getPromptAction().showToast({
      message: '管理员最多设置3个，管理员已满'
    })
  }
}