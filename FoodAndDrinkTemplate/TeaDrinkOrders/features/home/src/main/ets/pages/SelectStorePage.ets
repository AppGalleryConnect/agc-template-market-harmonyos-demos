import {
  Constants,
  HttpCode,
  HttpRequestApi,
  HwMapComp,
  IndexPageRouter,
  MapLocation,
  NavHeaderBar,
  PermissionUtil,
  RouterMap,
  StoreInfo,
  TabBarType,
  Utils,
  WindowModel,
} from 'common'
import { site } from '@kit.MapKit'
import { SelectStoreComp } from '../components/SelectStoreComp'
import { AppStorageV2 } from '@kit.ArkUI'

@Builder
export function SelectStorePageBuilder() {
  SelectStorePage()
}

@ComponentV2
struct SelectStorePage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local searchText: string = ''
  @Local selectIndex: number = 0
  @Local mapHeight: number = Constants.MAP_HEIGHT_DEFAULT
  @Local isExpandMap: boolean = true
  @Local storeInfoList: Array<StoreInfo> = []
  @Local collectStoreList: Array<StoreInfo> = []
  @Local selectStore: MapLocation = new MapLocation()
  @Local searchAddressList: Array<site.Site> = []

  @Computed
  get locations() {
    return this.searchList.map(item => {
      let location = new MapLocation()
      let locationArr = item.coordinates.split(',')
      if (locationArr?.length === 2) {
        location.id = item.id
        location.title = item.name
        location.latitude = Number(locationArr[0])
        location.longitude = Number(locationArr[1])
      }
      return location
    })
  }

  @Computed
  get searchList() {
    return this.storeInfoList.filter(item => !this.searchText || item.name.includes(this.searchText))
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.store_list') })
      Column() {
        Row() {
          Search({ value: $$this.searchText, placeholder: $r('app.string.search') })
            .textFont({ size: $r('sys.float.Body_L') })
            .width(Constants.FULL_SIZE)
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .maxLength(20)
        }
        .height(28)
        .margin({ top: 12, bottom: 12 })
        .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })

        Column() {
          HwMapComp({
            mapHeight: this.mapHeight,
            locations: this.locations,
            showMyLocation: false,
            selectStore: this.selectStore,
          }).margin({ top: 4 })
          Row() {
            Text(this.isExpandMap ? $r('app.string.collapse_map') : $r('app.string.expand_map'))
              .fontSize(8)
              .fontColor($r('sys.color.font_primary'))
            Image(this.isExpandMap ? $r('app.media.ic_up') : $r('app.media.ic_down')).width(16).margin({ left: 8 })
          }.width(Constants.FULL_SIZE).height(24).justifyContent(FlexAlign.Center).onClick(() => {
            if (this.isExpandMap) {
              this.isExpandMap = false
              this.mapHeight = 0
            } else {
              this.isExpandMap = true
              this.mapHeight = Constants.MAP_HEIGHT_DEFAULT
            }


          })
        }

        Column() {
          List({ space: 12 }) {
            ForEach(this.searchList, (item: StoreInfo, index: number) => {
              ListItem() {
                SelectStoreComp({ storeInfo: item, isSelect: this.selectIndex === index })
                  .onClick(() => {
                    if (this.selectIndex === index) {
                      this.pageStack?.popToName(RouterMap.INDEX_PAGE,
                        { index: TabBarType.ORDER, storeId: item.id } as IndexPageRouter)
                    } else {
                      this.selectIndex = index
                      this.selectStore = this.locations.find(location => location.id === item.id)!
                    }
                  })
              }
            }, (item: StoreInfo) => item.id)
          }.layoutWeight(1).scrollBar(BarState.Off)
        }.layoutWeight(1)
        .padding({
          top: 12,
          left: Constants.BORDER_WIDTH,
          right: Constants.BORDER_WIDTH,
          bottom: this.windowModel.getWindowBottomHeight(),
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }.width(Constants.FULL_SIZE).layoutWeight(1)
    }.hideTitleBar(true).onShown(() => {
      Promise.all([PermissionUtil.getLocation(), HttpRequestApi.getStoreList()]).then(res => {
        let myLocation = res[0]
        if (res[1].code === HttpCode.SUCCESS && res[1].data) {
          this.storeInfoList = res[1].data
          this.storeInfoList.forEach(item => {
            item.distance = Utils.getDistanceWithLocation(myLocation, item.coordinates);
            item.distanceStr = Utils.getFmtDistWithLocation(myLocation, item.coordinates);
          })
          this.storeInfoList.sort((a, b) => a.distance - b.distance)
          this.selectStore = this.locations.find(item => item.id === this.storeInfoList[0].id)!
        }
      })
    })
  }
}