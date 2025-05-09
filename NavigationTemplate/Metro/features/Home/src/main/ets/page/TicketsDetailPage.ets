import { ETickets, eTicketsTotal } from 'commonlib'
import { MainEntryVM } from 'commonlib';
import { CounterComponent, CounterType, LengthMetrics } from '@kit.ArkUI';
import { BaseTitle } from 'componentlib';


@Builder
export function TicketsDetailPageBuilder(name: string, param: Object){
  TicketsDetailPage()
}

@Component
export struct TicketsDetailPage{
  @State value:number = 1
  vm: MainEntryVM = MainEntryVM.instance;
  lastPageIndex:number = MainEntryVM.instance.navStack.size()-1
  ticketDays:number = parseInt(JSON.stringify(MainEntryVM.instance.navStack.getParamByIndex(this.lastPageIndex)))
  ticket:ETickets = eTicketsTotal[0]
  @State totalPrice:number = 0
  aboutToAppear(): void {
    for (let index = 0; index < eTicketsTotal.length; index++) {
      if (this.ticketDays===eTicketsTotal[index].days) {
        this.ticket = eTicketsTotal[index]
        this.totalPrice = this.value*parseInt(eTicketsTotal[index].price)
        return
      }
    }
  }

  @Builder
  TicketsDetailBuilder() {
    Text('优惠购票')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination(){
      BaseTitle({
        customTitle: () => {
          this.TicketsDetailBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Column(){
        Column() {
          Row() {
            Image(this.ticket.image)
              .width(80)
              .height(88)
              .margin(12)
              .borderRadius(8)
            Column() {
              Text(this.ticket.title)
                .margin({ top: 12 })
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
              Text('使用次数：不限')
                .fontColor($r('app.color.font_color_gray'))
                .fontSize((10))
                .margin({top:8})
              Text('有效时间：首次扫码后' + this.ticket.days + '天')
                .fontColor($r('app.color.font_color_gray'))
                .fontSize((10))
                .margin({top:4})
            }
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(VerticalAlign.Top)
          .width('90%')
          .backgroundColor(Color.White)
          .margin({ top: 10 })
          .borderRadius(16)

          Column() {
            Row() {
              Text('票单价').fontColor(Color.Gray)
              Text('￥' + this.ticket.price).fontWeight(FontWeight.Bold)
            }
            .margin(12)
            .justifyContent(FlexAlign.SpaceBetween)
            .width('90%')

            Divider().width('90%')
            Row() {
              Text('票张数').fontColor(Color.Gray)
              CounterComponent({
                options: {
                  type: CounterType.LIST,
                  numberOptions: {
                    min: 1,
                    value: this.value,
                    onChange:(date:number)=>{
                      this.totalPrice = date*parseInt(this.ticket.price)
                    }
                  },
                },
              })
                .margin({right:30})
            }
            .margin(10)
            .width('90%')

            Divider().width('90%')
            Row() {
              Text('实付金额').fontColor(Color.Gray)
              Text('￥' + this.totalPrice)
                .fontWeight(FontWeight.Bold)
                .fontSize(20)
                .fontColor($r('app.color.orange'))
            }
            .margin(10)
            .justifyContent(FlexAlign.SpaceBetween)
            .width('90%')
          }
          .borderRadius(16)
          .margin({ top: 10 })
          .width('90%')
          .backgroundColor(Color.White)

          Row() {
            Column() {
              Text('购买须知').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 5 })
              Text($r('app.string.purchase_notes'))
                .fontSize(12)
                .fontColor($r('app.color.grey'))
                .lineSpacing(LengthMetrics.px(15))
            }
            .margin(10)
            .alignItems(HorizontalAlign.Start)
          }
          .borderRadius(16)
          .margin({ top: 10 })
          .width('90%')
          .backgroundColor(Color.White)
        }
        Column(){
          Row() {
            Text('确认支付').fontColor(Color.White)
          }
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .height(40)
          .width('90%')
          .backgroundColor($r('app.color.orange'))
          .onClick(()=>{
            this.vm.navStack.pushPath({name:'CheckOutPage',param:this.totalPrice})
          })
        }
        .margin({bottom:30})
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .width('100%')
    }
    .backgroundColor('#fff1ecec')
    .hideTitleBar(true)
    .backgroundImageSize({ width: '100%', height: '100%' })
    .height('100%')
  }
}