import dayjs from 'dayjs';
import { Lunar } from 'lunar';

@Entry
@Component
struct WidgetCard {
  /*
   * The title.
   */
  readonly title: string = 'Hello World';
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';
  @State lunarInfo: string = ''
  @State yiText: string[] = []
  @State jiText: string[] = []

  aboutToAppear() {
    this.lunarInfo = this.getLunarInfo()
    this.getTodayYiJi()
  }

  getLunarInfo() {
    let d = Lunar.fromDate(new Date())
    return d.getMonthInChinese() + '月' + d.getDayInChinese()
  }

  getTodayYiJi() {
    const todayLunar = Lunar.fromDate(new Date());
    // 获取今日宜和忌
    this.yiText = todayLunar.getDayYi();
    this.jiText = todayLunar.getDayJi();
  }

  build() {
    // Row() {
    Column() {
      Column({ space: 8 }) {
        Text(dayjs(new Date()).format('YYYY年MM月DD日'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
        Text(this.lunarInfo)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        postCardAction(this, {
          action: this.actionType,
          abilityName: this.abilityName,
          params: {
            message: 'perpetual',
          },
        });
      })

      Column({ space: 12 }) {
        Row({ space: 5 }) {
          Image($r('app.media.ic_yi_str'))
            .width(20)

          Text() {
            ForEach(this.yiText, (value: string) => {
              Span(value + '  ')
            },(value: string) => value)
          }
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor(FontWeight.Regular)
          .layoutWeight(1)

        }

        Row({ space: 5 }) {
          Image($r('app.media.ji'))
            .width(20)

          Text() {
            ForEach(this.jiText, (value: string) => {
              Span(value + '  ')
            },(value: string) => value)
          }
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor(FontWeight.Regular)
          .layoutWeight(1)
        }
      }
      .onClick(() => {
        postCardAction(this, {
          action: this.actionType,
          abilityName: this.abilityName,
          params: {
            message: 'almanac',
          },
        });
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 12,
      bottom: 14,
      left: 12,
      right: 12,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: 'perpetual',
        },
      });
    })
  }
}