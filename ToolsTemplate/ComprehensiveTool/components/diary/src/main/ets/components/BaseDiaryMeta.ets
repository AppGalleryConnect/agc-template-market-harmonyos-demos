import dayjs from 'dayjs';
import { WEEK_MAP } from '../commons/Constant';


@ComponentV2
export struct BaseDiaryMeta {
  @Param date: Date = new Date();
  @Param isPrivacy: boolean = false;

  @Computed
  get dateDay() {
    return dayjs(this.date).format('YYYY-MM-DD');
  }

  @Computed
  get weekDay() {
    let week = dayjs(this.date).day();
    return WEEK_MAP[week];
  }

  @Computed
  get dateTime() {
    return dayjs(this.date).format('HH:mm');
  }

  build() {
    RelativeContainer() {
      // 日期时间
      this.dateView()
      // 隐私日记
      if (this.isPrivacy) {
        this.lockView()
      }
    }
    .height('auto')
  }

  @Builder
  dateView() {
    Row({ space: 4 }) {
      Text() {
        Span(this.dateDay)
        Span(' ')
        Span(this.weekDay)
      }
      .fontSize(16)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .lineHeight(21)

      Text(this.dateTime)
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight(16)
    }
    .id('dateTime')
    .alignItems(VerticalAlign.Center)
    .alignRules({
      left: { anchor: '__container__', align: HorizontalAlign.Start },
    })
  }

  @Builder
  lockView() {
    Row() {
      SymbolGlyph($r('sys.symbol.lock_fill'))
        .fontColor([$r('sys.color.white')])
        .fontSize(14)
    }
    .width(20)
    .height(20)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#E63C60', 0.0], ['#FFC2CF', 1]]
    })
    .id('lock')
    .alignRules({
      right: { anchor: '__container__', align: HorizontalAlign.End },
    })
  }
}