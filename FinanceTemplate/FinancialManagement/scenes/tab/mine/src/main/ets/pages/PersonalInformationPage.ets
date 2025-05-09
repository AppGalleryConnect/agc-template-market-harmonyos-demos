import { emitter } from '@kit.BasicServicesKit';
import { FormatUtil, PickerUtil, RouterMap } from 'commonlib';
import { PersonalInformationVM } from '../viewModels/PersonalInformationVM';
import { TipsDialog } from '@kit.ArkUI';

@Builder
export function PersonalInformationPageBuilder() {
  PersonalInformationPage();
}

@ComponentV2
export struct PersonalInformationPage {
  vm: PersonalInformationVM = PersonalInformationVM.instance
  dialogControllerLogout: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否确认退出登录?',
      primaryButton: {
        value: '取消',
        action: () => {

        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.logout()
        }
      },
    }),
  })

  aboutToAppear(): void {
    emitter.on('isLogin', (data) => {
      if (data.data?.isLogin) {
        this.vm.init()
      }
    });
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
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
                      let imageUri = uris[0] ? uris[0] : this.vm.userInfo?.avatar;
                      if (imageUri === this.vm.avatar) {
                        return
                      }
                      if (imageUri) {
                        this.vm.avatar = imageUri
                        this.vm.modify()
                      }
                    });
                });

              Row() {
                Image($r('app.media.icc_arrow_right'))
                  .width(12)
                  .height(24)
              }
              .margin({
                right: 8,
              });
            }
            .backgroundColor($r('sys.color.white'))
            .height(56)
            .borderRadius(16)
            .margin({ top: 16 });

            Column() {
              Row() {
                Row() {
                  Text('昵称')
                    .fontSize(16)
                    .layoutWeight(1)
                    .lineHeight(22)
                }
                .width('25%')

                Row() {
                  Row() {
                    Text(this.vm.nickname)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ right: 8 })
                  }
                  .flexGrow(1)
                  .justifyContent(FlexAlign.End)

                  Image($r('app.media.icc_arrow_right'))
                    .width(12)
                    .height(24)
                }
                .width('75%')
                .justifyContent(FlexAlign.End)
              }
              .padding({ top: 13, bottom: 13 })
              .onClick(() => {
                FormatUtil.jumpToNext(RouterMap.Edit_Name_Page)
              })

              Divider().color($r('sys.color.comp_divider'))

              Row() {
                Text('手机号')
                  .fontSize(16)
                  .layoutWeight(1)
                  .lineHeight(22)
                Row() {
                  Text(FormatUtil.encryptPhoneNo(this.vm.cellphone ?? ''))
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ right: 8 })
                  Image($r('app.media.icc_arrow_right'))
                    .width(12)
                    .height(24)
                }
              }
              .padding({ top: 13, bottom: 13 })
              .onClick(() => {
                FormatUtil.jumpToNext(RouterMap.Edit_Phone_Page)
              })
            }
            .padding({ left: 12, right: 8 })
            .backgroundColor($r('sys.color.white'))
            .borderRadius(16);
          }
          .margin({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
      }
      .height('calc(100% - 40vp)')

      Row() {
        Button('退出登录')
          .fontColor('#E4480C')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width('100%')
          .borderRadius(20)
          .onClick(() => {
            this.dialogControllerLogout.open()
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('个人信息')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}