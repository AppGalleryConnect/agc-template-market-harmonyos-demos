import { CommonNavTitle, CommonNoticeBoard } from 'componentlib';
import { AmountCard } from '../components/AmountCard';
import { Banner } from '../components/Banner';
import { PositionList } from '../components/PositionList';
import { LoginAvatarCard } from '../components/LoginAvatarCard'
import { MinePageVM } from '../viewModels/MinePageVM';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function MinePageBuilder() {
  MinePage()
}

@Entry
@Component
struct MinePage {
  vm: MinePageVM = MinePageVM.instance

  aboutToAppear(): void {
    emitter.on('isLogin', (data) => {
      if (data.data?.isLogin) {
        this.vm.reFresh()
      } else {
        this.vm.logout()
      }
    });
    this.vm.init()
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Banner()
        Column() {
          CommonNavTitle({ title: '我的' })
          Scroll() {
            Column() {
              LoginAvatarCard()
              AmountCard()
              CommonNoticeBoard({ noticeList: this.vm.noticeList })
              PositionList()
            }
          }
          .scrollBar(BarState.Off)
          .height('calc(100% - 56vp)')
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
