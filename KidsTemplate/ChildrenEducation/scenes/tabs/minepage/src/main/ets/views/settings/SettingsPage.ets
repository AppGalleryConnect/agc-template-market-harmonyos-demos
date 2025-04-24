import { AuthUtil, CommonConstants, rightArrow } from '@ohos_agcit/children_education_utils';
import { userAuth } from '@kit.UserAuthenticationKit';
import { CustomContentDialog } from '@kit.ArkUI';

@Builder
export function SettingsPageBuilder() {
  SettingsPage();
}


@ComponentV2
export struct SettingsPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column({ space: 17 }) {
        Row() {
          Text('隐私协议')
            .textExtend();
          Blank();
          rightArrow()
        }.width(CommonConstants.FULL_PERCENT)
        .onClick(() => {
          this.appPathStack.pushPathByName('PrivacyAgreement', undefined);
        });

        Divider();

        Row() {
          Text('时长控制')
            .textExtend();
          Blank();
          rightArrow()
        }.width(CommonConstants.FULL_PERCENT)
        .onClick(() => {
          AuthUtil.onStartEasy(true, (result: userAuth.UserAuthResult) => {
            if (result.result === 12500000) {
              this.appPathStack.pushPathByName('TimeCtrl', undefined);
            } else if (result.result === 12500010) {
              this.dialogController.open();
              this.appPathStack.pushPathByName('TimeCtrl', undefined);
            }
          });
        });

        Divider();
      }.padding({ right: 16, left: 16, top: 34 });
    }
    .title('设置')
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '温馨提示',
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
          },
        },
      ],
    }),
    autoCancel: false,
  });

  @Builder
  buildContent(): void {
    Column() {
      Text('您的手机还未录入指纹、人脸识别、锁屏密码中的一种，建议前往 设置-生物识别和密码 进行添加');
    }
    .width(CommonConstants.FULL_PERCENT);
  }
}

@Extend(Text)
function textExtend() {
  .fontSize(16)
  .fontFamily('鸿蒙黑体')
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
  .fontColor($r('sys.color.black'));
}
