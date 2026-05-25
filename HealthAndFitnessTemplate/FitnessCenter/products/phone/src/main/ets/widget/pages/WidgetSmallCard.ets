import { BookingInfo } from 'external_interactions';

@Component
export struct WidgetSmallCard {
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';
  readonly FULL_PERCENT: string = '100%';
  @State targetPage: string = 'course/ShowAllCourse'
  @State buttonText: string = '立即预约'
  @Prop courseName: string = '';
  @Prop recordTime: string = '';
  @Prop showImg: string = 'app.media.material1'
  @Prop @Watch('updateContent') hasRecord: boolean = false
  @Prop bookingInfo: BookingInfo = {} as BookingInfo;

  updateContent() {
    this.targetPage = this.hasRecord ? 'course/BookingRecord' : 'course/ShowAllCourse'
    this.buttonText = this.hasRecord ? '查看更多' : '立即预约'
  }

  build() {
    Column() {
      Row() {
        Text('我的预约')
          .alignSelf(ItemAlign.Center)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.logo'))
          .width('15%')
          .aspectRatio(1)
      }
      .width('100%')
      .height(24)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        if (!this.hasRecord) {
          Text('暂无预约信息！')
            .alignSelf(ItemAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
        } else {
          Image($r(this.showImg))
            .height('100%')
            .aspectRatio(1)
            .borderRadius(8)
          Column() {
            Row() {
              Text(this.courseName)
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .constraintSize({ maxWidth: '50%' })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .height(16)
            Row() {
              Text(this.recordTime)
                .textAlign(TextAlign.Start)
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Regular)
                .maxLines(1)
                .constraintSize({ maxWidth: '50%' })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .height(14)
            Row() {
              Text(AppStorage.get('currentStore') ?? '全市门店')
                .textAlign(TextAlign.Start)
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Regular)
                .maxLines(1)
                .constraintSize({ maxWidth: '50%' })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .height(14)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ left: 6 })
        }
      }
      .width('100%')
      .height('45%')
      .margin({ top: 10, bottom: 8 })

      Button(this.buttonText, { controlSize: ControlSize.SMALL })
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#FF9019')
        .width(this.FULL_PERCENT)
        .onClick(() => {
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: { targetPage: this.targetPage },
          });
        });
    }
    .justifyContent(FlexAlign.Center)
    .width(this.FULL_PERCENT)
    .height(this.FULL_PERCENT)
    .padding(12)
  }

}

