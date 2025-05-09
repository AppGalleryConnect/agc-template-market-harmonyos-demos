import { ETickets, eTicketsTotal } from 'commonlib'
import { MainEntryVM } from 'commonlib';
import { BaseTitle } from 'componentlib';


@Builder
export function BuyTicketsPageBuilder(name: string, param: Object){
  BuyTicketsPage()
}

@ComponentV2
export struct BuyTicketsPage{
  vm: MainEntryVM = MainEntryVM.instance;

  @Builder
  BuyTicketsBuilder() {
    Text('优惠购票')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.BuyTicketsBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Scroll(){
        Column(){
          Column(){
            Row(){
              Text('电子日票')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .margin({left:5})
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .margin({left:10,top:20})
            Row(){
              Image($r('app.media.orangePoint'))
                .width(8)
                .height(8)
                .margin({left:10,top:4,right:2})
              Text('有效期内不限次数，不限里程，支持扫码过闸，无需取票')
                .fontColor($r('app.color.font_color_gray'))
                .fontSize(10)
                .margin({top:4})
            }
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .justifyContent(FlexAlign.Start)
            ForEach(eTicketsTotal,(tickets:ETickets,index:number)=>{

              Column() {
                Row() {
                  Image(tickets.image)
                    .width(80)
                    .height(105)
                    .margin({ left: 13 })
                    .borderRadius(8)
                  Column() {
                    Row() {
                      Text(tickets.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                    }
                    .margin({ top: 3 })
                    .width(70)
                    .height(19)

                    Row() {
                      this.myContent(tickets.content1, 0, 1, $r('app.color.background_color_white'))
                      this.myContent(tickets.content2, 4, 1, $r('app.color.background_color_white'))
                      this.myContent(tickets.content3, 4, 1, $r('app.color.background_color_white'))
                    }
                    .margin({ top: 4 })

                    Row() {
                      this.myContent(tickets.content4, 0, 0, $r('app.color.background_color_orange'))
                      this.myContent(tickets.content5, 4, 0, $r('app.color.background_color_orange'))
                    }
                    .margin({ top: 4 })

                    Row() {
                      Row() {
                        Text('￥' + tickets.price)
                          .fontColor($r('app.color.orange'))
                          .fontSize(20)
                          .fontWeight(FontWeight.Bold)
                      }
                      .width(61)
                      .height(27)
                      .justifyContent(FlexAlign.Start)

                      Row() {
                        Text('去购买')
                          .margin(5)
                          .fontColor($r('app.color.background_color_white'))
                      }
                      .justifyContent(FlexAlign.Center)
                      .width(72)
                      .height(28)
                      .borderRadius(8)
                      .margin({ left: 78 })
                      .backgroundColor($r('app.color.orange'))
                      .onClick(() => {
                        this.vm.navStack.pushPath({ name: 'TicketsDetailPage', param: tickets.days })
                      })
                    }
                    .margin({ top: 12 })
                    .justifyContent(FlexAlign.Start)
                  }
                  .width('60%')
                  .margin({ left: 12 })
                  .alignItems(HorizontalAlign.Start)
                }
                .alignItems(VerticalAlign.Top)
                .width('100%')
                .margin({ bottom: 16, top: 16 })
                if (index !== eTicketsTotal.length-1) {
                  Divider()
                    .margin({top:5})
                    .width(304)
                }
              }
            }, (item: string, index: number) => item + index)
          }
          .borderRadius(16)
          .margin({top:20})
          .backgroundColor($r('app.color.background_color_white'))
        }
        .width(328)
      }
      .align(Alignment.Top)
      .height('100%')
      .width('100%')
    }
    .backgroundColor($r('app.color.stationsInformation_background_color'))
    .hideTitleBar(true)
    .backgroundImageSize({ width: '100%', height: '100%' })
    .height('100%')
    .width('100%')
  }

  @Builder
  myContent(content:Resource,margin:number,borderWidth:number,backgroundColor:Resource){
    Row() {
      Text(content)
        .height(14)
        .width(40)
        .fontSize(10)
        .fontColor($r('app.color.orange'))
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderColor($r('app.color.orange'))
    .width(48)
    .height(16)
    .borderWidth(borderWidth)
    .borderRadius(16)
    .margin({left:margin})
    .backgroundColor(backgroundColor)
  }
}