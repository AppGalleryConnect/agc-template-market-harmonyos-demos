import { FormatUtil, RouterMap } from 'commonlib'
import { IMainService } from '../types'
import { HomePageVM } from '../viewModels/HomePageVM'

@ComponentV2
export struct MainService {
  vm: HomePageVM = HomePageVM.instance

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.vm.mainServiceList, (item: IMainService) => {
          Column() {
            Row() {
              Image(item.image)
                .width(24)
                .height(24)
            }

            Text(item.name)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .width(60)
          .height(48)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRODUCT_LIST, { type: item.type, index: item.index })
          })
        }, (item: IMainService[]) => JSON.stringify(item))
      }
    }
    .width('100%')
    .height(80)
    .alignItems(VerticalAlign.Center)
  }
}