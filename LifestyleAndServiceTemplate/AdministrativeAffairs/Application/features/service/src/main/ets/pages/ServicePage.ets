import {
  CloudFunction,
  CloudFunctionServiceResult,
  Constants,
  refineServices,
  ServiceList,
  ServiceListInfo,
} from 'common';
import { ServiceTitle } from 'components';
import { ServiceItems } from '../components/ServiceItems';

@ComponentV2
export struct ServicePage {
  @Local categoryList: ServiceListInfo[] = []
  @Local refineServicesArray: ServiceList[] = []
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  async getServiceList() {
    let resp = await CloudFunction.getServiceList('service')
    if ((resp as CloudFunctionServiceResult).result.ret.code === 0) {
      let result: ServiceListInfo[] =
        (resp as CloudFunctionServiceResult).result.result as ServiceListInfo[]
      this.categoryList = result
      /*
       * 细分全部服务
       * */
      this.refineServicesArray = refineServices(this.categoryList)
      AppStorage.setOrCreate('refineServicesArray', this.refineServicesArray)
    }
  }

  aboutToAppear(): void {
    this.getServiceList()
  }

  @Builder
  serviceHead(headName: string) {
    Row({ space: Constants.CONTAINER_SPACE_TEN }) {
      Row()
        .width($r('app.float.service_line_width'))
        .height($r('app.float.service_line_height'))
        .backgroundColor($r('app.color.service_bg'))
      Text(headName).fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
    }
    .margin({ top: $r('app.float.service_header_margin_top'), bottom: $r('app.float.service_header_margin_bottom') })
    .padding({ left: $r('app.float.service_header_padding_left'), right: $r('app.float.service_header_padding_right') })
  }

  build() {
    Column() {
      /*
       * 标题栏
       * */
      ServiceTitle({
        title: $r('app.string.service_title'),
      })
      List() {
        ListItem() {
          Column() {
            Row({ space: Constants.CONTAINER_SPACE_TEN }) {
              Image($r('app.media.search')).width($r('app.float.service_size')).height($r('app.float.service_size'))
              Text($r('app.string.enter_service'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_L'))
            }
            .borderRadius(Constants.RADIUS_TWENTY)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .width(Constants.FULL_PERCENT_WIDTH)
            .padding($r('app.float.service_padding'))
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: $r('app.float.service_margin') })
            .onClick(() => {
              this.pageInfos.pushPathByName('serviceSearch', null)
            })
            .margin({ bottom: $r('app.float.common_margin_nineteen') })

            Image($r('app.media.image')).borderRadius(Constants.RADIUS_TEN)
          }
          .margin({
            bottom: $r('app.float.common_margin_sixty'),
            left: 12,
            right: 12,
          })
        }

        ForEach(this.categoryList, (service: ServiceListInfo) => {
          ListItemGroup({ header: this.serviceHead(service.categoryName) }) {
            ServiceItems({
              serviceList: service.serviceList,
            })
          }
        }, (service: ServiceListInfo) => service.categoryId)
      }
      .height(Constants.FULL_PERCENT_HEIGHT)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Start)
    }
  }
}