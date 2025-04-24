import { BaseStyleData, Constants, HotService, NavigationParams, ServiceListEnum } from 'common'

@ComponentV2
export struct HotServiceCard {
  @Param hotServices: HotService[] = [];
  @Param isOlder?: boolean = false;
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Consumer('baseStyleData') baseStyleData: BaseStyleData = new BaseStyleData()

  build() {
    Grid() {
      ForEach(this.hotServices, (service: HotService, index: number) => {
        GridItem() {
          Stack() {
            Image(this.isOlder ? service.olderPic : service.pic)
              .height(this.isOlder ? $r('app.float.service_hot_image_size_older') :
              $r('app.float.service_hot_image_size'))
              .width(Constants.FULL_PERCENT_WIDTH)
              .borderRadius(12)
              .clip(true)
            if (!this.isOlder) {
              Row() {
                Column({ space: Constants.CONTAINER_SPACE_TEN }) {
                  Text(service.name)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(Constants.FONT_SIZE_MINI)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                  Image($r('app.media.hot_right_arrow'))
                    .width($r('app.float.service_hot_arrow_size'))
                    .height($r('app.float.service_hot_arrow_size'))
                }.width(Constants.FORTY_PERCENT_WIDTH).alignItems(HorizontalAlign.Start)

                Image(service.icon).width($r('app.float.hot_service_width')).height($r('app.float.hot_service_height'))
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({
                top: 12,
                bottom: 12,
                left: $r('app.float.hot_service_content_left'),
                right: $r('app.float.hot_service_content_right'),
              })
            } else {
              Column() {
                Image(service.icon)
                  .width($r('app.float.hot_service_icon_width'))
                  .height($r('app.float.hot_service_icon_height'))
                Column() {
                  Text(service.name).fontWeight(FontWeight.Medium).fontSize($r('sys.float.Title_S'))
                    .fontSize($r('sys.color.font_primary'))
                }
                .width(Constants.FULL_PERCENT_WIDTH)
                .padding({
                  left: $r('app.float.hot_service_icon_padding'),
                  right: $r('app.float.hot_service_icon_padding'),
                })
              }
              .height(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceEvenly)
              .padding({
                left: $r('app.float.hot_service_content_left'),
                right: $r('app.float.hot_service_content_right'),
              })
            }
          }
        }
        .onClick(() => {
          //   跳转到对应的h5页面
          let loadUrl = 'visit.html'
          if (service.serviceId === 'code') {
            if (this.isOlder) {
              /*
               * 长辈版情况跳转到医保码
               * */
              this.pageInfos.pushPathByName('medicalCode', null)
              return
            }
          }
          if (service.serviceId === ServiceListEnum.InsuranceInformation) {
            loadUrl = 'person.html'
          } else if (service.serviceId === ServiceListEnum.VisitRecords) {
            loadUrl = 'visit.html'
          }
          this.pageInfos.pushPathByName('web', new NavigationParams(service.name, loadUrl))
        })
        .width($r('app.float.hot_service_older_width'))
        .height(this.isOlder ? $r('app.float.hot_service_older_height') : $r('app.float.hot_service_normal_height'))
        .borderRadius(this.isOlder ? Constants.RADIUS_TWELVE : 0)
        .clip(true)
      }, (service: HotService) => service.serviceId)
    }
    .columnsTemplate(this.isOlder ? '1fr 1fr' : '1fr')
    .backgroundColor($r('sys.color.background_primary'))
    .padding(this.isOlder ? $r('app.float.common_margin_twelve') : 0)
    .margin({
      top: this.isOlder ? $r('app.float.common_margin_twelve') : 0,
      left: this.isOlder ? $r('app.float.common_margin_sixty') : 0,
      right: this.isOlder ? $r('app.float.common_margin_sixty') : 0,
    })
    .borderRadius(this.isOlder ? Constants.RADIUS_TEN : 0)
    .columnsGap(10)
    .rowsGap(10)
    .layoutDirection(GridDirection.Row)
  }
}