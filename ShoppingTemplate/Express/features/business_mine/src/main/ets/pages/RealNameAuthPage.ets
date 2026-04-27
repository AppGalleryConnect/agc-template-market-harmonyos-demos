import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { CommonTitle, HttpApi, RouterModule, User, UserInfoModel, WindowInfo } from 'lib_foundation';
import { RealNameAuthView } from 'module_auth';

@Builder
export function RealNameAuthPageBuilder() {
  RealNameAuthPage()
}

@ComponentV2
struct RealNameAuthPage {
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;

  verify() {
    const data = {
      userId: this.userInfoModel.id,
      isRealName: 1,
    } as User;
    HttpApi.updateUserInfo(data).then(() => {
      this.userInfoModel.isRealName = 1;
      ToastDialog.showToast({ message: '实名成功！'})
    })
  }

  build() {
    NavDestination() {
      Column() {
        CommonTitle({
          title: '实名认证',
        })
        RealNameAuthView({
          pathStack: RouterModule.stack,
          confirm: () => {
            if (this.userInfoModel) {
              this.verify();
              RouterModule.pop();
            }
          }
        })
          .layoutWeight(1)
      }
      .padding({
        bottom: this.windowModel.windowBottomPadding
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}