import { Constants, DividerTmp, NavigationParams, ServiceList, ServiceListEnum } from 'common'
import { SymbolGlyphModifier } from '@kit.ArkUI'

@ComponentV2
export struct ServiceSearch {
  @Local searchValue: string = ''
  @Local refineServicesArray: ServiceList[] = []
  @Local refineServicesArrayOrigin: ServiceList[] = []
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  controller: SearchController = new SearchController()

  aboutToAppear(): void {
    this.refineServicesArray = AppStorage.get('refineServicesArray') ?? []
    this.refineServicesArrayOrigin = JSON.parse(JSON.stringify(this.refineServicesArray))
  }

  serviceSearch(searchValue: string) {
    if (this.searchValue !== '') {
      this.refineServicesArray = this.refineServicesArray.filter(value => value.name.includes(searchValue))
    } else {
      this.refineServicesArray = this.refineServicesArrayOrigin
    }
  }

  @Builder
  searchCard(item: ServiceList) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: Constants.CONTAINER_SPACE_TEN }) {
        Image(item.icon).width($r('app.float.service_title_size')).height($r('app.float.service_title_size'))
        Text(item.name)
      }

      Image($r('app.media.about_more')).width($r('app.float.service_more')).height($r('app.float.service_more'))
    }
    .height($r('app.float.service_height'))
  }

  build() {
    NavDestination() {
      Column() {
        Search({ value: this.searchValue, placeholder: $r('app.string.enter_service'), controller: this.controller })
          .backgroundColor($r('app.color.service_search'))
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: Constants.FONT_SIZE_SMALL })
          .onChange((value: string) => {
            this.searchValue = value
            this.serviceSearch(value)
          })
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')),
          })
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({
            size: $r('sys.float.Body_L'),
          })
        List() {
          ForEach(this.refineServicesArray, (item: ServiceList) => {
            ListItem() {
              this.searchCard(item)
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
              } else if (item.serviceId === ServiceListEnum.NotAvailable) {
                this.pageInfos.pushPathByName('notAvailable', new NavigationParams(item.name))
                return
              } else if (item.serviceId === ServiceListEnum.MakeAppointment) {
                this.pageInfos.pushPathByName('reservation', new NavigationParams(item.name))
                return
              }
              this.pageInfos.pushPathByName('web', new NavigationParams(item.name, loadUrl))
            })
            .margin({ top: $r('app.float.drug_inquiry_list_margin') })
          }, (item: ServiceList) => item.name)
        }
        .divider(this.egDivider)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .padding({ left: $r('app.float.common_padding_ten'), right: $r('app.float.common_padding_ten') })
    }.title('服务搜索').padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}
