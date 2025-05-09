import { availableTickets, MainEntryVM, MyTickets, notAvailableTickets, waitingForPayTickets } from 'commonlib'
import { BaseTitle } from 'componentlib';
import { TabBarView } from '../components/tabBarBuilder'
import { TabListItem, TICKET_WALLET } from '../constants/Constants'


@Builder
export function MyTicketsPageBuilder(name: string, param: Object) {
  MyTicketsPage()
}

@Component
export struct MyTicketsPage {
  vm: MainEntryVM = MainEntryVM.instance;
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  textTimerController: TextTimerController = new TextTimerController()

  @Builder
  MyTicketsBuilder() {
    Text('票卡包')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.MyTicketsBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Column() {
        Row() {
          ForEach(TICKET_WALLET, (item: TabListItem, index: number) => {
            TabBarView({
              data: item,
              currentIndex: this.currentIndex,
              index: index,
              onClickTab: (index) => {
                this.currentIndex = index
              }
            })
          }, (item: string, index: number) => item + index)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')

        Tabs({
          barPosition: BarPosition.Start,
          index: this.currentIndex,
          controller: this.controller
        }) {
          TabContent() {
            this.showTickets(availableTickets,0)
          }
          .align(Alignment.Top)
          TabContent() {
            this.showTickets(waitingForPayTickets,1)
          }
          .align(Alignment.Top)
          TabContent() {
            this.showTickets(notAvailableTickets,2)
          }
          .align(Alignment.Top)
        }
        .height(315)
        .barHeight(0)
        .animationDuration(0)
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .margin({ top: 25 })
      }
      .margin({ top: 22 })
      .height('100%')
      .width(328)
    }
    .backgroundColor($r('app.color.background_color'))
    .height('100%')
    .hideTitleBar(true)
  }

  @Builder
  showTickets(ticketsList:MyTickets[],state:number){
    Column(){
      ForEach(ticketsList,(item:MyTickets,index:number)=>{
        Column(){
          Row(){
            Image(item.image)
              .width(80)
              .height(105)
            Column(){
              Text(item.title)
                .fontColor($r('app.color.tab_font_color'))
                .margin({top:7})
              Text('可用次数：不限')
                .fontSize(10)
                .margin({top:8})
                .fontColor($r('app.color.font_color_gray'))
              Text('有效期至：首次扫码后'+item.totalTime+'小时')
                .fontSize(10)
                .margin({top:4})
                .fontColor($r('app.color.font_color_gray'))
              Row(){
                Row() {
                  Image(state !==2 ?$r('app.media.x'):$r('app.media.x2'))
                    .width(12)
                    .height(12)
                    .margin({bottom:4})
                  Text('' + item.totalCount)
                    .fontSize(20)
                    .fontColor(state !== 2 ? $r('app.color.highlight_font_color') : $r('app.color.tab_font_color'))
                }
                .alignItems(VerticalAlign.Bottom)
                if (state === 0) {
                  this.rowBuilder('去使用',$r('app.color.highlight_font_color'),$r('app.color.background_color_white'),0,item)
                }else if (state === 1){
                  Column() {
                    this.rowBuilder('去支付', $r('app.color.highlight_font_color'),
                      $r('app.color.background_color_white'),1,item)
                    Row(){
                     Text('剩余支付时间:')
                       .fontSize(10)
                       .fontColor($r('app.color.highlight_font_color'))
                      TextTimer({ isCountDown: true, count: 900000, controller: this.textTimerController })
                        .format('mm:ss')
                        .onAppear(() => {
                          this.textTimerController.start()
                        })
                        .fontSize(10)
                        .fontColor($r('app.color.highlight_font_color'))
                    }
                    .margin({left:95,top:8})
                  }
                }else {
                  this.rowBuilder('已失效',$r('app.color.unavailableTicket'),$r('app.color.tab_font_color'),2,item)
                }
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({top:16})
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .margin({left:12})
          }
          .margin({top:12,bottom: index===ticketsList.length-1? 12:0})
          .justifyContent(FlexAlign.Start)
          if (index!==ticketsList.length-1) {
            Divider()
              .margin({top:20})
              .width('100%')
          }
        }
        .width(304)
      }, (item: string, index: number) => item + index)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .borderRadius(16)
    .backgroundColor($r('app.color.tab_font_color_selected'))
    .width(328)
  }

  @Builder
  rowBuilder(text:string,rowColor:Resource,fontColor:Resource,state:number,item:MyTickets){
    Row() {
      Text(text)
        .fontSize(14)
        .fontColor(fontColor)
    }
    .borderRadius(8)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .margin({ left: 115 })
    .width(72)
    .height(28)
    .backgroundColor(rowColor)
    .onClick(()=>{
      if (state===0) {
        if (item.title === '地铁一日票') {
          this.vm.navStack.pop(1,true)
        }
        this.vm.navStack.pop(2,true)
      }else if (state === 1){
        this.vm.navStack.pushPath({name:'CheckOutPage',param: item.title==='地铁一日票'?15:35})
      }
    })
  }
}