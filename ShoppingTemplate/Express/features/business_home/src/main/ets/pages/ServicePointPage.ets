import { BottomBtn, CommonNoticeBar, CommonTitle, IServicePoint } from 'lib_foundation'
import { StoreCard } from '../components/StoreCard'
import { ServicePointPageVM } from '../viewModels/ServicePointPageVM'

@Builder
export function ServicePointPageBuilder() {
  ServicePointPage()
}

@Entry
@ComponentV2
struct ServicePointPage {
  vm: ServicePointPageVM = new ServicePointPageVM();

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '服务点查询',
      })
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            CommonNoticeBar({
              text: '下单后，前往任意柜机都可以投放哦～'
            })

            List({ space: 12 }) {
              ForEach(this.vm.servicePointList, (servicePoint: IServicePoint) => {
                ListItem() {
                  StoreCard({
                    servicePoint: servicePoint,
                    isSelected: this.vm.selectedServicePoint?.id === servicePoint.id
                  })
                }
                .onClick(() => {
                  this.vm.selectedServicePoint = servicePoint
                })
              }, (item: IServicePoint) => JSON.stringify(item))
            }
            .width('100%')
            .layoutWeight(1)
            .lanes(this.vm.listLanes, 12)
          }
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: 8,
          })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .align(Alignment.Top)
      }
      .layoutWeight(1)

      BottomBtn({
        text: '保存',
        paddingSize: { left: 28, right: 28, bottom: this.vm.windowModel.windowBottomPadding },
        onAction: () => {
          this.vm.save()
        }
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}