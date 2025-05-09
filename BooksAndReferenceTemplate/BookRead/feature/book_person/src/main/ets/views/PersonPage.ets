import { Constants, NavHeaderBar, UserInfo } from 'common';
import { CenterToolCard } from '../comp/CenterToolCard';
import { UserMsgCard } from '../comp/UserMsgCard';

@ComponentV2
export struct PersonPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.mask'))
          .width(Constants.FULL_SIZE)
          .height(274)
        Column() {
          NavHeaderBar({
            title: $r('app.string.person'),
            hasBackButton: false,
            hasBgColor: false,
            isMainPage: true,
          })
          Scroll() {
            Column() {
              UserMsgCard()
                .margin({ top: 10, bottom: 10 });
              CenterToolCard();
            }
          }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top);

        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          left: 12,
          right: 12,
        })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}