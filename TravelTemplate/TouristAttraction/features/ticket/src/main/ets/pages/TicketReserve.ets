import { AppStorageV2, CounterComponent, CounterType } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, Constant, GridRowColSetting } from 'common';
import { TitleBar } from 'uicomponents';
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
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Builder
  ReserveInfoBuilder() {
    Column() {
      Text('预订须知').fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Bold).margin({ top: 8, bottom: 8 });
      Text(this.ticketType?.instruction).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
    }
    .width(Constant.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    });
  }

  @Builder
  TicketTypeInfoBuilder() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.ticketType?.ticketTypeName).fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Bold);
        Row() {
          Text('预付 | 未核销随时退').fontColor($r('sys.color.font_tertiary')).fontSize($r('sys.float.Body_S'));
          Text() {
            Span('￥').fontSize($r('sys.float.Body_S'));
            Span(`${this.ticketType?.discountPrice}`)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium);
          }.fontColor($r('sys.color.warning'));
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
      }.alignItems(HorizontalAlign.Start);

      Divider();
      TourDateManagement({ ticketType: this.ticketType });
      Divider();
      this.TicketCountBuilder();

    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding(12)
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  TicketCountBuilder() {
    Row() {
      Column({ space: 2 }) {
        Text('购买数量')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Text('同一证件当天限购1张').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
      }.alignItems(HorizontalAlign.Start);

      CounterComponent({
        options: {
          type: CounterType.LIST, numberOptions: {
            value: this.vm.selectTouristCount,
            min: Constant.MIN_PURCHASE_QUANTITY,
            max: Constant.MAX_PURCHASE_QUANTITY,
            onChange: (value: number) => {
              this.vm.changeTourist(value);
            },
          },
        },
      }).width(120);
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '门票预订', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            Scroll() {
              Column({ space: 12 }) {
                this.TicketTypeInfoBuilder();
                TouristManagement();
                this.ReserveInfoBuilder();
              }.layoutWeight(1);
            }
            .padding({ top: 8, right: 8 })
            .margin({ left: 16, right: 16 })
            .constraintSize({ maxWidth: Constant.FULL_PERCENT })
            .align(Alignment.Top)
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring);
          };
        }.layoutWeight(1).onBreakpointChange((bp) => {
          this.vm.breakPointModel.currentBreakpoint = bp as BreakpointNameEnum;
        });

        Row() {
          Text() {
            Span('应付金额').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
            Span('￥').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.warning'));
            Span(`${this.vm.getAmount(this.ticketType?.discountPrice)}`)
              .fontColor($r('sys.color.warning'))
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Medium);
          };

          Button('立即预订').backgroundColor($r('sys.color.multi_color_04')).onClick(() => {
            if (!this.vm.validate(this.getUIContext())) {
              return;
            }

            this.vm.createOrder(this.ticketType);
          });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(Constant.FULL_PERCENT)
        .backgroundColor($r('sys.color.font_on_primary'))
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        });
      }.margin({ bottom: this.windowBottomHeight }).backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.ticketType = context.pathInfo.param as TicketType;
    });
  }
}