import { AccountUtil, CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { rightArrow } from '../../components/RightArrow';
import { buffer } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CustomContentDialog } from '@kit.ArkUI';

@Builder
export function SettingBuilder() {
  SettingPage();
}
const PRIVACY_URL = 'privacy_url';

@Entry
@ComponentV2
export struct SettingPage {
  vm: CommonModel = CommonModel.instance;

  logTag: string = 'AboutPage';
  domainId: number = 0x0000;

  // 退出登录对话框
  logOutDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '账号退出登录',
      contentBuilder: () => {
        this.logOutContent();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.logOutDialogController.close();
          },
        },
        {
          value: $r('app.string.confirm'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            AccountUtil.loginOut();
            this.vm.navStack.pop();
          },
        },
      ],
    }),
  });

  // 退出登陆
  @Builder
  logOutContent() {
    Column() {
      Row() {
        Text('请确认是否退出当前账户？')
          .fontSize(14);
      };
    }
    .width('100%')
    .borderRadius(16)
    .margin({
      left: '4%',
      right: '4%',
      bottom: 5,
    });
  }

  build() {
    NavDestination() {
      Column({space: 17}){
        Row() {
          Text('隐私协议')
            .textExtend();
          Blank();
          rightArrow()
        }
        .borderRadius(16)
        .minHeight(46)
        .backgroundColor($r('app.color.comp_background_list_card'))
        .width(CommonConstants.FULL_PERCENT)
        .onClick(() => {
          const params: Record<string, Object> = { 'protocolUrl': this.getProtocolUrl(PRIVACY_URL) };
          this.vm.navStack.pushPathByName('PrivacyAgreement', params);
        })
        .padding({
          left: 12,
          right: 12
        })

        Row() {
          Text('保密设置')
            .textExtend();
          Blank();
          rightArrow()
        }
        .borderRadius(16)
        .minHeight(46)
        .backgroundColor($r('app.color.comp_background_list_card'))
        .width(CommonConstants.FULL_PERCENT)
        .onClick(() => {
          this.vm.navStack.pushPathByName('SecretSetting', undefined);
        })
        .padding({
          left: 12,
          right: 12
        })

        Row() {
          Text($r('app.string.log_out'))
            .textExtend();
          Blank();
          rightArrow()
        }
        .borderRadius(16)
        .minHeight(46)
        .backgroundColor($r('app.color.comp_background_list_card'))
        .width(CommonConstants.FULL_PERCENT)
        .onClick(() => {
          this.logOutDialogController.open();
        })
        .padding({
          left: 12,
          right: 12
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        top: 10,
        left: '4%',
        right: '4%'
      })


    }
    .backgroundColor('#F1F3F5')
    .title('设置')
  }

  getProtocolUrl(privacyUrl: string): string {
    try {
      // Read files from /AppScope/resources/rawfile.
      const value: Uint8Array = (this.getUIContext().getHostContext() as Context).resourceManager.getRawFileContentSync('data.json');
      // Return the link to the HUAWEI ID User Authentication Agreement.
      return JSON.parse(buffer.from(value.buffer).toString())[privacyUrl] as string;
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `getProtocolUrl Error. errCode is ${error.code}, errMessage is ${error.message}`);
      return '';
    }
  }
}

@Extend(Text)
function textExtend() {
  .fontSize(16)
  .fontFamily('鸿蒙黑体')
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
  .fontColor($r('app.color.font_secondary'));
}
