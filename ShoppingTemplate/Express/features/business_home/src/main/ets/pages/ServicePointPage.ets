import { IServicePoint } from 'lib_foundation'
import { StoreCard } from '../components/StoreCard'
import { ServicePointPageVM } from '../viewModels/ServicePointPageVM'

@Builder
export function ServicePointPageBuilder() {
  ServicePointPage()
}

@Entry
@ComponentV2
struct ServicePointPage {
  vm: ServicePointPageVM = ServicePointPageVM.instance

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.ic_warning_service'))
                .width(12)
                .height(12)
                .margin({ right: 4 })
              Text('下单后，前往任意柜机都可以投放哦～')
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor(Color.White)
            }
            .width('100%')
            .backgroundColor('rgba(10,89,247,0.8)')
            .borderRadius(8)
            .padding({
              left: 12,
              right: 12,
              top: 8,
              bottom: 8
            })
            .margin({ bottom: 12 })

            ForEach(this.vm.servicePointList, (servicePoint: IServicePoint) => {
              StoreCard({
                servicePoint: servicePoint,
                isSelected: this.vm.selectedServicePoint?.id === servicePoint.id
              })
                .onClick(() => {
                  this.vm.selectedServicePoint = servicePoint
                })
            }, (item: IServicePoint[]) => JSON.stringify(item))
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .height('calc(100% - 46vp)')

      Row() {
        Button('保存')
          .width('100%')
          .onClick(() => {
            this.vm.save()
          })
      }
      .width('100%')
      .height(76)
      .padding({ left: 28, right: 28 })
    }
    .backgroundColor('#F1F3F5')
    .title('自寄点')
  }
}