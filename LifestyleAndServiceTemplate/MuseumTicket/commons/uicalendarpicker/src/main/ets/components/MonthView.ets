import { BREAKPOINT_PROP_NAME } from '@hw-agconnect/ui-base';
import { DAY_WIDTH } from '../common/Constant';
import { DayModel, MonthModel, DateUtils } from '../common/Model';
import { UICalendarVM } from '../viewmodel/UICalendarVM';

@Component
export struct MonthView {
  @StorageLink(BREAKPOINT_PROP_NAME) breakpoint: string = 'sm';
  calendarVM: UICalendarVM = new UICalendarVM();
  month: MonthModel = new MonthModel(1, 1, []);
  isShowDisabledLabel: boolean = false;
  isShowLabel: boolean = false;

  aboutToAppear(): void {
    this.isShowDisabledLabel = this.calendarVM.isShowDisabledLabel();
    this.isShowLabel = this.calendarVM.isShowLabel();
  }

  setMonthViewH() {
    if (this.calendarVM.isSwiper()) {
      return '100%';
    }
    return 'auto';
  }

  @Builder
  buildDay(item: DayModel) {
    Row() {
      Column() {
        Text(item.day.toString())
          .fontSize(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.day)
          .fontColor(this.calendarVM.getFontColor(item))
          .fontWeight(FontWeight.Medium)
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'));
        // 减少不必要的render时间
        Column() {
          if (this.isShowDisabledLabel && this.calendarVM.isDisabledDate(item)) {
            Text(this.calendarVM.getDisableLabel(item))
              .fontSize($r('sys.float.ohos_id_text_size_caption'))
              .fontColor(this.calendarVM.isSelected(item) ? $r('sys.color.ohos_id_color_text_primary_contrary') :
              this.calendarVM.customFontColor)
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'));
          }
          // 减少不必要的render时间
          if (this.isShowLabel && this.calendarVM.isAbleDate(item)) {
            Text(this.calendarVM.getAbleLabel(item))
              .fontSize($r('sys.float.ohos_id_text_size_caption'))
              .fontColor(this.calendarVM.isSelected(item) ? $r('sys.color.ohos_id_color_text_primary_contrary') :
              this.calendarVM.customFontColor)
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'));
          }
        }.width('100%').height(11);

      }
      .width('100%')
      .height('100%')
      .opacity(this.calendarVM.isEnable(item) ? 1 : $r('sys.float.ohos_id_alpha_content_tertiary'))
      .borderRadius(4)
      .backgroundColor(this.calendarVM.isSelected(item) ? this.calendarVM.customColor : '')
      .justifyContent(FlexAlign.Center)
      .stateStyles(
        {
          pressed: {
            .backgroundColor($r('sys.color.ohos_id_color_click_effect'));
          },
        },
      );
    }
    .visibility(this.calendarVM.isDayVisible(item))
    .width(DAY_WIDTH)
    .aspectRatio(1)
    .padding({
      left: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft,
      right: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft,
      top: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
      bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
    })
    .enabled(this.calendarVM.isEnable(item))
    .onClick(() => {
      this.calendarVM.clickDate(item);
    });
  }

  @Builder
  buildDayBg(item: DayModel) {
    Row() {
      Text('')
        .width('100%')
        .height('100%')
        .backgroundColor(this.calendarVM.isInRange(item) ? this.calendarVM.customColor : '')
        .opacity($r('sys.float.ohos_id_alpha_highlight_bg'))
        .borderRadius({
          topLeft: this.calendarVM.isStartDate(item) ? 4 : 0,
          topRight: this.calendarVM.isEndDate(item) ? 4 : 0,
          bottomLeft: this.calendarVM.isStartDate(item) ? 4 : 0,
          bottomRight: this.calendarVM.isEndDate(item) ? 4 : 0,
        })
        .pixelRound({
          start: PixelRoundCalcPolicy.NO_FORCE_ROUND,
          end: PixelRoundCalcPolicy.NO_FORCE_ROUND,
        });
    }
    .visibility(this.calendarVM.isDayVisible(item))
    .width(DAY_WIDTH)
    .aspectRatio(1)
    .pixelRound({
      start: PixelRoundCalcPolicy.NO_FORCE_ROUND,
      end: PixelRoundCalcPolicy.NO_FORCE_ROUND,
    })
    .padding({
      top: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
      bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
      left: this.calendarVM.isStartDate(item) ? DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft : 0,
      right: this.calendarVM.isEndDate(item) ? DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft : 0,
    });
  }

  @Builder
  DayView(item: DayModel) {
    if (this.calendarVM.isTypeRange()) {
      Stack() {
        this.buildDayBg(item);
        this.buildDay(item);
      }
      .pixelRound({
        start: PixelRoundCalcPolicy.NO_FORCE_ROUND,
        end: PixelRoundCalcPolicy.NO_FORCE_ROUND,
      });
    } else {
      this.buildDay(item);
    }
  }

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.SpaceBetween,
    }) {
      ForEach(this.month.data, (item: DayModel) => {
        this.DayView(item);
      }, (item: DayModel, index) => index.toString());
    }
    .height(this.setMonthViewH())
    .width('100%');
  }
}
