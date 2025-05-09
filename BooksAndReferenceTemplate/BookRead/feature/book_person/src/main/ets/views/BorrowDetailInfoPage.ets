import { UICountdown } from '@hw-agconnect/ui-countdown'
import { BookInfo, BorrowInfo, BorrowStatus, Constants, DHMS, NavHeaderBar, TCRouter, TimeUtils } from 'common';

@ComponentV2
export struct BorrowDetailInfoPage {
  @Local borrowInfo: BorrowInfo | undefined = undefined;
  @Local time: DHMS | undefined = undefined;

  aboutToAppear(): void {
    this.borrowInfo = TCRouter.getParams<BorrowInfo>(Constants.BORROW_DETAIL_ROUTE);
    if (this.borrowInfo && this.borrowInfo.status !== BorrowStatus.RETURNED) {
      this.time = new DHMS(this.borrowInfo?.borrowDeadline, this.borrowInfo?.borrowBegin);
    }
  }

  @Builder
  borrowTimeCard(info: BorrowInfo) {
    Column() {
      Row() {
        Column() {
          Text(info.statusInfo.statusText)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(info.statusInfo.statusColor)
            .width(72)
            .height(28)
            .borderRadius(8)
        }
        .backgroundColor($r('sys.color.comp_background_list_card'))

        Row() {
          Text($r('app.string.please'))
          Text(` ${TimeUtils.timestamp2YMD(info.borrowDeadline)} `)
            .fontColor(Color.Red)
          Text($r('app.string.returned_flag'))
        }
        .padding({ right: 5 })
        .opacity(50)
      }.width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 8, bottom: 8 })

      Column() {
        if (this.time) {
          Row() {
            Text(this.borrowInfo?.status === BorrowStatus.BORROWING ?
            $r('app.string.remaining') : $r('app.string.overdue'))
              .fontSize(18)
            UICountdown({
              day: this.time.days.toString(),
              minute: this.time.minutes.toString(),
              second: this.time.seconds.toString(),
              fontSize: 18,
              timeColor: info.statusInfo.statusColor,
              timeBackgroundColor: $r('app.color.common_background')
            }).backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .width('90%')
              .padding(14)
              .borderRadius(10)
          }
        } else {
          UICountdown({
            day: '0',
            minute: '0',
            second: '0',
            fontSize: 20,
            timeColor: info.statusInfo.statusColor,
            timeBackgroundColor: $r('app.color.common_background')
          }).backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
            .width('90%')
            .padding(14)
            .borderRadius(10)
        }

      }
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(`${getContext()
          .resourceManager
          .getStringByNameSync('borrow_time')}: ${TimeUtils.timestamp2YMD(info.borrowBegin)}`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
      }
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_SIZE)
      .padding({ top: 8, bottom: 8 })

      if (info.status === BorrowStatus.RETURNED) {
        Row() {
          Text(`${getContext()
            .resourceManager
            .getStringByNameSync('borrow_return_time')}: ${TimeUtils.timestamp2YMD(info.borrowEnd)}`)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
        }
        .width(Constants.FULL_SIZE)
        .padding({ top: 8, bottom: 8 })
      }
    }
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .height(info.status === BorrowStatus.RETURNED ? 200 : 150)
    .alignSelf(ItemAlign.Center)
    .borderRadius(16)
    .padding({
      left: 18,
      right: 18,
    })
    .margin({ top: 15, bottom: 15 })
  }

  @Builder
  borrowBookInfo(info: BorrowInfo) {
    Column() {
      Text($r('app.string.borrow_book_info_flag'))
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
    }.alignSelf(ItemAlign.Start)
    .padding({
      left: 18,
      right: 18,
    })
    .margin({ bottom: 15 })

    Column() {
      ForEach(info.borrowBooks, (book: BookInfo, index: number) => {
        Column() {
          Row() {
            Text(`${(index + 1).toString()} `)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .padding({
                top: 10,
                bottom: 10,
              })
            Text(`${book.name} `)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .padding({
                top: 10,
                bottom: 10,
              })
            Text(`${getContext().resourceManager.getStringByNameSync('author')}: ${book.author}`)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_secondary'))
              .padding({
                top: 10,
                bottom: 10,
              })
          }
          .alignSelf(ItemAlign.Start)

          Divider()
        }
      },(item: string) => new Date().toString())
    }
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .height(167)
    .alignSelf(ItemAlign.Center)
    .borderRadius(16)
    .padding({
      left: 18,
      right: 18,
    })
    .margin({ bottom: 15 })
  }

  @Builder
  borrowSystem() {
    Column() {
      Column() {
        Text($r('app.string.borrow_flag_system'))
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
      }.alignSelf(ItemAlign.Start)
      .padding({
        left: 18,
        right: 18,
      })
      .margin({ bottom: 15 })

      Column() {
        Scroll() {
          Text($r('app.string.borrow_flag'))
            .fontSize(12)
            .padding({
              top: 10,
              bottom: 10,
            })
        }.scrollBar(BarState.Off)
      }
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .height(200)
      .alignSelf(ItemAlign.Center)
      .borderRadius(16)
      .padding({
        left: 18,
        right: 18,
      })
    }
    .padding({ bottom: 20 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: $r('app.string.borrow_detail'),
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: true,
          })
            .backgroundColor($r('sys.color.background_secondary'))
          Column() {
            if (this.borrowInfo) {
              this.borrowTimeCard(this.borrowInfo);
              this.borrowBookInfo(this.borrowInfo);
            }
            this.borrowSystem();
          }
          .width(Constants.FULL_SIZE)
          .height(Constants.FULL_SIZE)
          .padding({
            left: 18,
            right: 18,
          })
        }
        .justifyContent(FlexAlign.Center)
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }.hideTitleBar(true)
  }
}