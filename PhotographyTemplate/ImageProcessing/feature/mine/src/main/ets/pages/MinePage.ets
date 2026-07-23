import { BaseTitle, CommonConstants } from 'commonlib';
import { SettingAndHelpCard } from '../components/SettingAndHelpCard';
import { UserCard } from '../components/UserCard';
import { MinePageVM } from '../viewmodels/MinePageVM';

@ComponentV2
export struct MinePage {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Column() {
      BaseTitle({
        title: '我的',
      })
      Scroll() {
        Column({ space: 12 }) {
          UserCard()
          SettingAndHelpCard()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function MinePageBuilder() {
  MinePage();
}