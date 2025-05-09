import { UICalendarDialog } from './UICalendarDialog';
import { DialogType, END_YEAR, MAX_GAP_DEFAULT, START_YEAR, SwiperDirection, TypePicker } from '../common/Constant';
import { DatesItem,DateUtils } from '../common/Model';

@Extend(Text)
function textStyle() {
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .lineHeight(19);
}

@Component
export struct UICalendarPicker {
  @BuilderParam customBuildPanel: () => void;
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
  /**
   * 设置可选日期,将未在该日期中的整体禁用，仅该值传值时生效。
   */
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
  /**
   * 半模态弹窗高度
   */
  @Prop sheetH: SheetSize | Length = 500;
  @State isShowSheet: boolean = false;
  controller: CustomDialogController = new CustomDialogController({
    builder: this.buildDialog,
    customStyle: true,
  });
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

  @Builder
  buildDialog() {
    UICalendarDialog({
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
      ableDates: this.ableDates,
      disableDayLabel: this.disableDayLabel,
      maxGap: this.maxGap,
      enableSelectTime: this.enableSelectTime,
      isMilitaryTime: this.isMilitaryTime,
      sheetTitle: this.sheetTitle,
      onSelected: (date: Date | Date[]) => {
        if (date instanceof Date) {
          this.selected = date;
        } else {
          this.selectDates = date;
        }
        this.onSelected(date);
      },
      cancel: () => {
        this.cancel();
      },
      onClickDate: (date: Date) => {
        this.onClickDate(date);
      },
      close: () => {
        if (this.dialogType === DialogType.DIALOG) {
          this.controller?.close();
        } else {
          this.isShowSheet = false;
        }
      },
    });
  }

  getSingleDateLabel() {
    if (!this.selected) {
      return $r('app.string.select_placeholder');
    }
    return DateUtils.formatDate(this.selected);
  }

  getSingleDateTimeLabel() {
    if (!this.selected) {
      return $r('app.string.select_placeholder');
    }
    return DateUtils.formatDateTime(this.selected);
  }

  getMultiDateLabel() {
    if (!this.selectDates.length) {
      return $r('app.string.select_placeholder');
    }
    const listCut = [...this.selectDates];
    listCut.splice(2);
    let label = listCut.map((item) => {
      return DateUtils.formatDate(item);
    }).join('; ');
    if (this.selectDates.length > 2) {
      label += '...';
    }

    return label;
  }

  getDateRangeLabel() {
    if (this.selectDates.length <= 0) {
      return $r('app.string.select_placeholder');
    }
    if (this.selectDates.length === 1) {
      return `${DateUtils.formatDate(this.selectDates[0])}-`;
    }
    return `${DateUtils.formatDate(this.selectDates[0])}-${DateUtils.formatDate(this.selectDates[1])}`;
  }

  @Builder
  buildPanel() {
    Row({ space: 4 }) {
      if (this.type === TypePicker.SINGLE) {
        if (this.enableSelectTime) {
          Text(this.getSingleDateTimeLabel()).textStyle();
        } else {
          Text(this.getSingleDateLabel()).textStyle();
        }
      } else if (this.type === TypePicker.MULTIPLE) {
        Text(this.getMultiDateLabel()).textStyle();
      } else {
        Text(this.getDateRangeLabel()).textStyle();
      }
      Image($r('app.media.ic_public_arrow_right'))
        .width(12)
        .height(20)
        .fillColor($r('sys.color.ohos_id_color_primary'))
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.High);
    };
  }

  build() {
    Column() {
      if (this.customBuildPanel) {
        this.customBuildPanel();
      } else {
        this.buildPanel();
      }
    }
    .onClick(() => {
      if (this.dialogType === DialogType.DIALOG) {
        this.controller.open();
      } else {
        this.isShowSheet = true;
      }
    })
    .bindSheet($$this.isShowSheet, this.buildDialog(), {
      showClose: false,
      preferType: SheetType.CENTER,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      detents: this.swiperDirection === SwiperDirection.VERTICAL ? [SheetSize.MEDIUM, SheetSize.LARGE] : [this.sheetH],
      backgroundColor: this.swiperDirection === SwiperDirection.VERTICAL ? $r('sys.color.ohos_id_color_dialog_bg') :
        null,
    });
  }
}