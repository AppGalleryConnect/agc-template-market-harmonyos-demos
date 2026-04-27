import { AddFriendTypeEnum } from '../utils/MessageEnum';
import { AddFriendSingleModel } from '../viewmodel/AddFriendSingleModel';

export const ADD_FRIEND_LIST: AddFriendSingleModel[] = [
  {
    icon: $r('app.media.add_friend_contact'),
    title: '手机联系人添加',
    subtitle: '添加通讯录中的朋友',
    type: AddFriendTypeEnum.CHAT_TYPE_Contact
  },
  {
    icon: $r('app.media.add_friend_scan'),
    title: '扫一扫',
    subtitle: '扫描二维码名片',
    type: AddFriendTypeEnum.CHAT_TYPE_Scan
  }
];