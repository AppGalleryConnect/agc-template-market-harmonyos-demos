import { PersonalInformationVM } from '../viewModels/PersonalInformationVM';
import { CommonUtil, PickerUtil, RouterMap } from 'module_base';
import { RouterModule } from 'lib_foundation';

@Builder
export function PersonalInformationPageBuilder() {
  PersonalInformationPage();
}

@ComponentV2
export struct PersonalInformationPage {
  vm: PersonalInformationVM = PersonalInformationVM.instance

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Row() {
            Text('头像')
              .fontSize(16)
              .layoutWeight(1)
              .lineHeight(22)
              .padding({
                left: 12,
              });

            Image(this.vm.avatar ? this.vm.avatar : $r('app.media.ic_avatar'))
              .width(40)
              .height(40)
              .borderRadius(100)
              .margin({
                right: 6,
              })
              .onClick(() => {
                PickerUtil.selectPhoto({
                  maxSelectNumber: 1,
                })
                  .then((uris) => {
                    let imageUri = uris[0] ? uris[0] : this.vm.userInfoModel?.avatar;
                    if (imageUri === this.vm.avatar) {
                      return
                    }
                    if (imageUri) {
                      this.vm.avatar = imageUri
                      this.vm.modify()
                    }
                  });
              });
          }
          .backgroundColor($r('sys.color.white'))
          .height(56)
          .borderRadius(16)
          .margin({ top: 16 });

          Column() {
            Row() {
              Text('昵称')
                .fontSize(16)
                .layoutWeight(1)
                .lineHeight(22)

              Row() {
                Text(this.vm.userInfoModel.nickname)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                Image($r('app.media.ic_arrow_right')).rightIconStyle();
              }
            }
            .formContainerStyle()
            .onClick(() => {
              RouterModule.push({ url: RouterMap.Edit_Name_Page })
            })

            Divider().color($r('sys.color.comp_divider'))

            Row() {
              Text('手机号')
                .fontSize(16)
                .layoutWeight(1)
                .lineHeight(22)
              Row() {
                Text(CommonUtil.encryptPhoneNo(this.vm.userInfoModel.cellphone ?? ''))
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                Image($r('app.media.ic_arrow_right')).rightIconStyle();
              }
            }
            .formContainerStyle()
            .onClick(() => {
              RouterModule.push({ url: RouterMap.Edit_Phone_Page })
            })
          }
          .backgroundColor($r('sys.color.white'))
          .borderRadius(16);
        }
        .margin({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .title('个人信息')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}


@Extend(Row)
function formContainerStyle() {
  .width('100%')
  .alignItems(VerticalAlign.Center)
  .borderRadius(16)
  .padding({
    top: 12,
    bottom: 12,
    left: 12,
    right: 4,
  })
}

@Extend(Image)
function rightIconStyle() {
  .width(24)
  .height(24)
  .margin({ left: 4 })
}