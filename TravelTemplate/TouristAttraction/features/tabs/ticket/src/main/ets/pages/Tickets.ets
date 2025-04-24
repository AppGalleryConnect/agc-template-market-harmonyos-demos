import { Constant } from 'common';
import { TitleBar } from 'components';
import { TicketInfo } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';

@Builder
export function TicketsBuilder() {
  Tickets();
}

@ComponentV2
export struct Tickets {
  vm: TicketVM = TicketVM.instance;
  @Local isLoading: boolean = true;
  @Local isFromMain: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  TicketItemBuilder(ticket: TicketInfo) {
    Row({ space: 8 }) {
      Image(ticket.banner).borderRadius(8).width('20%').height(90);
      Column() {
        Text(ticket.ticketName).fontSize(16).fontWeight(500);
        Row({ space: 8 }) {
          ForEach(ticket.labels, (item: string) => {
            Text(item)
              .fontSize(10)
              .border({ width: 1, radius: 4, color: '#F6933B' })
              .padding(4);
          }, (item: string) => item);
        };

        Text('实名制购票请携带身份证方便入园').fontSize(12).opacity(0.6);

        Text() {
          Span('￥').fontSize(12).fontColor('#E84026');
          Span(`${ticket.ticketType[ticket.basicTicketTypeId].discountPrice.toFixed(2)}`)
            .fontWeight(500)
            .fontColor('#E84026')
            .fontSize(18);
          Span('起').fontSize(12).opacity(0.6);
        }.width(Constant.FULL_PERCENT).textAlign(TextAlign.End);
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('80%')
      .height(Constant.FULL_PERCENT);
    }
    .onClick(() => {
      this.mainPathStack.pushPathByName('TicketDetail', ticket.ticketId);
    })
    .backgroundColor(Color.White)
    .padding(16)
    .borderRadius(8)
    .height(120)
    .width(Constant.FULL_PERCENT);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false || this.isFromMain, title: '门票列表', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        List({ space: 12 }) {
          LazyForEach(this.vm.ticketList, (item: TicketInfo) => {
            this.TicketItemBuilder(item);
          });
        }.scrollBar(BarState.Off).padding({ left: 12, right: 12 }).height('90%');
      };
    }.backgroundColor('#F1F3F5F2').hideTitleBar(true).onReady((context: NavDestinationContext) => {
      if (context.pathInfo.param as boolean) {
        this.isFromMain = true;
      }
    });
  }
}