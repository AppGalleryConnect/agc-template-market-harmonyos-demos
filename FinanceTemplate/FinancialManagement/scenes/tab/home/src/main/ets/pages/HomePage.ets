import { Banner } from '../components/Banner'
import { MainService } from '../components/MainService'
import { FlexibleAccess } from '../components/FlexibleAccess'
import { FinancialNightMarket } from '../components/FinancialNightMarket'
import { FinancialInformation } from '../components/FinancialInformation'
import { HomePageVM } from '../viewModels/HomePageVM'
import { CommonNavTitle, CommonNoticeBoard } from 'componentlib'

@Builder
export function HomePageBuilder() {
  HomePage()
}

@Entry
@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance

  async aboutToAppear() {
    await this.vm.init()
  }

  build() {
    Column() {
      // 状态栏
      CommonNavTitle({ title: '理财' })
      Scroll() {
        Column() {
          Banner()
          // 服务列表
          MainService()
          // 公告栏
          CommonNoticeBoard({ noticeList: this.vm.noticeList })
          // 灵活取用
          FlexibleAccess()
          // 理财夜市
          FinancialNightMarket()
          // 理财资讯
          FinancialInformation()
        }
      }
      .scrollBar(BarState.Off)
      .height('calc(100% - 56vp)')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}