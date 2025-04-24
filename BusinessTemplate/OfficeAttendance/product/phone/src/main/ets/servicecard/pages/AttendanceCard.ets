import { CheckInStatus } from '@ohos_agcit/office_attendance_common_lib/src/main/ets/constants/CheckInEnums';
import { CardListComponent } from '../view/CardListComponent';
import { CardListParameter } from '../viewmodel/CardListParameter';

let storageLocal = new LocalStorage();

@Entry(storageLocal)
@Component
struct AttendanceCard {
  @LocalStorageProp('startTime') startTime: string = '--:--:--';
  @LocalStorageProp('endTime') endTime: string = '--:--:--';
  @LocalStorageProp('checkInStatus') checkInStatus: CheckInStatus = CheckInStatus.NOT_STARTED;
  @State cardListParameter: CardListParameter = new CardListParameter(Color.White,
    $r('app.string.card_list_title'), '', ImageSize.Auto, $r('app.media.servicecard'), true,
    Color.White, true, 2, $r('sys.color.ohos_id_color_emphasize'),
    $r('app.color.list_item_count_background'), '', true, '');
  /*
   * The action type.
   */
  readonly actionType = 'router';
  /*
   * The ability name.
   */
  readonly abilityName = 'EntryAbility';
  /*
   * The message.
   */
  readonly message = 'ServiceCard';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent = '100%';

  @Builder
  cardListBuilder() {
    Row() {
      Text(this.startTime)
        .fontSize($r('app.float.item_title_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor('rgb(0,0,0,0.9)')

      Text($r('app.string.firstTime'))
        .fontSize($r('app.float.item_content_font_size'))
        .fontWeight(FontWeight.Regular)
        .height($r('app.float.item_text_height'))
        .backgroundColor('rgba(0,0,0,0.05)')
        .fontColor('rgba(0,0,0,0.9)')
        .borderRadius(20)
        .padding({
          left: 6,
          right: 6
        })
    }
    .alignItems(VerticalAlign.Center)
    .width(this.fullWidthPercent)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 12 })

    Row() {
      Text(this.endTime)
        .fontSize($r('app.float.item_title_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0,0,0,0.9)')
        .height($r('app.float.item_text_height'))

      Text($r('app.string.lastTime'))
        .fontSize($r('app.float.item_content_font_size'))
        .fontWeight(FontWeight.Regular)
        .height($r('app.float.item_text_height'))
        .backgroundColor('rgba(0,0,0,0.05)')
        .fontColor('rgba(0,0,0,0.9)')
        .borderRadius(20)
        .padding({
          left: 6,
          right: 6
        })
    }
    .alignItems(VerticalAlign.Center)
    .width(this.fullWidthPercent)
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.item_height'))
    .margin({ top: 6 })
  }

  build() {
    Row() {
      CardListComponent({ cardListParameter: this.cardListParameter, checkInStatus: this.checkInStatus }) {
        this.cardListBuilder();
      }
    }
    .height(this.fullHeightPercent)
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: this.message
        }
      });
    })
  }
}