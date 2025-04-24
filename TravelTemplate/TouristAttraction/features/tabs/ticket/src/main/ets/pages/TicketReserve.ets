import { CounterComponent, CounterType, promptAction } from '@kit.ArkUI';
import { Constant } from 'common';
import { TitleBar } from 'components';
import { TourDateManagement } from '../components/TourDateManagement';
import { TouristManagement } from '../components/TouristManagement';
import { TicketType } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';

@Builder
export function TicketReserveBuilder() {
  TicketReserve();
}

@ComponentV2
export struct TicketReserve {
  vm: TicketVM = TicketVM.instance;
  @Local yOffset: number = 0;
  scroller: Scroller = new Scroller();
  @Local ticketType: TicketType | null = null;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  ReserveInfoBuilder() {
    Column({ space: 12 }) {
      Text('预订须知').fontSize(14).fontWeight(500).width(Constant.FULL_PERCENT).textAlign(TextAlign.Start);
      Divider();
      Text(this.ticketType?.instruction).fontSize(14).opacity(0.9);
    }.padding(12).backgroundColor(Color.White).borderRadius(8);
  }

  @Builder
  TicketTypeInfoBuilder() {
    Column({ space: 12 }) {
      Text(this.ticketType?.ticketTypeName)
        .fontSize(20)
        .fontWeight(500)
        .align(Alignment.Start)
        .width(Constant.FULL_PERCENT);
      Row() {
        Text('预付 | 未核销随时退').opacity(0.4).fontSize(12);
        Row() {
          Text('￥').fontSize(12).fontColor('#E84026');
          Text(`${this.ticketType?.discountPrice}`).fontSize(18).fontWeight(500).fontColor('#E84026');
        };
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Divider();
      TourDateManagement({ ticketType: this.ticketType });
      Divider();
      this.TicketCountBuilder();
    }.padding(12).backgroundColor(Color.White).borderRadius(8);
  }

  @Builder
  TicketCountBuilder() {
    Row() {
      Text('购买数量').fontSize(16).fontWeight(500);

      CounterComponent({
        options: {
          type: CounterType.LIST,
          numberOptions: {
            value: this.vm.selectTouristCount,
            min: Constant.MIN_PURCHASE_QUANTITY,
            max: Constant.MAX_PURCHASE_QUANTITY,
            onChange: (value: number) => {
              this.vm.changeTourist(value);
            },
          },
        },
      }).width(80);
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).padding(0);
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            TitleBar({
              isShowBack: true, title: '门票预订', clickEvent: () => {
                this.mainPathStack.pop();
              },
            });

            Scroll() {
              Column({ space: 12 }) {
                this.TicketTypeInfoBuilder();
                TouristManagement();
                this.ReserveInfoBuilder();
              }.padding(12).linearGradient({
                direction: GradientDirection.Bottom, // 渐变方向
                repeating: false, // 渐变颜色是否重复
                colors: [['#64BB5C', 0.0], ['#FFFFFF', 0.5], ['#FFFFFF', 1]], // 数组末尾元素占比小于1时满足重复着色效果
              });
            }
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring);
          }.height('80%');

          Row() {
            Text() {
              Span('应付金额').fontSize(14).opacity(0.9);
              Span('￥').fontSize(12).fontColor('#E84026').fontWeight(500);
              Span(`${this.vm.getAmount(this.ticketType?.discountPrice)}`)
                .fontColor('#E84026')
                .fontSize(20)
                .fontWeight(500);
            };

            Button('预定')
              .width(96)
              .height(40)
              .backgroundColor('#64BB5C')
              .onClick(() => {
                if (!this.vm.validate()) {
                  return;
                }

                this.vm.createOrder(this.ticketType);
              });
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(Constant.FULL_PERCENT)
          .height('10%')
          .position({ y: '90%' })
          .backgroundColor(Color.White)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12, right: 12 });
        };
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.ticketType = context.pathInfo.param as TicketType;
    });
  }
}