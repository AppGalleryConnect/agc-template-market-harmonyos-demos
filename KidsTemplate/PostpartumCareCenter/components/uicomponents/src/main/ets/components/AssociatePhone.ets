import { AccountUtil, FormatUtil } from '@ohos_agcit/postpartum_care_center_utils';
import { MainEntryVM } from '../../../../Index';
import { CustomContentDialog } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct AssociatePhone {
  @Param @Require phone: string;
  @Param needMask?: boolean = false;
  vm: MainEntryVM = MainEntryVM.instance;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: $r('app.string.unbind_account'),
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: 'rgba(0,0,0,0.60)',

          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          },
        },
        {
          value: $r('app.string.confirm'),
          fontColor: 'rgba(0,0,0,0.90)',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            AccountUtil.cancelAuthorization();
            this.disassociate();
          },
        },
      ],
    }),
  });

  @Builder
  buildContent(): void {
    Column() {
      Text($r('app.string.unbind_dialog_message')).fontSize(16).fontColor('rgba(0,0,0,0.90)').margin({ bottom: 20 });
    }
    .width('100%');
  }

  build() {
    Row() {
      Text(this.needMask ? FormatUtil.maskPhoneNumber(this.phone) : this.phone)
        .fontSize($r('app.string.font_size_12'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor('rgba(0,0,0,0.60)')
        .margin({ right: 4 });

      Row() {
        Image($r('app.media.ic_associate'))
          .width(12)
          .height(12)
          .margin({ right: 2 });
        if (this.phone === '') {
          Text($r('app.string.bind_account'))
            .fontSize($r('app.string.font_size_10'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.90)')
            .onClick(() => {
              this.vm.requestPhoneNumber();
            });
        } else {
          Text($r('app.string.unbind_account'))
            .fontSize($r('app.string.font_size_10'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.90)')
            .onClick(() => {
              this.dialogController.open();
            });
        }
      }
      .padding({
        left: 5,
        right: 5,
        top: 1,
        bottom: 1,
      })
      .borderRadius($r('app.string.border_radius_8'))
      .backgroundColor('rgba(0,0,0,0.05)');
    }
    .width('100%');
  }

  private disassociate() {
    AccountUtil.setUserInfo({isLogin: true, phone: '', nickname: '', avatar: '' });
  }
}