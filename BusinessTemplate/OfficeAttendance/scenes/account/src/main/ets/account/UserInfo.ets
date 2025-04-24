import { PickerUtil, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { CustomContentDialog, router } from '@kit.ArkUI';
import { RequestProxy } from '../api/RequestProxy';
import { BaseResponse } from '@ohos_agcit/office_attendance_network';

@Builder
export function UserInfoBuilder() {
  UserInfo();
}

@ComponentV2
export struct UserInfo {
  @Local userName: ResourceStr = $r('app.string.account_name');
  @Local imageUri: string | undefined = undefined;
  @Param callback: () => void = () => {
  };

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: $r('app.string.unbind_dialog_title'),
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: $r('app.color.button_text_color'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          }
        },
        {
          value: $r('app.string.confirm'),
          fontColor: $r('app.color.button_text_color'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            RequestProxy.logout().then((resp: BaseResponse<undefined>) => {
              RouterModule.pop();
              router.replaceUrl({ url: 'pages/Login' })
            });
          }
        }
      ],
    }),
    alignment: DialogAlignment.Top,
    offset: { dx: 0, dy: 216 },
    width: 328,
    height: 164,
  });
  build() {
    NavDestination(){
      Column({ space: 16 }) {
        Row() {
          Text($r('app.string.avatar'))
            .fontSize(16)
            .fontColor($r('app.string.black_90'))
            .layoutWeight(1)
            .fontWeight(FontWeight.Medium)
            .lineHeight(22)
            .padding({
              left: 12,
            });

          Image(this.imageUri === undefined ? $r('app.media.ic_user_default') : this.imageUri)
            .width(40)
            .height(40)
            .borderRadius(100)
            .margin({
              right: 4,
            })
            .onClick(() => {
              PickerUtil.selectPhoto({
                maxSelectNumber: 1,
              })
                .then((uris) => {
                  this.imageUri = uris[0] ? uris[0] : this.imageUri;
                });
            });

          Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
        }
        .backgroundColor($r('sys.color.white'))
        .height(56)
        .borderRadius(16)
        .margin({ top: 16 });

        Row() {
          Text($r('app.string.nickName'))
            .fontSize(16)
            .layoutWeight(1)
            .fontWeight(FontWeight.Medium)
            .lineHeight(22)
            .padding({ left: 12 });
          TextInput({
            text: this.userName,
          })
            .textAlign(TextAlign.End)
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor(Color.White)
            .fontColor($r('app.string.black_60'))
            .selectionMenuHidden(true)
            .padding({ right: 6 });
          Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
        }
        .backgroundColor($r('sys.color.white'))
        .height(56)
        .borderRadius(16);

        Row() {
          Button($r('app.string.log_out'))
            .fontColor($r('app.color.button_text_color'))
            .fontSize(16)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .width('100%')
            .onClick(() => {
              this.dialogController.open();
            });
        }.margin({
          top: 500,
        });
      }
      .backgroundColor('#F1F3F5')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
      });
    }.title({ builder: this.titleBuilder(), height: 56 })
    .padding({ top: 36, bottom: 28 }).backgroundColor($r('app.color.about_background'))
  }


  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.user_info'))
        .fontWeight(FontWeight.Bold)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize(24)
        .margin({ left: 16, top: 36 })
        .height(56)
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
  }

  @Builder
  buildContent(): void {
    Column() {
      Text($r('app.string.unbind_dialog_message')).fontSize(16).fontColor('rgba(0,0,0,0.90)').margin({ bottom: 20 })
    }
    .width('100%')
  }
}