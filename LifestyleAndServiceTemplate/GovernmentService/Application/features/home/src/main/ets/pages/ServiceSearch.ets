import { DividerTmp, NavigationParams, ServiceList, TabData } from 'common'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { getDataFromJSON } from 'h5'

@Component
export struct ServiceSearch {
  @State searchValue: string = ''
  @State refineServicesArray: ServiceList[] = []
  @State refineServicesArrayOrigin: ServiceList[] = []
  @State egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Consume('pageInfos') pageInfos: NavPathStack
  controller: SearchController = new SearchController()

  aboutToAppear(): void {
    this.refineServicesArray = getDataFromJSON<ServiceList>('Service_All.json', this);
    this.refineServicesArrayOrigin = JSON.parse(JSON.stringify(this.refineServicesArray))
  }

  serviceSearch(searchValue: string) {
    if (this.searchValue !== '') {
      this.refineServicesArray = this.refineServicesArray.filter(value => value.text.includes(searchValue))
    } else {
      this.refineServicesArray = this.refineServicesArrayOrigin
    }
  }

  @Builder
  searchCard(item: ServiceList) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 10 }) {
        Image($r(item.icon)).width(24).height(24)
        Text(item.text)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
      }

      Image($r('app.media.about_more')).width(14).height(14)
    }
    .height(40)
  }

  build() {
    NavDestination() {
      Column() {
        Search({
          value: this.searchValue,
          placeholder: $r('app.string.service_search_placeholder'),
          controller: this.controller,
        })
          .backgroundColor('#E5E7E8')
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
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
              this.pageInfos.pushPathByName('Empty', new NavigationParams(item.text))
            })
          }, (item: ServiceList) => item.text)
        }
        .divider(this.egDivider)
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius(16)
        .padding(12)
        .scrollBar(BarState.Off)
      }
      .padding({ left: 16, right: 16 }).backgroundColor($r('sys.color.background_secondary'))
    }.title('服务搜索').padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}
