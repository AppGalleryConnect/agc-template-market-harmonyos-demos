import { common } from '@kit.AbilityKit';
import { ComponentContent, PersistenceV2, promptAction, window } from '@kit.ArkUI';
import { CacheUtil, GlobalContext, TCLogger, UserInfo } from 'common';
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

  getClearSize() {
    CacheUtil.getCache().then((resp: number) => {
      TCLogger.info(this.logTag, 'getClearSize resp:' + resp);
      // 计算缓存大小（转换为KB或MB）
      let cacheSizeInKB = resp / 1024;
      if (cacheSizeInKB > 1024) {
        this.cacheSize = (cacheSizeInKB / 1024).toFixed(2) + 'MB';
      } else {
        this.cacheSize = cacheSizeInKB.toFixed(2) + 'KB';
      }
    })
  }

  showAlert() {
    this.ctx.showAlertDialog({
      message: '仅限清除APP内部缓存文件，不包含下载的文件',
      subtitle: '确认清除APP缓存吗？',
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            this.clean()
          }
        }
      ]
    })
  }

  async clean() {
    // 清除APP缓存文件，不包括清除下载
    CacheUtil.clearCache()
    this.cacheSize = '0.00KB'
    // 显示成功提示
    this.ctx.getPromptAction().showToast({
      message: '缓存清除成功',
      duration: 2000
    });
    TCLogger.info(this.logTag, 'clean cache completed');
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