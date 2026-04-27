import { LoginAvatarCard } from '../components/LoginAvatarCard';
import { MainService } from '../components/MainService';
import { Setting } from '../components/Setting';
import { Title } from '../components/Title';
import { Welfare } from '../components/Welfare';
import { MinePageVM } from '../viewModels/MinePageVM';

@Entry
@ComponentV2
export struct MinePage {
  vm: MinePageVM = MinePageVM.instance

  build() {
    NavDestination() {
      Column() {
        Column() {
          Title()
          Scroll() {
            Column() {
              LoginAvatarCard()
              MainService()
              Welfare()
              Setting()
            }
            .padding({ left: 16, right: 16 })
          }
          .scrollBar(BarState.Off)
        }
      }
    }
    .backgroundColor('#F1F3F5')
  }
}