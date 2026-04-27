import { PreferenceUtil, StringUtils, PreferenceConstant } from 'common'

// 修改隐私空间密码内容数据模型
export class PasswordChangeViewModel {
  oldPasswoed: string = ''
  newPassword: string = ''
  surePassword: string = ''
  savePassWoedSuccess: (success: boolean, content: string | Resource) => void = () => {
  }

  setOldPasswoed(value: string) {
    this.oldPasswoed = value
  }

  setNewPasswoed(value: string) {
    this.newPassword = value
  }

  setSurePasswoed(value: string) {
    this.surePassword = value
  }

  // 判断按钮是否能点击
  public checkResult(): boolean {
    let result = false
    if (!StringUtils.isEmpty(this.oldPasswoed) &&
      !StringUtils.isEmpty(this.newPassword) &&
      !StringUtils.isEmpty(this.surePassword)) {
      result = true
    }

    return result
  }

  // 判断能否直接返回
  public canBackNotSave(): boolean {
    if (!this.checkResult()) {
      return true
    }

    const password: string = PreferenceUtil.getInstance().get(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY, '1') as string
    if (password !== this.newPassword) {
      return false
    }

    return true
  }

  savePrivateSpacePassword() {
    let result = false
    let content: string | Resource = ''
    let spInstance = PreferenceUtil.getInstance()
    if (spInstance.get(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY, '1') === this.oldPasswoed) {
      if (this.newPassword === this.surePassword) {
        result = true
        content = $r('app.string.change_success')
        spInstance.put(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY, this.surePassword)
      } else {
        result = false
        content = $r('app.string.secret_not_same')
      }
    } else {
      result = false
      content = $r('app.string.old_secret_not_correct')
    }
    if (this.savePassWoedSuccess) {
      this.savePassWoedSuccess(result, content)
    }
  }
}
