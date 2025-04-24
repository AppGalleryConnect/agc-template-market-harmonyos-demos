import { Constants, NavigationParams, ServiceList, ServiceListEnum } from 'common';

@ComponentV2
export struct ServiceItems {
  @Param serviceList: ServiceList[] = []
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Grid() {
        ForEach(this.serviceList, (item: ServiceList) => {
          GridItem() {
            Column({ space: Constants.CONTAINER_SPACE_TEN }) {
              Image(item.icon)
                .width($r('app.float.service_card_icon_width'))
                .height($r('app.float.service_card_icon_height'))
              Text(item.name)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular)
            }
          }
          .onClick(() => {
            //   跳转到对应的h5页面
            let loadUrl = 'visit.html'
            if (item.serviceId === ServiceListEnum.InsuranceInformation) {
              loadUrl = 'person.html'
            } else if (item.serviceId === ServiceListEnum.AccountDetails) {
              loadUrl = 'visit.html'
            } else if (item.serviceId === ServiceListEnum.DesignatedHospital ||
              item.serviceId === ServiceListEnum.HealthcareMap) {
              this.pageInfos.pushPathByName('business', new NavigationParams(item.name))
              return
            } else if (item.serviceId === ServiceListEnum.NotAvailable ||
              item.serviceId === ServiceListEnum.MakeAppointment) {
              this.pageInfos.pushPathByName('notAvailable', new NavigationParams(item.name))
              return
            }
            this.pageInfos.pushPathByName('web', new NavigationParams(item.name, loadUrl))
          })
        }, (item: ServiceList) => item.name)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(20)
      .rowsGap(15)
      .layoutDirection(GridDirection.Row)
      .padding({ bottom: $r('app.float.service_card_padding_bottom') })

      Divider().strokeWidth(10).color($r('sys.color.background_primary'))
    }
  }
}