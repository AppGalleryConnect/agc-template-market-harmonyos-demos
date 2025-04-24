import { CommonTab } from '../components/CommonTab'
import { Constants, NavHeaderBar } from 'common/Index'

@Component
export struct OrderListPage {
  @State title: Resource = $r('app.string.order_list')

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ hasBackButton: false, title: this.title })
        CommonTab().layoutWeight(1)
      }
      .height(Constants.FULL_SIZE)
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}