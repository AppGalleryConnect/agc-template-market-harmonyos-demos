import { CommonConstants, PickerUtil, StringUtil, AccountUtil } from '@ohos_agcit/car_beauty_care_commonlib';
import { rightArrow } from './FeedTitle';


@Builder
export function UserInfoBuilder() {
  UserInfoPage();
}

@ComponentV2
export struct UserInfoPage {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = AppStorage.get('topRectHeight') || 0;

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

          Image(AccountUtil.getUserInfo().avatar)
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
                  let imageUri = uris[0] ? uris[0] : AccountUtil.getUserInfo().avatar;
                  AccountUtil.getUserInfo().avatar = imageUri;
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
            text: AccountUtil.getUserInfo().nickname,
          })
            .textAlign(TextAlign.End)
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor(Color.White)
            .selectionMenuHidden(true)
            .padding({ right: 6 })
            .onChange((value) => {
              AccountUtil.getUserInfo().nickname = value;
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
              AccountUtil.loginOut();
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
    }
    .title('个人信息')
    .margin({ top: px2vp(this.topRectHeight) })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}