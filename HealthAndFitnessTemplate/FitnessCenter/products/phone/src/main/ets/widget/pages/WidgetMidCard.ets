import { BookingInfo } from 'external_interactions';

@Component
export struct WidgetMidCard {
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';
  readonly FULL_PERCENT: string = '100%';
  @Prop courseName: string = '';
  @Prop recordDate: string = '';
  @Prop recordTime: string = '';
  @Prop showImg: string = 'app.media.material1';
  @Prop hasRecord: boolean = false;
  @Prop bookingInfo: BookingInfo = {} as BookingInfo;
  @State recordStoreName: string = AppStorage.get('currentStore') ?? '全市门店';

  build() {
    Column() {
      Row() {
        Image($r('app.media.logo'))
          .width('7.5%')
          .aspectRatio(1)
        Text('健身房元服务')
          .margin({ left: 8 })
          .alignSelf(ItemAlign.Center)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(24)
      .justifyContent(FlexAlign.Start)

      Row() {
        Image($r(this.showImg))
          .width('42%')
          .height('100%')
          .borderRadius(12)

        Column() {
          if (!this.hasRecord) {
            Row({ space: 8 }) {
              Image($r('app.media.book_now'))
                .width(30)
                .aspectRatio(1)
              Text('立即预约')
                .fontColor(Color.White)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FF9019')
            .width('100%')
            .height('45%')
            .borderRadius('50%')
            .onClick(() => {
              postCardAction(this, {
                action: this.actionType,
                abilityName: this.abilityName,
                params: { targetPage: 'course/ShowAllCourse' },
              });
            })

            Row({ space: 8 }) {
              Image($r('app.media.my_book'))
                .width(30)
                .aspectRatio(1)
              Text('我的预约')
                .fontColor(Color.White)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FF9019')
            .width('100%')
            .height('45%')
            .borderRadius('50%')
            .onClick(() => {
              postCardAction(this, {
                action: this.actionType,
                abilityName: this.abilityName,
                params: { targetPage: 'course/BookingRecord' },
              });
            })
          } else {
            Row() {
              Text(this.courseName)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .constraintSize({ maxWidth: '100%' })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .height(20)
            Row() {
              Text(`预约时间：${this.recordDate}  ${this.recordTime}`)
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .constraintSize({ maxWidth: '100%' })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .height(16)
            Row() {
              Text(`预约门店：${this.recordStoreName}`)
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .constraintSize({ maxWidth: '100%' })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .height(16)

            // 我的预约 & 取消预约
            Row() {
              Column() {
                Text('我的预约')
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
              }
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FF9019')
              .width('48%')
              .height('100%')
              .borderRadius('50%')
              .onClick(() => {
                postCardAction(this, {
                  action: this.actionType,
                  abilityName: this.abilityName,
                  params: { targetPage: 'course/BookingRecord' },
                });
              })
              Column() {
                Text('取消预约')
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
              }
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FF9019')
              .width('48%')
              .height('100%')
              .borderRadius('50%')
              .onClick(() => {
                postCardAction(this, {
                  action: this.actionType,
                  abilityName: this.abilityName,
                  params: { targetPage: 'course/BookingRecord' },
                });
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .height(28)
          }
        }
        .width('55%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height('75%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(this.FULL_PERCENT)
    .height(this.FULL_PERCENT)
    .padding(12)
  }
}