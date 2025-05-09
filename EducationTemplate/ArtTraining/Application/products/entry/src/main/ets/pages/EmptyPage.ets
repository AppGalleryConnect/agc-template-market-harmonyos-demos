import { AccountUtil, WindowUtil } from 'commonlib';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct EmptyPage {
  aboutToAppear(): void {
    AccountUtil.silentLogin().then(() => {
      if (AccountUtil.getAccountInfo().openID) {
        WindowUtil.initWindowUtil();
        router.replaceUrl({
          url: 'pages/MainEntry',
        });
      } else {
        promptAction.showToast({ message: '请先登录华为账号~' });
      }
    })
      .catch(() => {
        promptAction.showToast({ message: '华为账号登录失败，请检查工程签名配置~' });
      });
  }

  build() {
    RelativeContainer() {

    }
    .height('100%')
    .width('100%');
  }
}