import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfo } from 'common';

@ObservedV2
export class NewFileFolderOperationSelectVM {
  // 是否显示新建文件夹布局
  @Trace isShow: boolean = false;
  // 显示新建文件夹对话框
  @Trace isShowInput: boolean = false;
  // 全局用户信息对象
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
}
