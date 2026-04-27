import { TravelPeopleModel } from 'common_travel_guide'

// 出行人信息
@ComponentV2
export struct TravelInformationPage {
  @Require @Param peopleList: TravelPeopleModel[]

  build() {
    Column() {
      Text('出行信息')
        .fontSize(16)
        .margin({ bottom: 24 })
        .fontColor('#333333')
      List({ space: 12 }) {
        ForEach(this.peopleList, (item: TravelPeopleModel, index: number) => {
          ListItem() {
            Column() {
              Text(item.name)
                .fontSize(16)
                .fontColor('#333333')
              Row() {
                Text('联系方式')
                  .fontSize(12)
                  .opacity(0.4)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(item.phone)
                  .fontSize(12)
                  .fontColor('#000000')
              }
              .margin({ top: 14, bottom: 4 })

              Row() {
                Text('证件信息')
                  .fontSize(12)
                  .opacity(0.4)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(item.maskedIdNumber)
                  .fontSize(12)
                  .fontColor('#000000')
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
        }, (item: TravelPeopleModel) => item.maskedIdNumber?.toString()
        )
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }
    .borderRadius(16)
    .width('100%')
    .backgroundColor($r('sys.color.icon_on_primary'))
    .padding(12)
    .margin({ top: 10 })
    .alignItems(HorizontalAlign.Start)
  }
}
