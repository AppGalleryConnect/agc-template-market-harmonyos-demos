import { common } from '@kit.AbilityKit';
import { ComponentContent, PersistenceV2, promptAction, window } from '@kit.ArkUI';
import { GlobalContext, UserInfo } from 'common';
import { checkUpdate, DialogController, findNewVersion, Params } from 'check_app_update';

@ObservedV2
export class SettingAboutVM {
  logTag: string = 'SetUpPage';
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace cacheSize: string = '计算中...'
  ctx: UIContext = GlobalContext.getUIContext();

  checkAppUpdate() {
    checkUpdate(this.ctx.getHostContext() as common.UIAbilityContext)
      .then(version => {
        // 0 不存在新版本， 1 存在新版本
        if (version === 1) {
          this.showCallDialog(version);
        } else {
          // 已经是最新版本
          promptAction.showToast({ message: '已是最新版本' })
        }
      })
  }

  showCallDialog(version: number) {
    DialogController.setContext(this.ctx);
    let contentNode: ComponentContent<object> =
      new ComponentContent(this.ctx, wrapBuilder(findNewVersion), new Params(version))
    DialogController.setContentNode(contentNode);
    DialogController.setOptions({ alignment: DialogAlignment.Center, offset: { dx: 0, dy: 0 } })
    DialogController.openDialog();
  }

  clearUserInfo() {
    this.userInfo.id = '';
    this.userInfo.avatarUrl = '';
    this.userInfo.nickName = '';
    this.userInfo.telephone = '';
    this.userInfo.isLogin = false;
    this.userInfo.gender = '';
    this.userInfo.age = '';
    this.userInfo.birthday = '';
    this.userInfo.email = '';
  }
}