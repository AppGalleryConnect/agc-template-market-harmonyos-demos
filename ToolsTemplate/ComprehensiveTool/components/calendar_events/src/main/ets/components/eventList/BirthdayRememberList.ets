import dayjs from 'dayjs';
import { Countdown } from '../../utils/Countdown';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { DistanceToday } from '../common/DistanceToday';
import { ListEndSwiperAction } from '../common/ListEndSwiperAction';
import { EVENT_TYPE } from '../../constants/Constants';
import { RemindEventDispatcher } from '../../utils/EventDispatcher';
import { getWeekday } from '../../utils/Utils';

@ComponentV2
export struct BirthdayRememberList {
  @Param birthdayRememberList: UserEventItem[] = []
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local countdown: Countdown = new Countdown();
  @Param eventType: string = '';
  @Local currentIndex: number = -1

  aboutToDisappear() {
    this.countdown.stopCountdown()
  }

  @Monitor('birthdayRememberList.length')
  listChange() {
    this.countdown.startCountdown(this.birthdayRememberList[0])
  }

  aboutToAppear(): void {
    RemindEventDispatcher.eventChangeCallback = (userEventInfo: UserEventItem) => {
      if ([EVENT_TYPE.BIRTHDAY, EVENT_TYPE.ANNIVERSARIES].includes(userEventInfo.eventType)) {
        this.countdown.startCountdown(this.birthdayRememberList[0])
      }
    }
  }

  @Builder
  itemEnd(item: UserEventItem) {
    ListEndSwiperAction({
      userEventInfo: item,
      onToTop: (item: UserEventItem) => {
        this.birthdayRememberList.forEach(item => item.isTop = false)
        item.isTop = true
      },
    })
  }

  @Builder
  EventDayCountdown(item: UserEventItem) {
    Column({ space: 16 }) {
      Text(`距离${item.content}`)
        .fontWeight(FontWeight.Bold)
        .fontSize(18)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text('今天')
        .fontWeight(FontWeight.Bold)
        .fontSize(18)
        .fontColor('#C4272B')
        .visibility(this.countdown.isToday(item.date[0].date) ? Visibility.Visible :
        Visibility.None)
      Row({ space: 5 }) {
        Text(this.countdown.days > 9 ? this.countdown.days.toString() : '0' + this.countdown.days)
          .padding(5)
          .backgroundColor('#C4272B')
          .fontColor($r('sys.color.font_on_primary'))
          .borderRadius(4)
        Text('天')
        Text(this.countdown.hours > 9 ? this.countdown.hours.toString() : '0' + this.countdown.hours)
          .padding(5)
          .backgroundColor('#C4272B')
          .fontColor($r('sys.color.font_on_primary'))
          .borderRadius(4)
        Text(':')
        Text(this.countdown.minutes > 9 ? this.countdown.minutes.toString() : '0' + this.countdown.minutes)
          .padding(5)
          .backgroundColor('#C4272B')
          .fontColor($r('sys.color.font_on_primary'))
          .borderRadius(4)
        Text(':')
        Text(this.countdown.seconds > 9 ? this.countdown.seconds.toString() : '0' + this.countdown.seconds)
          .padding(5)
          .backgroundColor('#C4272B')
          .borderRadius(4)
          .fontColor($r('sys.color.font_on_primary'))
      }
      .visibility(this.countdown.isToday(item.date[0].date) ? Visibility.None :
      Visibility.Visible)
    }
    .height(120)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .borderRadius(16)
    .linearGradient({
      angle: 130,
      colors: [
        ['#FFF4E9', 0.0],
        ['#F4F2FE', 0.4],
        ['#F4F2FE', 1.0],
      ],
    })
  }

  build() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.birthdayRememberList.filter(item => item.isTop), (item: UserEventItem, index: number) => {
          if (this.birthdayRememberList.length) {
            ListItem() {
              this.EventDayCountdown(item)
            }
            .onClick(() => {
              const params: Record<string, UserEventItem | string> = {
                'userEventInfo': item,
                'eventType': this.eventType,
              }
              this.calendarEventVM.getPageInfo()?.pushPathByName('BirthdayRememberDetails', params)
            })
            .onAppear(() => {
              this.countdown.startCountdown(item)
            })
            .onDisAppear(() => {
              this.countdown.stopCountdown()
            })
          }
        }, (item: UserEventItem) => JSON.stringify(item))
        ListItem() {
          Column() {
            Image($r('app.media.no_data')).width(120).height(120)
            Text('暂无重要提醒')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .margin({ top: '40%' })
        }
        .visibility(this.birthdayRememberList.length ? Visibility.None : Visibility.Visible)

        ForEach(this.birthdayRememberList.filter(item => !item.isTop), (item: UserEventItem, index: number) => {
          ListItem() {
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Column() {
                Image(this.eventType === EVENT_TYPE.BIRTHDAY ? $r('app.media.ic_birthday') :
                $r('app.media.ic_remember'))
                  .width(24)
                  .height(24)
              }
              .width(30)
              .height(30)

              Column({ space: 3 }) {
                Text(item.content)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(14)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${item.date[0].isLunar ? item.date[0].lunarDate :
                dayjs(item.date[0].date).format('MM月DD日')} ${getWeekday(item.date[0].date)}`)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                Text(item.remarks)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .flexGrow(1)
              .margin({ left: 16 })
              .alignItems(HorizontalAlign.Start)

              Row() {
                Text(this.calendarEventVM.getDaysUntilBirthday(dayjs(item.date[0].date).format('YYYY-MM-DD'))
                  .toString())
                  .fontColor('#C4272B')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text('天')
                  .fontSize(14)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .width(60)
            }
            .backgroundColor('#FAFAFA')
            .borderRadius(16)
            .padding(12)
            .width('100%')
            .onClick(() => {
              const params: Record<string, UserEventItem | string> = {
                'userEventInfo': item,
                'eventType': this.eventType,
              }
              this.calendarEventVM.getPageInfo()?.pushPathByName('BirthdayRememberDetails', params)
            })
          }
          .visibility(this.birthdayRememberList.length ? Visibility.Visible : Visibility.None)
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd(item)
              },
            },
          })
        }, (item: UserEventItem) => JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .margin({ top: 12 })
    .layoutWeight(1)
    .padding({ bottom: 16 })
    .justifyContent(FlexAlign.Start)
  }
}