import { BreakpointNameEnum, BreakpointType, Constant } from 'common';
import { TitleBar } from 'uicomponents';
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
    Row({ space: 16 }) {
      Image(ticket.banner).borderRadius(8).width(72).height(96);
      Column({ space: 4 }) {
        Text(ticket.ticketName)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Row({ space: 8 }) {
          ForEach(ticket.labels, (item: string) => {
            Text(item)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .border({ width: 1, radius: 4, color: $r('sys.color.comp_divider') })
              .height(16)
              .padding({
                top: 1,
                bottom: 1,
                left: 4,
                right: 4,
              });
          }, (item: string) => item);
        };

        Text('实名制购票请携带身份证方便入园')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'));

        Row({ space: 2 }) {
          if (ticket.ticketType[ticket.basicTicketTypeId].originalPrice !==
            ticket.ticketType[ticket.basicTicketTypeId].discountPrice) {
            Text(`￥${ticket.ticketType[ticket.basicTicketTypeId].originalPrice.toFixed(2)}`)
              .fontColor($r('sys.color.font_tertiary'))
              .fontSize(12)
              .decoration({ type: TextDecorationType.LineThrough });
          }
          Text() {
            Span('￥').fontSize($r('sys.float.Body_S'));
            Span(`${ticket.ticketType[ticket.basicTicketTypeId].discountPrice.toFixed(2)}`)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Subtitle_L'));
            Span('起').fontSize($r('sys.float.Body_S'));
          }.fontColor($r('sys.color.warning'));
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End).alignItems(VerticalAlign.Bottom);

      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .height(96);
    }
    .backgroundColor($r('sys.color.font_on_primary'))
    .padding(12)
    .borderRadius(16)
    .width(Constant.FULL_PERCENT)
    .onClick(() => {
      this.mainPathStack.pushPathByName('TicketDetail', ticket.ticketId);
    });
  }

  build() {
    Column() {
      TitleBar({
        isShowBack: false, title: '门票', clickEvent: () => {
          this.mainPathStack.pop();
        },
      });
      List({ space: 12 }) {
        LazyForEach(this.vm.ticketList, (item: TicketInfo) => {
          this.TicketItemBuilder(item);
        });
      }
      .scrollBar(BarState.Off)
      .lanes(new BreakpointType<number>({
        [BreakpointNameEnum.SM]: 1,
        [BreakpointNameEnum.MD]: 1,
        [BreakpointNameEnum.LG]: 2,
        [BreakpointNameEnum.XL]: 2,
      }).getValue(this.vm.breakPointModel.currentBreakpoint), 16)
      .padding({ left: this.vm.breakPointModel.pagePadding, right: this.vm.breakPointModel.pagePadding })
      .layoutWeight(1)
      .contentStartOffset(8)
      .contentEndOffset(this.vm.isTabVertical ? this.vm.windowBottomHeight + 8 :
        Constant.BOTTOM_TAB_BAR_HEIGHT + this.vm.windowBottomHeight + 8)
      .edgeEffect(EdgeEffect.Spring);
    }.backgroundColor($r('sys.color.background_secondary')).layoutWeight(1);
  }
}