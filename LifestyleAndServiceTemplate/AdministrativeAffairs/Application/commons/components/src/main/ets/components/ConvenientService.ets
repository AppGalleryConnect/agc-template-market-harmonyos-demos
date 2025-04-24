import { ServiceListEnum, GridBanner, Constants, NavigationParams } from 'common';

@ComponentV2
export struct ConvenientService {
  @Param serviceList: GridBanner[] = [];
  @Param isOlder?: boolean = false;
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  build() {
    Column() {
      Row({ space: Constants.CONTAINER_SPACE_TEN }) {
        Row()
          .width($r('app.float.convenience_line_width'))
          .height($r('app.float.convenience_line_height'))
          .backgroundColor($r('app.color.convenience_service_bg'))
        Text($r('app.string.convenience_service'))
          .fontWeight(Constants.FONT_WEIGHT_MEDIUM)
          .fontSize(this.isOlder ? Constants.FONT_SIZE_LARGE : Constants.FONT_SIZE_NORMAL)
      }

      Grid() {
        ForEach(this.serviceList, (item: GridBanner, index: number) => {
          GridItem() {
            Column() {
              Row({ space: this.isOlder ? Constants.CONTAINER_SPACE_TWELVE : Constants.CONTAINER_SPACE_EIGHT }) {
                Image(item.pic)
                  .height(this.isOlder ? $r('app.float.convenience_older_image_height') :
                  $r('app.float.convenience_image_height'))
                  .width(this.isOlder ? $r('app.float.convenience_older_image_width') :
                  $r('app.float.convenience_image_width'))
                Text(item.name).fontSize(this.isOlder ? $r('sys.float.Title_S') : $r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Regular)
              }.width(Constants.EIGHTY_PERCENT_WIDTH)
              .justifyContent(FlexAlign.Start)
            }
            .padding({
              left: this.isOlder ? $r('app.float.convenience_service_older_padding') :
              $r('app.float.convenience_service_padding'),
            })
            .width(Constants.FULL_PERCENT_WIDTH)
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              /*
               * */
              if (item.serviceId === ServiceListEnum.DrugInquiry) {
                this.pageInfos.pushPathByName('medicines', new NavigationParams(item.name))
              } else {
                this.pageInfos.pushPathByName('business',
                  new NavigationParams(item.name, null, null, item.serviceId === ServiceListEnum.DesignatedHospital))
              }
            })
          }
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width($r('app.float.service_hot_image_size_older'))
          .height(this.isOlder ? $r('app.float.service_hot_image_height_older') :
          $r('app.float.service_hot_image_height'))
          .borderRadius(Constants.RADIUS_TWELVE)
          .clip(true)
        }, (item: GridBanner) => item.name)
      }
      .columnsTemplate(this.isOlder ? '1fr' : '1fr 1fr')
      .columnsGap(20)
      .rowsGap(15)
      .layoutDirection(GridDirection.Row)
      .padding({
        bottom: $r('app.float.convenience_content_margin_bottom'),
        top: $r('app.float.convenience_content_margin_top'),
      })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      top: $r('app.float.convenience_service_margin'),
      left: $r('app.float.common_margin_sixty'),
      right: $r('app.float.common_margin_sixty'),
      bottom: $r('app.float.convenient_service_margin_bottom'),
    })
    .padding({
      left: $r('app.float.convenience_service_padding'),
      right: $r('app.float.convenience_service_padding'),
      top: $r('app.float.convenience_service_padding_top'),
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(Constants.RADIUS_SIXTY)
  }
}