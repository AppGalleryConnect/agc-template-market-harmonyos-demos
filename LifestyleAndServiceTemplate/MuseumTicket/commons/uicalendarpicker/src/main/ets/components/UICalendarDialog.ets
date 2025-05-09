import {
  AvoidAreaCallback,
  AvoidAreaInfo,
  BREAKPOINT_PROP_NAME,
  CommonGridSetting,
  Logger,
  PaddingType,
  UIBase,
} from '@hw-agconnect/ui-base';
import { MonthModel, UICalendarOptions, DatesItem, DateUtils } from '../common/Model';
import {
  DAY_WIDTH,
  DialogType,
  END_YEAR,
  MAX_GAP_DEFAULT,
  START_YEAR,
  SwiperDirection,
  TypePicker,
} from '../common/Constant';
import { UICalendarVM } from '../viewmodel/UICalendarVM';
import { MonthView } from './MonthView';
import { inspector } from '@kit.ArkUI';

@Extend(Image)
function arrowStyle(customColor: ResourceColor, disabled: boolean = false, w: number = 12, h: number = 20) {
  .width(w)
  .height(h)
  .fillColor(customColor)
  .interpolation(ImageInterpolation.High)
  .draggable(false)
  .opacity(disabled ? $r('sys.float.ohos_id_alpha_content_tertiary') : 1)
  .responseRegion({
    x: '-20%',
    y: '-20%',
    width: '130%',
    height: '130%',
  });
}

@Extend(Button)
function btnStyle(fontSize: Length) {
  .type(ButtonType.Normal)
  .buttonStyle(ButtonStyleMode.TEXTUAL)
  .borderRadius(8)
  .fontSize(fontSize)
  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
  .padding({
    top: 0,
    bottom: 0,
    left: 16,
    right: 16,
  });
}

@Extend(Text)
function textStyle(fontSize: Length) {
  .fontSize(fontSize)
  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
  .fontColor($r('sys.color.ohos_id_color_text_primary'));
}

@Extend(Button)
function iconContainerStyle() {
  .type(ButtonType.Circle)
  .width(40)
  .height(40)
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'));
}

@CustomDialog
export struct UICalendarDialog {
  /**
   * 日期选择器的类型
   */
  @Prop type: TypePicker = TypePicker.SINGLE;
  /**
   * 弹窗类型
   */
  @Prop dialogType: DialogType = DialogType.SHEET;
  /**
   * 滑动方向
   */
  @Prop swiperDirection: SwiperDirection = SwiperDirection.HORIZONTAL;
  /**
   * 定制主题色
   */
  @Prop customColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary_activated');
  /**
   * 定制文字颜色
   */
  @Prop customFontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  /**
   * 一周起始天，默认是星期天，取值范围 0 - 6
   */
  @Prop startDayOfWeek: number = 0;
  /**
   * 切换年月的起始年份
   */
  @Prop startYear: number = START_YEAR;
  /**
   * 切换年月的结束年份
   */
  @Prop endYear: number = END_YEAR;
  /**
   * 单日期，支持传入默认值
   */
  @Prop selected: Date;
  /**
   * 多日期，支持传入默认值
   */
  @Prop selectDates: Date[] = [];
  /**
   * y方向上的偏移
   */
  @Prop yOffset: number = 0;
  /**
   * 设置可选范围
   */
  @Prop rangeLimit: Date[] = [];
  /**
   * 设置禁选日期，仅针对单日期、多日期生效
   */
  @Prop disabledDates: DatesItem[] = [];
  @Prop ableDates: DatesItem[] = [];
  /**
   * 禁止使用日期的自定义文字
   */
  @Prop disableDayLabel: ResourceStr = $r('app.string.disable_day_label');
  /**
   * 针对时间段类型，设置起止日期的跨度
   */
  @Prop maxGap: number = MAX_GAP_DEFAULT;
  /**
   * 支持选择时间
   */
  @Prop enableSelectTime: boolean = false;
  /**
   * 针对时间选择，展示时间是否为24小时制
   */
  @Prop isMilitaryTime: boolean = false;
  /**
   * 半模态弹窗标题文字
   */
  @Prop sheetTitle: ResourceStr = '';
  @StorageLink(BREAKPOINT_PROP_NAME) breakpoint: string = 'sm';
  controller: CustomDialogController;
  // 年月滚轮视图
  @State monthPickerVisible: boolean = false;
  // 时间滚轮
  @State timePickerVisible: boolean = false;
  @State paddingTop: number = 0;
  @State paddingBottom: number = 0;
  calendarVM: UICalendarVM = new UICalendarVM();
  @State showNearMonth: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  // 监听Swiper中间元素layout，左右两边元素做分帧处理
  private _middleMonthId: string = 'MiddleMonthID';
  private listener: inspector.ComponentObserver = inspector.createComponentObserver(this._middleMonthId);
  /**
   * 确认选择后的回调
   */
  onSelected: (date: Date | Date[]) => void = () => {
  };
  /**
   * 点击日期的回调
   */
  onClickDate: (date: Date) => void = () => {
  };
  /**
   * 取消选择的回调
   */
  cancel: () => void = () => {
  };
  close: () => void = () => {
  };

  build() {
    if (this.calendarVM.dialogType === DialogType.DIALOG) {
      this.buildDialog();
    } else if (this.calendarVM.swiperDirection === SwiperDirection.HORIZONTAL) {
      this.buildSheet();
    } else {
      this.buildListView();
    }
  }

  aboutToAppear(): void {
    const props: UICalendarOptions = {
      type: this.type,
      dialogType: this.dialogType,
      swiperDirection: this.swiperDirection,
      customColor: this.customColor,
      customFontColor: this.customFontColor,
      startDayOfWeek: this.startDayOfWeek,
      startYear: this.startYear,
      endYear: this.endYear,
      selected: this.selected,
      selectDates: this.selectDates,
      yOffset: this.yOffset,
      rangeLimit: this.rangeLimit,
      disabledDates: this.disabledDates,
      disableDayLabel: this.disableDayLabel,
      maxGap: this.maxGap,
      enableSelectTime: this.enableSelectTime,
      isMilitaryTime: this.isMilitaryTime,
      sheetTitle: this.sheetTitle,
      ableDates: this.ableDates,
      onSelected: (date: Date | Date[]) => {
        this.onSelected(date);
      },
      onClickDate: (date: Date) => {
        this.onClickDate(date);
      },
      cancel: () => {
        this.cancel();
      },
      close: () => {
        this.close();
      },
    };
    this.calendarVM.init(props);
    this.handleScreenChange();
    this.listener.on('layout', this.middleMonthLayoutCB);
  }

  aboutToDisappear(): void {
    UIBase.offAvoidAreaChange(this.avoidAreaChangeWatch);
    this.listener.off('layout', this.middleMonthLayoutCB);
  }

  handleScreenChange() {
    const data: PaddingType | undefined = AvoidAreaInfo.getAvoidAreaOnce();
    this.handlePadding(data);
    UIBase.onAvoidAreaChange(this.avoidAreaChangeWatch);
  }

  avoidAreaChangeWatch = (data: AvoidAreaCallback) => {
    const resp: PaddingType = AvoidAreaInfo.handle(data);
    this.handlePadding(resp);
  };
  middleMonthLayoutCB = () => {
    this.showNearMonth = true;
  };

  handlePadding(data: PaddingType | undefined) {
    this.paddingTop = data?.top || 0;
    if (UIBase.isWindowLayoutFullScreen()) {
      this.paddingBottom = data?.bottom || 0;
    }
  }

  @Builder
  buildMonthPicker() {
    Column() {
      Row() {
        TextPicker({
          range: [this.calendarVM.yearLabels, this.calendarVM.monthLabels],
          selected: [this.calendarVM.currShowDate.getFullYear() - this.calendarVM.startYear,
            this.calendarVM.currShowDate.getMonth()],
        })
          .width('100%')
          .constraintSize({ minHeight: 160, maxHeight: 280 })
          .selectedTextStyle({
            color: this.calendarVM.customColor,
            font: {
              size: $r('sys.float.ohos_id_text_size_headline7'),
              family: $r('sys.string.ohos_id_text_font_family_medium'),
            },
          })
          .textStyle({
            color: $r('sys.color.ohos_id_color_text_secondary'),
            font: {
              size: $r('sys.float.ohos_id_text_size_sub_title1'),
              family: $r('sys.string.ohos_id_text_font_family_regular'),
            },
          })
          .disappearTextStyle({
            color: $r('sys.color.ohos_id_color_text_tertiary'),
            font: {
              size: $r('sys.float.ohos_id_text_size_sub_title3'),
              family: $r('sys.string.ohos_id_text_font_family_regular'),
            },
          })
          .onChange((value, index) => {
            this.calendarVM.yearMonthTuple = index as number[];
          });
      }
      .width('100%')
      .margin({ top: 30, bottom: 20 });

      Row({ space: 14 }) {
        Button($r('app.string.cancel'))
          .btnStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.btn)
          .onClick(() => {
            this.monthPickerVisible = false;
            this.calendarVM.yearMonthTuple = [this.calendarVM.currShowDate.getFullYear() - this.calendarVM.startYear,
              this.calendarVM.currShowDate.getMonth()];
          });
        Button($r('app.string.confirm'))
          .btnStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.btn)
          .onClick(() => {
            this.monthPickerVisible = false;
            this.calendarVM.changeYearMonth();
          });
      }.alignSelf(ItemAlign.End);
    }
    .width('100%');
  }

  @Builder
  buildTimePicker() {
    Column() {
      TimePicker({
        selected: (this.calendarVM.inSelectedDate || this.calendarVM.currShowDate),
        format: TimePickerFormat.HOUR_MINUTE_SECOND,
      })
        .width('100%')
        .constraintSize({ minHeight: 160, maxHeight: 280 })
        .useMilitaryTime(this.calendarVM.isMilitaryTime)
        .onChange((value: TimePickerResult) => {
          if (value.hour >= 0) {
            this.calendarVM.selectedTime = value;
          }
        })
        .selectedTextStyle({
          color: this.calendarVM.customColor,
          font: {
            size: $r('sys.float.ohos_id_text_size_headline7'),
            family: $r('sys.string.ohos_id_text_font_family_medium'),
          },
        })
        .textStyle({
          color: $r('sys.color.ohos_id_color_text_secondary'),
          font: {
            size: $r('sys.float.ohos_id_text_size_sub_title1'),
            family: $r('sys.string.ohos_id_text_font_family_regular'),
          },
        })
        .disappearTextStyle({
          color: $r('sys.color.ohos_id_color_text_tertiary'),
          font: {
            size: $r('sys.float.ohos_id_text_size_sub_title3'),
            family: $r('sys.string.ohos_id_text_font_family_regular'),
          },
        });

      Row({ space: 14 }) {
        Button($r('app.string.cancel'))
          .btnStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.btn)
          .onClick(() => {
            this.timePickerVisible = false;
            this.calendarVM.selectedTime = {
              hour: this.calendarVM.inSelectedDate?.getHours() || 0,
              minute: this.calendarVM.inSelectedDate?.getMinutes() || 0,
              second: this.calendarVM.inSelectedDate?.getSeconds() || 0,
            };
          });
        Button($r('app.string.confirm'))
          .btnStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.btn)
          .onClick(() => {
            this.calendarVM.showNowLabel = false;
            this.timePickerVisible = false;
            this.calendarVM.inSelectedDate?.setHours(this.calendarVM.selectedTime.hour,
              this.calendarVM.selectedTime.minute, this.calendarVM.selectedTime.second);
          });
      }.alignSelf(ItemAlign.End);
    };

  }

  @Builder
  buildHeader() {
    Row() {
      Row() {
        Text(DateUtils.formatYear(this.calendarVM.currShowDate.getFullYear().toString()))
          .textStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.year);
        Text(this.calendarVM.monthLabels[this.calendarVM.currShowDate.getMonth()])
          .textStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.year)
          .margin({ left: 4 });
        Image($r('app.media.ic_public_arrow_right'))
          .arrowStyle(this.calendarVM.customColor)
          .margin({ left: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.yearToArrow });
      }
      .onClick(() => {
        this.monthPickerVisible = true;
      });

      if (this.calendarVM.showTime) {
        Row() {
          Text(this.calendarVM.getTimeLabel())
            .textStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.year);
          Image($r('app.media.ic_public_arrow_right'))
            .arrowStyle(this.calendarVM.customColor)
            .margin({ left: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.yearToArrow });
        }
        .opacity(Boolean(this.calendarVM.inSelectedDate) ? 1 : $r('sys.float.ohos_id_alpha_content_tertiary'))
        .enabled(Boolean(this.calendarVM.inSelectedDate))
        .onClick(() => {
          this.timePickerVisible = true;
        });
      } else {
        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .arrowStyle(this.calendarVM.customColor, this.calendarVM.isReachStart())
            .enabled(!this.calendarVM.isReachStart())
            .onClick(() => {
              this.swiperController.showPrevious();
            });

          Image($r('app.media.ic_public_arrow_right'))
            .arrowStyle(this.calendarVM.customColor, this.calendarVM.isReachEnd())
            .margin({ left: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.arrowToArrow })
            .enabled(!this.calendarVM.isReachEnd())
            .onClick(() => {
              this.swiperController.showNext();
            });
        };
      }

    }
    .width('100%')
    .padding({
      left: 8,
      right: 8,
      top: 8,
      bottom: 8,
    })
    .margin({ bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.yearToWeek })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  buildWeekLabels() {
    Row() {
      ForEach(this.calendarVM.weekLabels, (item: string) => {
        Text(item)
          .fontSize(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.week)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
          .lineHeight(18)
          .textAlign(TextAlign.Center)
          .width(DAY_WIDTH);
      }, (item: string) => item);
    }.margin({ bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.weekToDay }).width('100%');
  }

  @Builder
  buildFooter() {
    if (this.calendarVM.dialogType === DialogType.DIALOG &&
      (this.calendarVM.type !== TypePicker.SINGLE || this.calendarVM.showTime)) {
      Row({ space: 14 }) {
        Button($r('app.string.cancel'))
          .btnStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.btn)
          .onClick(() => {
            this.calendarVM.cancelSelect();
          });

        Button($r('app.string.confirm'))
          .btnStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.btn)
          .enabled(this.calendarVM.isSelectedValid())
          .onClick(() => {
            this.calendarVM.confirmSelect();
          });
      }
      .justifyContent(FlexAlign.End)
      .margin({ top: 4 })
      .width('100%');
    }
  }

  @Builder
  buildScrollerInside() {
    Stack() {
      Column() {
        this.buildHeader();
        this.buildWeekLabels();
        Swiper(this.swiperController) {
          if (this.showNearMonth) {
            MonthView({ month: this.calendarVM.preMonth, calendarVM: this.calendarVM });
          } else {
            Column();
          }

          MonthView({ month: this.calendarVM.currentMonth, calendarVM: this.calendarVM }).id(this._middleMonthId);

          if (this.showNearMonth) {
            MonthView({ month: this.calendarVM.nextMonth, calendarVM: this.calendarVM });
          } else {
            Column();
          }
        }
        .width('100%')
        .aspectRatio(7 / 6)
        .index($$this.calendarVM.curMonthIndex)
        .indicator(false)
        .loop(true)
        .onAnimationStart((index: number, targetIndex: number) => {
          this.calendarVM.onAnimationStart(index, targetIndex);
        })
        .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer) => {
          return this.calendarVM.onGestureRecognizerJudgeBegin(event, current);
        });

        this.buildFooter();
      }
      .width('100%')
      .visibility(this.monthPickerVisible || this.timePickerVisible ? Visibility.Hidden : Visibility.Visible);

      if (this.monthPickerVisible) {
        this.buildMonthPicker();
      } else if (this.timePickerVisible) {
        this.buildTimePicker();
      }
    }
    .alignContent(Alignment.Center)
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .padding({
      left: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.outerLeft,
      right: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.outerLeft,
      top: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.outerTop,
      bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.outerTop,
    });
  }

  @Builder
  buildDialog() {
    GridRow(CommonGridSetting.getCommonGridOption(GridRowDirection.RowReverse)) {
      GridCol({
        span: 4,
        offset: {
          sm: 0,
          md: 2,
          lg: 4,
          xl: 4,
        },
      }) {
        Column() {
          Scroll() {
            this.buildScrollerInside();
          }
          .translate({ y: this.calendarVM.yOffset })
          .width('100%')
          .onClick(() => {
          });
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .padding({ top: this.paddingTop, bottom: this.paddingBottom });
      };
    }
    .onClick(() => {
      this.close();
    })
    .margin({
      left: CommonGridSetting.getGridMargin(this.breakpoint),
      right: CommonGridSetting.getGridMargin(this.breakpoint),
    })
    .onBreakpointChange((breakpoint) => {
      this.breakpoint = breakpoint;
    });
  }

  @Builder
  sheetTitleBuilder() {
    Row({ space: 4 }) {
      Button() {
        Image($r('app.media.ic_public_close_sheet'))
          .width(20)
          .height(20)
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .draggable(false);
      }
      .iconContainerStyle()
      .onClick(() => {
        this.calendarVM.cancelSelect();
      });

      Text(this.calendarVM.sheetTitle)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .margin({ left: 8, right: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Start);

      Blank();

      Button() {
        Image($r('app.media.ic_public_confirm_sheet'))
          .width(20)
          .height(20)
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .draggable(false);
      }
      .iconContainerStyle()
      .enabled(this.calendarVM.isSelectedValid())
      .onClick(() => {
        this.calendarVM.confirmSelect();
      });

    }.width('100%');
  }

  @Builder
  buildSheet() {
    Column({ space: 16 }) {
      this.sheetTitleBuilder();
      Scroll() {
        this.buildScrollerInside();
      }
      .layoutWeight(1)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 30,
    });
  }

  @Builder
  groupHeader(v: MonthModel) {
    Row({ space: 4 }) {
      Text(DateUtils.formatYear(v.year.toString()))
        .textStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.year);
      Text(this.calendarVM.monthLabels[v.month - 1])
        .textStyle(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.year);
    }
    .width('100%')
    .padding(10)
    .margin({ bottom: 4 })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'));
  }

  @Builder
  buildListView() {
    Column() {
      Row() {
        this.sheetTitleBuilder();
      }
      .width('100%')
      .padding({
        top: 10,
        bottom: 10,
      });

      this.buildWeekLabels();
      List({ initialIndex: this.calendarVM.curMonthIndex, scroller: this.calendarVM.listScroller }) {
        LazyForEach(this.calendarVM.monthDataSource, (v: MonthModel) => {
          ListItemGroup({ header: this.groupHeader(v) }) {
            ListItem() {
              MonthView({ month: v, calendarVM: this.calendarVM });
            };
          };
        }, (v: MonthModel) => `${v.year}-${v.month}`);
      }
      .width('100%')
      .layoutWeight(1)
      .sticky(StickyStyle.Header)
      .scrollBar(BarState.Off)
      .cachedCount(1)
      .friction(0.5)
      .edgeEffect(EdgeEffect.None)
      .onScrollIndex((start: number, end: number, center: number) => {
        this.calendarVM.onScrollIndex(start, end, center);
      });
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 });
  }
}
