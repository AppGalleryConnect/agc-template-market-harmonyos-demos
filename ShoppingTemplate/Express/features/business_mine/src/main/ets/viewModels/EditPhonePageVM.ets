import { RouterModule } from 'lib_foundation';
import { BaseViewModel, toastUtil } from 'module_base'

const TAG = '[EditPhonePageVM]';

@ObservedV2
export class EditPhonePageVM extends BaseViewModel {
  private static _instance: EditPhonePageVM;
  @Trace isLogin: boolean = false
  @Trace public cellphone: string = ''

  public static get instance() {
    if (!EditPhonePageVM._instance) {
      EditPhonePageVM._instance = new EditPhonePageVM();
    }
    return EditPhonePageVM._instance;
  }

  init() {
    this.cellphone = this.userInfoModel.cellphone
  }

  clear() {
    this.cellphone = ''
  }

  modify() {
    if (!this.userInfoModel) {
      return
    }
    if (!this.cellphone) {
      toastUtil.showToast('手机号不能为空');
      return
    }

    if (this.cellphone.length !== 11) {
      toastUtil.showToast('手机号不是11位');
      return
    }

    this.userInfoModel.cellphone = this.cellphone
    toastUtil.showToast('修改成功！')
    RouterModule.pop()
  }
}
