import { CommonConstants, PickerUtil, Title, rightArrow, StringUtil } from '@ohos_agcit/children_education_utils';
import { emitter } from '@kit.BasicServicesKit';
import { User } from '@ohos_agcit/children_education_datasource';

@Builder
export function PersonalInformationBuilder() {
  PersonalInformationPage();
}

@ComponentV2
export struct PersonalInformationPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

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

          Image(StringUtil.isEmpty(this.user.userAvatar) ? $r('app.media.avatar') : this.user.userAvatar)
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
                  let imageUri = uris[0] ? uris[0] : this.user.userAvatar;
                  if (StringUtil.isNotEmpty(imageUri)) {
                    let userAvatar: emitter.EventData = {
                      data: {
                        userAvatar: imageUri,
                      },
                    };
                    emitter.emit(CommonConstants.USER_INFO, userAvatar);
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
            text: this.user.userName,
          })
            .textAlign(TextAlign.End)
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor(Color.White)
            .selectionMenuHidden(true)
            .padding({ right: 6 })
            .onChange((value) => {
              let userName: emitter.EventData = {
                data: {
                  userName: value,
                },
              };
              emitter.emit(CommonConstants.USER_INFO, userName);
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
              let userName: emitter.EventData = {
                data: {
                  isLogin: false,
                  userName: '点击登录',
                  userAvatar: '',
                  phone: '',
                },
              };
              emitter.emit(CommonConstants.USER_INFO, userName);
              this.appPathStack.pop();
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
    }.title(Title($r('app.string.personalInformation')))
    .onReady(() => {

    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}