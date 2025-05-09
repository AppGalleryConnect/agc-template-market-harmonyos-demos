import { MainEntryVM, newsInformationInterface } from 'commonlib'

@Builder
export function newsComponent(item: newsInformationInterface,vm: MainEntryVM) {

  Row({space: 8}) {
    Image(item.image)
      .width('30%')
      .borderRadius(8)
    Column() {
      Text(item.title)
        .fontSize(14)
        .fontColor($r('app.color.stationsInformation_default'))
        .maxLines(1)
        .textOverflow({overflow: TextOverflow.Ellipsis})
        .fontWeight('medium')
      Text(item.time)
        .fontSize(12)
        .fontColor($r('app.color.grey'))
        .margin({ top: 19 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
  .onClick(()=>{
    vm.navStack.pushPath({ name: 'newsDetailPage', param:item })
  })
  .width('100%')
}