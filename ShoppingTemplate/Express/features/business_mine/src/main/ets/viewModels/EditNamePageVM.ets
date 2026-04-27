import { RouterModule } from 'lib_foundation';
import { BaseViewModel, toastUtil } from 'module_base'

const TAG = '[EditNamePageVM]';

@ObservedV2
export class EditNamePageVM extends BaseViewModel {
  private static _instance: EditNamePageVM;
  @Trace isLogin: boolean = false
  @Trace nickname: string = ''

  public static get instance() {
    if (!EditNamePageVM._instance) {
      EditNamePageVM._instance = new EditNamePageVM();
    }
    return EditNamePageVM._instance;
  }

  init() {
    this.nickname = this.userInfoModel.nickname
  }

  clear() {
    this.nickname = ''
  }

  modify() {
    if (!this.userInfoModel) {
      return
    }
    if (!this.nickname) {
      toastUtil.showToast('昵称不能为空');
      return
    }
    if (this.nickname.length > 8) {
      toastUtil.showToast('昵称不能超过8位');
      return
    }
    this.userInfoModel.nickname = this.nickname
    toastUtil.showToast('修改成功！')
    RouterModule.pop()
  }
}
