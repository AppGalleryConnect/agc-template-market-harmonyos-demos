import {GridBanner, HomeServiceEnum, NavigationParams } from 'common';
import { MedicalPersonCardInfo } from 'components'

@ComponentV2
export struct InstitutionPersonalCard {
  @Param commonlyUsed: GridBanner[] = [];
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Consumer('tabCurrentIndex') tabCurrentIndex: number = 0

  aboutToAppear(): void {
  }

  @Builder
  personalGrid() {
    Row() {
      // Row({ space: Constants.CONTAINER_SPACE_TEN }) {
      Column() {
        Row({ space: 12 }) {
          Image($r('app.media.person_elders')).width(32).height(32)
          Text('长辈模式')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .onClick(() => {
          /*
          * 长辈模式
          * */
          this.pageInfos.pushPathByName('older', new NavigationParams('长辈模式'))
        })
      }
      .width('48%')
      .height(60)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 180,
        colors: [
          ['#F29962', 0.0],
          ['#DF4545', 0.4],
          ['#DF4545', 1.0],
        ],
      })

      Row() {
        // Row({ space: Constants.CONTAINER_SPACE_TEN }) {
        Column() {
          Row({ space: 12 }) {
            Image($r('app.media.person_code')).width(32).height(32)
            Text('医保码')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .onClick(() => {
            /*
             * 医保码
             * */
            this.tabCurrentIndex = HomeServiceEnum.Code
          })
        }
        .width('48%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .borderRadius(12)
        .linearGradient({
          angle: 180,
          colors: [
            ['##C1EF2E', 0.0],
            ['#58BC11', 0.4],
            ['#58BC11', 1.0],
          ],
        })
      }
    }
    .width('100%').justifyContent(FlexAlign.SpaceBetween)
    .margin({
      top: $r('app.float.personal_card_margin_top'),
      bottom: $r('app.float.personal_card_margin_bottom'),
    })
    .padding({
      left: $r('app.float.personal_card_padding'),
      right: $r('app.float.personal_card_padding'),
    })
  }

  build() {
    Column() {
      MedicalPersonCardInfo()
      this.personalGrid()
    }
    .borderRadius({
      topLeft: $r('app.float.person_card_radius_topL'),
      topRight: $r('app.float.person_card_radius_topL'),
      bottomLeft: $r('app.float.person_card_radius_botL'),
      bottomRight: $r('app.float.person_card_radius_botR'),
    })
    .justifyContent(FlexAlign.Center)
  }
}
