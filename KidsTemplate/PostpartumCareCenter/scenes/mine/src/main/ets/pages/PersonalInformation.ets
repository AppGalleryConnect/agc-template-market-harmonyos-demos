import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { PickerUtil } from '@ohos_agcit/postpartum_care_center_utils';

@Builder
export function PersonalInformationBuilder() {
  PersonalInformationPage();
}

@ComponentV2
export struct PersonalInformationPage {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Row() {
          Text($r('app.string.avatar'))
            .fontSize(16)
            .layoutWeight(1)
            .lineHeight(22)
            .padding({
              left: 12,
            });

          Image(this.vm.userInfo.avatar === '' ? $r('app.media.ic_user_default') : this.vm.userInfo.avatar)
            .width(45)
            .height(45)
            .borderRadius(100)
            .margin({
              right: 6,
            })
            .onClick(() => {
              PickerUtil.selectPhoto({
                maxSelectNumber: 1,
              })
                .then((uris) => {
                   if (uris){
                     this.vm.userInfo.avatar = uris[0];
                   }
                });
            });

          Row() {
            rightArrow();
          }
          .margin({
            right: 8,
          });
        }
        .backgroundColor($r('sys.color.white'))
        .height(56)
        .borderRadius(16)
        .margin({ top: 16 });

        Row() {
          Text($r('app.string.nickName'))
            .fontSize(16)
            .layoutWeight(1)
            .lineHeight(22)
            .padding({ left: 12 });
          TextInput({
            text: this.vm.userInfo.nickname,
          })
            .textAlign(TextAlign.End)
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor(Color.White)
            .selectionMenuHidden(true)
            .padding({ right: 6 })
            .onChange((value) => {
              this.vm.userInfo.nickname = value;
            });
          Row() {
            rightArrow();
          }
          .margin({
            right: 8,
          });
        }
        .backgroundColor($r('sys.color.white'))
        .height(56)
        .borderRadius(16);

        Row() {
          Button($r('app.string.log_out'))
            .fontColor($r('sys.color.black'))
            .fontSize(16)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .width('100%')
            .onClick(() => {
              this.vm.userInfo.isLogin = false;
              this.vm.userInfo.avatar = '';
              this.vm.userInfo.nickname = '';
              this.vm.userInfo.phone = '';

              this.vm.navStack.pop();
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
    }
    .title('个人信息')
    .onReady(() => {

    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    });
  }
}

@Builder
export function rightArrow (){
  SymbolGlyph($r('sys.symbol.chevron_right'))
    .fontColor([$r('sys.color.ohos_id_color_foreground')])
    .opacity(0.3)
    .fontSize('24vp');
}
