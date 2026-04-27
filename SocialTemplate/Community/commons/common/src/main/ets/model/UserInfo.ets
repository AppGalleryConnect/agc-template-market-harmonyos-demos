import { Type } from '@ohos.arkui.StateManagement';

@ObservedV2
export class UserInfo {
  @Trace id: string = '';
  @Trace nickName: string = ''; // 昵称
  @Trace avatarUrl: string = ''; // 头像
  @Trace userSig: string = ''; // 签名
  @Trace gender: string = ''; // 性别
  @Trace age: string = ''; // 年龄
  @Trace birthday: string = ''; // 出生日期
  @Trace telephone: string = ''; // 手机号
  @Trace email: string = ''; // 邮箱
  @Trace introDesc: string = ''; // 个人简介
  @Trace isLogin: boolean = false; // 是否登录
  @Trace chatBgImage: string = ''; // 聊天背景图
  @Trace messageNotificationTone: boolean = false; // 消息提示音
  @Trace messageVibrationAlert: boolean = false; // 消息震动提示音
  @Trace groupMessageNotificationTone: boolean = false; // 群消息震动提示音
}

export class PopInfoResult {
  phone: string = ''
  uid: string = ''
}

@ObservedV2
export class FriendUserInfo {
  @Type(UserInfo)
  @Trace userInfoList: UserInfo[] = []
}