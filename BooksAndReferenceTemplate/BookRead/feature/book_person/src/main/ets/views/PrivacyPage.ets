import { BookApi, Constants, GetUserInfoRsp, NavHeaderBar, TCRouter, UserInfo } from 'common';
import { AvatarIcon, SelectAvatarCard } from '../comp/SelectAvatarCard';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct PrivacyPage {
  @Local isPrivacy: boolean = false;
  scroller: Scroller = new Scroller();
  async aboutToAppear(): Promise<void> {
    const p = TCRouter.getParams<boolean>(Constants.PRIVACY_ROUTE);
    if (p) {
      this.isPrivacy = true;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: this.isPrivacy ? $r('app.string.privacy') : $r('app.string.user_agreement'),
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: true,
          })

          Scroll(this.scroller) {
            Column() {
              Text(this.isPrivacy ? $r('app.string.privacy_content') : $r('app.string.user_agreement_content'))
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .margin({ top: 10 })
            .width(Constants.FULL_SIZE)
            .padding(12)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(16)
          }
          .width(Constants.FULL_SIZE)
          .padding({
            left: 12,
            right: 12,
          })
          .margin({bottom: 100})
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)
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