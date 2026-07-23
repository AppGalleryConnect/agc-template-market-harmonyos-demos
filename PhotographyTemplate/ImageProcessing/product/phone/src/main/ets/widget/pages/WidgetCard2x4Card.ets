import { Constants, BtnItemInfo } from '../common/Constants';

@Entry
@Component
struct WidgetCard2x4Card {
  readonly actionType: string = 'router';
  readonly abilityName: string = 'PhoneAbility';

  postFormCard(routeUrl: string) {
    postCardAction(this, {
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        source: 'FormCard',
        pageUrl: routeUrl,
      },
    });
  }

  build() {
    Column() {
      this.headerBuilder()

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center}) {
        Column() {
          this.btnViewItem({
            label: '图片美化',
            icon: $r('app.media.ic_editing'),
            bgColor: $r('sys.color.multi_color_aux_01'),
            clickAction: () => {
              this.postFormCard(Constants.PICTURE_BEAUTIFICATION)
            }
          }, 84)
        }
        .flexGrow(1)
        .margin({ right: 8 })
        Column({ space: 8 }) {
          this.btnViewItem({
            label: '相机',
            icon: $r('app.media.ic_camera_beautify'),
            bgColor: $r('sys.color.multi_color_02'),
            clickAction: () => {
              this.postFormCard(Constants.LUT_CAMERA_PAGE)
            }
          })

          this.btnViewItem({
            label: '拼图',
            icon: $r('app.media.ic_collage'),
            bgColor: $r('sys.color.multi_color_05'),
            clickAction: () => {
              this.postFormCard(Constants.COLLAGE_PAGE)
            }
          })
        }
        .flexGrow(1)
      }
      .layoutWeight(1)
      .width(Constants.FULL_PERCENT)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding(Constants.PADDING_M)
  }

  @Builder
  headerBuilder() {
    Row({ space: 8 }) {
      Image($r('app.media.app_icon')).width(20).height(20)
      Text('图片美化')
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(400)
        .layoutWeight(1)
    }
    .width(Constants.FULL_PERCENT)
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
      });
    })
  }

  @Builder
  btnViewItem($$: BtnItemInfo, height: Length = 'auto') {
    Row({ space: 8 }) {
      Image($$.icon).width(24).height(24)
      Text($$.label)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(21)
    }
    .width(Constants.FULL_PERCENT)
    .height(height)
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($$.bgColor)
    .onClick(() => {
      $$.clickAction()
    })
  }
}