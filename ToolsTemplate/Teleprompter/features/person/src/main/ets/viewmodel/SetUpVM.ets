import { common } from '@kit.AbilityKit';
import { ComponentContent, PersistenceV2, UIContext, window } from '@kit.ArkUI';
import { GlobalContext, UserInfo } from 'common';
import { checkUpdate, DialogController, findNewVersion, Params } from 'check_app_update';

@ObservedV2
export class SettingAboutVM {
  logTag: string = 'SetUpPage';
  @Trace bottomHeight: number = 0;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace isVersionCheckSheet: boolean = false
  ctx: UIContext = GlobalContext.getUIContext();

  init() {
    try {
      window.getLastWindow(new UIContext().getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    } catch (e) {
    }
  }

  checkAppUpdate() {
    checkUpdate(this.ctx.getHostContext() as common.UIAbilityContext)
      .then(version => {
        // 0 不存在新版本， 1 存在新版本
        if (version === 1) {
          this.showCallDialog(version);
        } else {
          // todo 模拟最新版本
          this.showCallDialog(version);
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