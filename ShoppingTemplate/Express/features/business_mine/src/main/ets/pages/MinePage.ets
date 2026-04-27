import { CommonTitle } from 'lib_foundation';
import { CommonServiceView } from '../components/CommonServiceView';
import { LoginAvatarCard } from '../components/LoginAvatarCard';
import { MainService } from '../components/MainService';
import { MinePageVM } from '../viewModels/MinePageVM';

@ComponentV2
export struct MinePage {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Column() {
      CommonTitle({
        title: '我的',
        showBackBtn: false,
        fontSize: 26
      })
      Scroll() {
        Column({ space: 12 }) {
          LoginAvatarCard()
          MainService()
          CommonServiceView()
        }
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
        })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}