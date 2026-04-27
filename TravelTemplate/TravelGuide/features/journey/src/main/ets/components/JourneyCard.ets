import { TimeUtil } from 'common'
import { OrderInfo, OrderStatus, OrderType, PassengerInfo } from 'common_travel_guide'

@ComponentV2
export struct JourneyCard {
  @Param @Require data: OrderInfo

  getTitleStr() {
    let year = new Date().getFullYear()
    let timeStamp = TimeUtil.convertDateTimeToTimestamp(`${year}-${this.data.detailInfo?.startTime}`)
    let date = TimeUtil.formatDate(timeStamp, TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR)
    let week = TimeUtil.buildDayOfWeek(timeStamp)
    return `${date} ${week}`
  }

  getTimeStr(timeStr: string) {
    return timeStr.split(' ')[1] || ''
  }

  getDuration() {
    let year = new Date().getFullYear()
    let startT = TimeUtil.convertDateTimeToTimestamp(`${year}-${this.data.detailInfo?.startTime}`)
    let endT = TimeUtil.convertDateTimeToTimestamp(`${year}-${this.data.detailInfo?.endTime}`)
    let duration = TimeUtil.getDuration(startT, endT)
    return TimeUtil.getFormattedDuration(duration)
  }

  formatDurationStr(timeStr: string) {
    // 移除可能的秒数部分
    const timeWithoutSeconds = timeStr.split(':').slice(0, 2).join(':');

    // 将时间字符串转换为Date对象
    const hours = timeWithoutSeconds.split(':').map(Number)[0]
    const minutes = timeWithoutSeconds.split(':').map(Number)[1]

    // 构建结果字符串
    let result = '';
    if (hours > 0) {
      result += `${hours}时`;
    }
    if (minutes > 0) {
      result += `${minutes}分`;
    }

    return result || '0时';
  }

  getStatusColor(status: OrderStatus) {
    if (status === OrderStatus.FINISHED) {
      return 'rgba(0, 0, 0, 0.50)'
    }
    if ([OrderStatus.ISSUED, [OrderStatus.BOOKED]].includes(status)) {
      return '#49AA54'
    }
    return 'rgba(0, 0, 0, 0.50)'
  }

  getStatusStr(status: OrderStatus) {
    if ([OrderStatus.ISSUED, [OrderStatus.BOOKED]].includes(status)) {
      return '待出行'
    }
    if (status === OrderStatus.FINISHED) {
      return '已完成'
    }
    return '已完成'
  }

  @Builder
  cardTitle() {
    Row() {
      Text(`${this.getTitleStr()} 前往${this.data.detailInfo.destination}`)
        .fontWeight(500)
        .fontSize(14)
        .fontColor('#000')
    }
    .margin({ bottom: 8 })
    .width('100%')
  }

  @Builder
  passengerContent() {
    Column({ space: 10 }) {
      ForEach(this.data.passengerInfo, (item: PassengerInfo) => {
        this.passengerRow(item)
      },(item: PassengerInfo)=>JSON.stringify(item))
    }
    .width('100%')
  }

  @Builder
  passengerRow(item: PassengerInfo) {
    Row() {
      Text(item.name)
        .fontSize(14)
        .fontColor('#000')
      if (this.data.type === OrderType.AIRPLANE) {
        Text(item.getEncryptionID())
          .fontSize(14)
          .fontColor('#000')
      } else {
        Text(item.seatNo)
          .fontSize(14)
          .fontColor('#000')
          .visibility(this.data.type === OrderType.TRAIN ? Visibility.Visible : Visibility.Hidden)
      }
    }
    .width('100%')
    .height(48)
    .borderRadius(12)
    .backgroundColor('#F6F8F9')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  timeInfo() {
    Row() {
      Column({ space: 8 }) {
        Text(this.data.detailInfo.departureTime)
          .fontSize(26)
          .fontWeight(500)
          .fontColor('#000')
        Text(this.data.detailInfo.departurePlace)
          .fontSize(14)
          .fontColor('#333')
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 2 }) {
        if (this.data.type === OrderType.AIRPLANE) {
          Image($r('app.media.airplane_logo'))
            .height(43)
            .width(92)
          Text(`行程预计 ${this.formatDurationStr(this.getDuration())}`)
            .fontColor('rgba(0, 0, 0, 0.70)')
            .fontSize(10)
        } else {
          Text(this.formatDurationStr(this.getDuration()))
            .fontColor('rgba(0, 0, 0, 0.70)')
            .fontSize(10)
            .visibility(this.data.type === OrderType.TRAIN ? Visibility.Visible : Visibility.Hidden)

          Image($r('app.media.ic_trip_arrow'))
            .height(12)
            .width(76)
          Text(this.data.detailInfo.trainNo)
            .fontColor('rgba(0, 0, 0, 0.70)')
            .fontSize(10)
            .visibility(this.data.type === OrderType.TRAIN ? Visibility.Visible : Visibility.Hidden)
        }
      }
      .alignItems(HorizontalAlign.Center)


      Column({ space: 8 }) {
        Text(this.data.detailInfo.arrivalTime)
          .fontSize(26)
          .fontWeight(500)
          .fontColor('#000')
          .visibility(this.data.type === OrderType.BUS ? Visibility.Hidden : Visibility.Visible)

        Text(this.data.detailInfo.destination)
          .fontSize(14)
          .fontColor('#333')
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(83)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  airplaneInfo() {
    Column({ space: 8 }) {
      Row() {
        Text() {
          Span(this.data.detailInfo.flightNumber)
          Span(` | ${this.data.detailInfo.aircraftModel}`)
          Span(` | 起飞准点率${this.data.detailInfo.onTimeRate}`)
        }
        .fontColor('rgba(0, 0, 0, 0.30)')
        .fontSize(10)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row() {
        this.airplaneInfoItem('班次', this.data.detailInfo.flightNumber)
        this.airplaneInfoItem('舱位等级', this.data.detailInfo.cabinClass)
        this.airplaneInfoItem('登机口', this.data.detailInfo.boardingGateNo)
      }
      .height(56)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      this.passengerContent()
      this.statusRow()
    }
    .width('100%')
    .margin({ top: 4 })
  }

  @Builder
  airplaneInfoItem(label?: string, value?: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontColor('#9E9E9E')
        .fontSize(12)
      Text(value)
        .fontColor('#000')
        .fontSize(14)
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  trainInfo() {
    Column() {
      Column() {
        Row() {
          Text('检票口/候车地点')
            .fontSize(12)
            .fontColor('#9E9E9E')
            .margin({ bottom: 4 })
          Text('约' + this.data.detailInfo.busDuration)
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Text(this.data.detailInfo.ticketCheckpoint)
          .fontSize(14)
          .fontColor('#000')
          .margin({ bottom: 10 })
      }
      .alignItems(HorizontalAlign.Start)

      this.passengerContent()
      this.statusRow()
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 6 })
  }

  @Builder
  statusRow() {
    Row() {
      Text(this.getStatusStr(this.data.status))
        .fontSize(14)
        .fontColor(this.getStatusColor(this.data.status))
    }
    .margin({ top: 14 })
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  @Builder
  cardContent() {
    Column() {
      this.timeInfo()
      if (this.data.type === OrderType.AIRPLANE) {
        this.airplaneInfo()
      } else {
        this.trainInfo()
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .borderRadius(16)
    .padding({
      top: 16,
      bottom: 12,
      left: 12,
      right: 12
    })
    .backgroundColor('#fff')
  }

  build() {
    Column() {
      this.cardTitle()
      this.cardContent()
    }
    .width('100%')
  }
}
