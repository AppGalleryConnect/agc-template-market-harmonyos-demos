import { PreferenceConstant, PreferenceUtil } from 'common'

// 隐私空间密码管理vm
@ObservedV2
export class SettingPrivateSpacePasswordPageVM {
  @Trace inputPassword: string = ''
  @Trace surePassword: string = ''

  // 保存密码
  savePrivateSpacePassword() {
    PreferenceUtil.getInstance().put(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY, this.inputPassword)
  }
}