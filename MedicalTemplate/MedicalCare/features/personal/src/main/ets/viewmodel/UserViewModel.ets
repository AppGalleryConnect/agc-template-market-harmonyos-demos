import { BaseViewModel, DataUtil, LoadingDialogUtil, ToastUtil } from 'common'
import { UserApi } from '../api/UserApi'
import { UserModel } from '../model/UserModel'
import { functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi'
import { BusinessError } from '@ohos.base'

@ObservedV2
export class UserViewModel extends BaseViewModel {
  @Trace userModel: UserModel = new UserModel()
  @Trace userModelEdited: UserModel = new UserModel()
  private userApi: UserApi = new UserApi()
  private static instance: UserViewModel

  public static getInstance() {
    if (!UserViewModel.instance) {
      UserViewModel.instance = new UserViewModel()
    }
    return UserViewModel.instance
  }

  public onGetPhoneNumber(err: BusinessError<void>, data: functionalButtonComponentManager.GetPhoneNumberResult) {
    LoadingDialogUtil.close()
    if (err) {
      if (err.code !== 1001502012) {
        ToastUtil.showToast(`获取手机号失败: ${err.message}`)
      }
      return;
    }
    // 开发者处理AuthorizationCode
    let authorizationCode = data.code;
    this.bindPhone(authorizationCode)
  }

  public getUserInfo() {
    this.userApi.loginHospitalUser().then((data) => {
      this.userModel = DataUtil.copyObject(new UserModel(), data)
    })
  }

  public bindPhone(code?: string) {
    if (!code) {
      ToastUtil.showToast('获取手机号失败')
      return
    }
    this.userApi.loginHospitalUser(code).then((data) => {
      this.userModel.isPhoneAssociated = true
      // JustMock
      this.userModel.name = '张伟'
      this.userModel.cellphone = '188****1234'
    })
  }

  public saveUser() {
    this.userApi.uploadUserInfo(this.userModelEdited).then(() => {
      ToastUtil.showToast('用户信息更新成功')
      this.userModel = DataUtil.copyObject(new UserModel(), this.userModelEdited)
    })
  }

  public unbindPhone() {
    this.userModel.isPhoneAssociated = false
    this.userModel.cellphone = ''
    this.userApi.uploadUserInfo(this.userModel).then(() => {
      ToastUtil.showToast('用户信息更新成功')
    })
  }

  public toPersonalPage() {
    this.toPage('PersonalPage')
    this.userModelEdited = DataUtil.copyObject(new UserModel(), this.userModel)
  }

  public getUserName(useEdited: boolean = false) {
    let userModel = useEdited ? this.userModelEdited : this.userModel
    return userModel.name || '华为用户'
  }

  public getUserPhone(useEdited: boolean = false) {
    let userModel = useEdited ? this.userModelEdited : this.userModel
    return userModel.isPhoneAssociated ? userModel.cellphone : '未关联手机号'
  }
}
