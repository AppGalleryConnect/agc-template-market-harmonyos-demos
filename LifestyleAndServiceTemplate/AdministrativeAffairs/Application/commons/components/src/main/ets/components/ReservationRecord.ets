import { Constants, formatTimestamp, ReservationRecord, UserState } from 'common'
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct ReservationRecordList {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;

  @Builder
  itemEnd(item: ReservationRecord, index: number) {
    Column() {
      Row() {
        Text('取消预约').fontColor(Color.White)
      }
      .backgroundColor($r('app.color.record_sheet_submit_color'))
      .padding($r('app.float.common_padding_ten'))
      .margin({ left: $r('app.float.common_margin_ten'), right: $r('app.float.common_margin_ten') })
      .borderRadius(Constants.RADIUS_TEN)
      .onClick(() => {
        this.userState.recordList.splice(index, 1)
      })
    }.height(Constants.FULL_PERCENT_HEIGHT).backgroundColor(Color.White).justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      List() {
        if (!this.userState.recordList.length) {
          ListItem() {
            Column() {
              Image($r('app.media.no_data')).width($r('app.float.no_data_size')).height($r('app.float.no_data_size'))
              Text($r('app.string.no_data'))
            }
          }.width(Constants.FULL_PERCENT_WIDTH).height(Constants.FULL_PERCENT_HEIGHT).backgroundColor(Color.White)
        } else {
          ListItem() {
            Column() {
              Text($r('app.string.reservation_tips')).fontColor(Color.White)
            }
            .backgroundColor($r('app.color.institutions_tag_bg'))
            .width(Constants.FULL_PERCENT_WIDTH)
            .alignItems(HorizontalAlign.Center)
          }

          ForEach(this.userState.recordList, (item: ReservationRecord, index: number) => {
            ListItem() {
              Row() {
                Column({ space: Constants.CONTAINER_SPACE_TEN }) {
                  Row() {
                    Text($r('app.string.reservation_location'))
                    Text(item.recordName)
                  }
                  .width(Constants.FULL_PERCENT_WIDTH)
                  .justifyContent(FlexAlign.Start)

                  Row() {
                    Text($r('app.string.reservation_time'))
                    Text(formatTimestamp(item.calendarStartTime))
                    Text('-')
                    Text(formatTimestamp(item.calendarEndTime).split(' ')[1])
                  }
                  .width(Constants.FULL_PERCENT_WIDTH)
                  .justifyContent(FlexAlign.Start)
                }
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .padding($r('app.float.record_padding'))
              .backgroundColor(Color.White)
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(item, index)
                },
              },
            }) // 设置侧滑属性.
            .margin({ top: $r('app.float.record_margin') })
          }, (item: ReservationRecord) => JSON.stringify(item.calendarStartTime))
        }
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.record_bg'))
    }.title('预约记录').padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}