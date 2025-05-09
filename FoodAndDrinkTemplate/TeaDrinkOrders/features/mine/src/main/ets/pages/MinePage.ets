import { Constants, NavHeaderBar } from 'common/Index';
import { UserInfoComp } from '../components/UserInfoComp';
import { MenuComp } from '../components/MenuComp';

@Builder
export function MinePageBuilder() {
  MinePage()
}

@ComponentV2
struct MinePage {
  @Consumer('pageStack') pageStack?: NavPathStack

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.bg_mine')).width(Constants.FULL_SIZE)
        Column() {
          NavHeaderBar({ title: $r('app.string.tab_mine'), hasBackButton: false, hasBgColor: false })
          Column({ space: 16 }) {
            UserInfoComp().margin({ top: 10 })
            MenuComp()
          }
          .width(Constants.FULL_SIZE)
          .layoutWeight(1)
          .padding(16)
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor('#F2F1F3F5')
    }.hideTitleBar(true)
  }
}

