import { CheckInStatus } from '@ohos_agcit/office_attendance_common_lib/src/main/ets/constants/CheckInEnums';
import { CardListParameter } from '../viewmodel/CardListParameter';

const LAYOUT_WEIGHT = 1;

@Component
export struct CardListComponent {
  @Link checkInStatus: CheckInStatus | undefined;
  @BuilderParam customBuilderParam: () => void = this.customBuilder;
  @Link cardListParameter: CardListParameter | undefined;
  /**
   * The max quantity of list items.
   */
  readonly maxQuantity = 99;
  /*
  * The width percentage setting.
  */
  readonly fullWidthPercent = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent = '100%';

  @Builder
  customBuilder() {
    // custom builder
  }

  build() {
    if (this.cardListParameter !== undefined) {
      Column({ space: FlexAlign.Start }) {
        Row() {
          Image(this.cardListParameter.logo)
            .width($r('app.float.list_logo_size'))
            .height($r('app.float.list_logo_size'))

          Text(this.cardListParameter.title)
            .fontSize($r('app.float.list_title_font_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.cardListParameter.titleColor)
            .margin({ left: 6 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(LAYOUT_WEIGHT)
        }
        .width(this.fullWidthPercent)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        List() {
          this.customBuilderParam();
        }
        .width(this.fullWidthPercent)
        .height(this.fullHeightPercent)
        .layoutWeight(LAYOUT_WEIGHT)
        .scrollBar(BarState.Off)

        Button({ type: ButtonType.Capsule }) {
          Row() {
            if (this.checkInStatus === CheckInStatus.NOT_STARTED) {
              Text($r('app.string.servicecard_button_tip')).fontColor(Color.White)
            } else if (this.checkInStatus === CheckInStatus.ON_GOING) {
              LoadingProgress().enableLoading(true).margin({ right: 4 })
              Text($r('app.string.servicecard_button_ongoing_tip')).fontColor(Color.White)
            } else if (this.checkInStatus === CheckInStatus.FINISHED) {
              Text($r('app.string.servicecard_button_finished_tip')).fontColor(Color.White)
            }
          }.justifyContent(FlexAlign.Center)
        }.height(36).width('100%').backgroundColor($r('app.color.service_card_button_background'))
        .onClick(() => {
          if (this.checkInStatus !== CheckInStatus.NOT_STARTED) {
            this.checkInStatus = CheckInStatus.NOT_STARTED;
            return;
          }

          this.checkInStatus = CheckInStatus.ON_GOING;
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              message: 'Button'
            }
          })
        })
      }
      .pixelRound({ bottom: PixelRoundCalcPolicy.FORCE_CEIL })
      .backgroundImage(this.cardListParameter.backgroundImage)
      .backgroundImageSize(this.cardListParameter.backgroundImageSize)
      .backgroundColor(this.cardListParameter.backgroundColor)
      .padding({
        top: $r('app.float.list_side_padding'),
        bottom: $r('app.float.list_side_padding'),
        left: $r('app.float.list_side_padding'),
        right: $r('app.float.list_side_padding')
      })
    }
  }
}