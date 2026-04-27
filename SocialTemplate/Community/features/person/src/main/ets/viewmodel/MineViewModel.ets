import { GlobalContext, RouterMap } from 'common';
import { CMChatFactory, CMChatFriendInfo } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from '../views/LoginPage';
import { QRCodePageBuilder } from '../views/QRCodePage';

@ObservedV2
export class MineViewModel {
  @Trace cMChatFriendInfo: CMChatFriendInfo[] = []

  /**
   * 二维码跳转方法
   */
  qrcodeViewMethod() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.QR_CODE_PAGE,
      builder: wrapBuilder(QRCodePageBuilder)
    })
  }

  /**
   * 跳转登录页面方法
   */
  isLoginMethod() {
    // 非设置页面需要登录
    phoneRouterControl.jumpPage({
      pageName: RouterMap.LOGIN_PAGE,
      builder: wrapBuilder(LoginPageBuilder)
    })
  }

  /**
   * 获取黑名单列表
   */
  async getBlackLists() {
    this.cMChatFriendInfo = []
    let result = await CMChatFactory.instance.getBlackList();
    result.forEach((item: CMChatFriendInfo) => {
      this.cMChatFriendInfo.push(item)
    })
  }

  /**
   * 把用户从黑名单中删除
   */
  async deleteFromBlackList(userIds: string[], nickName: string[]) {
    let result = await CMChatFactory.instance.deleteFromBlackList(userIds);
    const response = result[0];
    if (response.resultCode === 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '移除成功'
      })
      this.getBlackLists()
      for (let i = 0 ; i < userIds.length ; i++){
       await this.addFriend(userIds[i], nickName[i])// 延迟执行的释放函数
      }
    } else {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '移除失败'
      })
    }
  }

  /**
   * 添加好友
   */
  async addFriend(userId: string, nickName: string) {
    let result = await CMChatFactory.instance.addFriend(userId, nickName);
  }
}