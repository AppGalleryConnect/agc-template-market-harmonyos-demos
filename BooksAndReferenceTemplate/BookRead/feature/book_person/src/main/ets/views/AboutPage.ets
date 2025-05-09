import { BookApi, Constants, GetUserInfoRsp, NavHeaderBar, TCRouter, UserInfo } from 'common';
import { AvatarIcon, SelectAvatarCard } from '../comp/SelectAvatarCard';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct AboutPage {
  @Local userInfo: UserInfo | undefined = undefined;
  @Local avatarIcon: AvatarIcon | undefined = undefined;
  @Local isSelectCalendar: boolean = false;
  @Local isModifyNickName: boolean = false;

  async aboutToAppear(): Promise<void> {

  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: $r('app.string.about'),
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: true,
          })
          Column() {
            Column() {
              Row() {
                Row() {
                  Text($r('app.string.privacy'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ left: 12 })
                }

                Image($r('app.media.arrow_right'))
                  .width(16)
                  .height(16)
                  .margin({ right: 12 })
              }
              .height(48)
              .width(Constants.FULL_SIZE)
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                TCRouter.push(Constants.PRIVACY_ROUTE, true);
              })
            }
            .margin({ top: 10 })
            .width(Constants.FULL_SIZE)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(16)

            Column() {
              Row() {
                Row() {
                  Text($r('app.string.user_agreement'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ left: 12 })
                }

                Image($r('app.media.arrow_right'))
                  .width(16)
                  .height(16)
                  .margin({ right: 12 })
              }
              .height(48)
              .width(Constants.FULL_SIZE)
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                TCRouter.push(Constants.PRIVACY_ROUTE, false);
              })
            }
            .margin({ top: 10 })
            .width(Constants.FULL_SIZE)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(16)
          }
          .alignItems(HorizontalAlign.Start)
          .width(Constants.FULL_SIZE)
          .padding({
            left: 12,
            right: 12,
          })
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}