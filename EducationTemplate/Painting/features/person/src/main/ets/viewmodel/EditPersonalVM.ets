import { FormGroup, FormType, ObservedInfoItem } from 'collect_personal_info'
import { TimeUtil, UserInfo } from 'common';
import { PersistenceV2 } from '@kit.ArkUI';
import { GenderStringToType, GenderTypeToString } from '../utils/TypeConversion';

@ObservedV2
export class EditPersonalVM {
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfo.avatarUrl || $r('app.media.path2x'),
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.userInfo.avatarUrl = param as ResourceStr;
    },
  });
  @Trace nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '姓名',
    value: this.userInfo.nickName,
    minLength: 2,
    maxLength: 10,
    placeholderText: '姓名',
    invocation: (param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '内容为空，请输入后保存',
    onChange: (param?: Object) => {
      this.nickNameItem.value = param as string;
      this.userInfo.nickName = param as string
    },
  })
  @Trace list: FormGroup[] = [
    {
      list: [
        this.avatarItem,
        this.nickNameItem,
      ],
    },
  ];
}