import { DialogType,
  SwiperDirection,
  TypePicker, UICalendarDialog, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { CommonDivider } from 'componentlib';
import { DatePickerPanelVM } from '../viewmodels/DatePickerPanelVM';

@ComponentV2
export struct DatePickerPanel {
  vm: DatePickerPanelVM = DatePickerPanelVM.instance;
  @Param showTopLabel: boolean = true;

  @Event paramChangeCallback: () => void = () => {
  };

  build() {
    Column() {
      if (this.showTopLabel) {
        this.titleBuilder();
      }
      this.datePickerBuilder();
      CommonDivider({ color: $r('app.color.system_color_grey_level1') });
      this.roomCountSelectorBuilder();
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: $r('app.string.padding_s'),
      bottom: $r('app.string.padding_s'),
      left: this.showTopLabel ? $r('app.string.padding_m') : 0,
      right: this.showTopLabel ? $r('app.string.padding_m') : 0,
    })
    .borderRadius(this.showTopLabel ? $r('app.string.border_radius_16') : 0)
    .backgroundColor('#FFFFFFFF');
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('入住').subLabelStyle();
      Text('共' + this.vm.totalDays + '晚')
        .padding({ left: $r('app.string.padding_xs'), right: $r('app.string.padding_xs') })
        .subLabelStyle()
        .borderWidth(1)
        .borderRadius(10)
        .borderColor('#FFE0E0E0');
      Text('离店').subLabelStyle();
    }
    .width('100%')
    .margin({ bottom: $r('app.string.margin_s') })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  datePickerBuilder() {
    UICalendarPicker({
      type: TypePicker.RANGE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.vm.today.getFullYear(),
      rangeLimit: [this.vm.startDate],
      endYear: this.vm.today.getFullYear() + 1,
      detents:[SheetSize.MEDIUM],
      selectDates: [this.vm.checkInDate, this.vm.checkOutDate],
      onSelected: (date: Date | Date[]) => {
        this.vm.handleConfirm(date, this.paramChangeCallback);
      },
      cancel:()=> {
      },
    }) {
      Row() {
        Row() {
          Text(this.vm.getDateLabel(this.vm.checkInDate))
            .mainLabelStyle()
            .margin({ right: $r('app.string.margin_s') });

          Text(this.vm.getDateDescription(this.vm.checkInDate))
            .subLabelStyle();
        };

        Blank()
          .width(12)
          .height(1)
          .margin({
            left: $r('app.string.margin_s'),
            right: $r('app.string.margin_s'),
          })
          .backgroundColor($r('app.color.font_color_level2'));
        Row() {
          Text(this.vm.getDateLabel(this.vm.checkOutDate))
            .mainLabelStyle()
            .margin({ right: $r('app.string.margin_s') });

          Text(this.vm.getDateDescription(this.vm.checkOutDate))
            .subLabelStyle();
        };

        if (!this.showTopLabel) {
          Blank();
          Text('共' + this.vm.totalDays + '晚')
            .subLabelStyle()
            .fontSize($r('app.string.font_size_24'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({
        bottom: $r('app.string.margin_s'),
      })
    }
  }

  @Builder
  roomCountSelectorBuilder() {
    Row() {
      Text('房间数量').mainLabelStyle();
      Row() {
        Column() {
          Image($r('app.media.icon_circle_subtract'))
            .height(20)
            .fillColor(this.vm.roomCount <= this.vm.MIN_ROOM_COUNT ?
            $r('app.color.font_color_level3') :
            $r('app.color.font_color_level1'));
        }
        .width(50)
        .padding({ left: 20 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => this.vm.changeRoomCount(-1, this.paramChangeCallback));

        Text(this.vm.roomCount.toString())
          .mainLabelStyle();
        Column() {
          Image($r('app.media.icon_circle_add'))
            .height(20)
            .fillColor(this.vm.roomCount >= this.vm.MAX_ROOM_COUNT ?
            $r('app.color.font_color_level3') :
            $r('app.color.font_color_level1'));
        }
        .width(30)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
        .onClick(() => this.vm.changeRoomCount(1, this.paramChangeCallback));
      }
      .width(120)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .margin({ top: $r('app.string.margin_s') })
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

@Extend(Text)
function mainLabelStyle() {
  .fontSize($r('app.string.font_size_28'))
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium);
}

@Extend(Text)
function subLabelStyle() {
  .fontSize($r('app.string.font_size_20'))
  .fontColor($r('app.color.font_color_level2'));
}