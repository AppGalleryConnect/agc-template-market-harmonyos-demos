import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BaseTitle } from '../components/BaseTitle';
import { AppRouter,
  checkLocationEnabled,
  City, CityDataModel, CityType, DataStorage,
  getAddressInfo,
  LocationType, PermissionUtil } from 'common';

@Builder
export function citySelectionPageBuilder() {
  CitySelectionPage()
}

@ComponentV2
export struct CitySelectionPage {
  @Local filterDataList: string[] = []
  @Local cityTableList: CityType[] = []
  @Local selectedIndex: number = 0
  @Local showIndexer: boolean = false
  scroller: ListScroller = new ListScroller()
  listScroller: ListScroller = new ListScroller()
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!
  @Local offsetY: number = 0
  @Local gridCityList: City[] = []
  @Local letterList: string[] = []
  @Local location: LocationType = LocationType.DEPARTURE
  @Local isFlightSearch: boolean = false
  @Local userGrant: boolean = false
  @Local isLocationEnabled: boolean = false
  // 定位中
  @Local isPositioning: boolean = false

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    this.cityTableList = CityDataModel.getCityData()

    this.gridCityList = CityDataModel.getHotCityList()

    this.letterList = CityDataModel.getLetterList()
  }

  // 申请地理位置权限
  async requestLocationPermission(): Promise<boolean> {
    let userGrant: boolean = await PermissionUtil.checkPermissions(this.context,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']);
    return userGrant
  }

  // 获取定位城市
  queryLocationCity() {
    try {
      getAddressInfo().then((city: string) => {
        this.dataStorage.curCity = city;
      }).finally(() => {
        this.isPositioning = false
      })
    } catch (err) {
      this.isPositioning = false
    }
  }

  // 拉起系统位置权限页面
  startLocationSetting() {
    this.context.startAbility({
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'location_manager_settings',
      parameters: {
        pushParams: {
          // 应用包名
          bundleName: this.context.abilityInfo.bundleName,
        },
      },
    })
  }

  @Builder
  CurrentCityView() {
    Column({ space: 10 }) {
      Text('当前定位城市').fontSize(16).fontWeight(FontWeight.Medium)

      Row() {
        if (this.dataStorage.curCity) {
          Row({ space: 4 }) {
            Image($r('app.media.ic_location')).width(14).height(14)
            Text(this.dataStorage.curCity).fontSize(12)
          }
          .width('calc((100% - 24vp) / 4)')
          .height('calc((180vp - 32vp) / 5)')
          .backgroundColor('#fff1f7fa')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.isFlightSearch) {
              AppRouter.pop(this.dataStorage.curCity)
            } else {
              let selectedCity: City = new City()
              selectedCity.cityId = (this.dataStorage.curCity ?? '') + '_id'
              selectedCity.cityName = this.dataStorage.curCity ?? ''
              selectedCity.cityCode = (this.dataStorage.curCity ?? '') + '_Code'
              if (this.location === LocationType.DEPARTURE) {
                this.dataStorage.departureCity = selectedCity
              } else if (this.location === LocationType.DESTINATION) {
                this.dataStorage.destinationCity = selectedCity
              }
              AppRouter.pop()
            }
          })
        } else {
          Row({ space: 4 }) {
            if (this.isPositioning) {
              LoadingProgress().width(12).height(12).color('#9900000')
            }
            Text(this.isPositioning ? '定位中' :
              (this.isLocationEnabled ? '定位失败，请检查定位权限' : '定位失败，请检查定位服务'))
              .fontSize(12)
          }
          .height('calc((180vp - 32vp) / 5)')
          .padding({ left: 14, right: 14 })
          .backgroundColor('#fff1f7fa')
          .justifyContent(FlexAlign.Center)
          .onClick(async () => {
            if (this.isLocationEnabled) {
              // 有权限
              this.userGrant = await this.requestLocationPermission()
              if (this.userGrant) {
                this.isPositioning = true
                // 获取地址信息
                this.queryLocationCity()
              } else {
                // 拉起系统位置权限页面
                this.startLocationSetting()
              }
            } else {
              this.startLocationSetting()
            }
          })
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HotCityView() {
    Column({ space: 10 }) {
      Text('热门城市').fontSize(16).fontWeight(FontWeight.Medium)

      Grid() {
        ForEach(this.gridCityList, (item: City) => {
          GridItem() {
            Row() {
              Text(item.cityName).fontSize(12)
            }
            .width('100%')
            .backgroundColor('#fff1f7fa')
            .padding({ top: 6, bottom: 6 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.isFlightSearch) {
                AppRouter.pop(item.cityName)
              } else {
                if (this.location === LocationType.DEPARTURE) {
                  this.dataStorage.departureCity = item
                } else if (this.location === LocationType.DESTINATION) {
                  this.dataStorage.destinationCity = item
                }
                AppRouter.pop()
              }
            })
          }
        })
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .layoutDirection(GridDirection.Row)
      .columnsGap(8)
      .rowsGap(8)
      .backgroundColor($r('sys.color.white'))
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ChooseCityByLetterView() {
    Column({ space: 10 }) {
      Text('字母索引').fontSize(16).fontWeight(FontWeight.Medium)

      Grid() {
        ForEach(this.letterList, (item: string) => {
          GridItem() {
            Row() {
              Text(item).fontSize(12)
            }
            .width('100%')
            .backgroundColor('#fff1f7fa')
            .padding({ top: 6, bottom: 6 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              let scrollIndex: number = this.letterList.findIndex((letter: string) => letter === item)
              this.scroller.scrollToIndex(3, true)
              this.listScroller.scrollToItemInGroup(scrollIndex, 0, true)
              this.selectedIndex = scrollIndex
              this.offsetY = 0
              this.showIndexer = true
            })
          }
        }, (item: string) => item)
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .layoutDirection(GridDirection.Row)
      .columnsGap(8)
      .rowsGap(8)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  itemHead(text: string) {
    Text(text)
      .backgroundColor('#fff')
      .width('100%')
      .fontWeight(FontWeight.Bold)
      .padding({ top: 12 })
  }

  build() {
    NavDestination() {
      BaseTitle({
        title: '选择城市',
        showBackBtn: true,
        onBack: () => {
          AppRouter.pop()
        },
      })

      Stack({ alignContent: Alignment.TopEnd }) {
        List({ space: 24, scroller: this.scroller }) {
          ListItem() {
            this.CurrentCityView()
          }

          ListItem() {
            this.HotCityView()
          }

          ListItem() {
            this.ChooseCityByLetterView()
          }

          ListItem() {
            List({ scroller: this.listScroller }) {
              ForEach(this.cityTableList, (item: CityType) => {
                ListItemGroup({ header: this.itemHead(item.name) }) {
                  ForEach(item.cityList, (city: string) => {
                    ListItem() {
                      Text(city)
                        .width('100%')
                        .height(48)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .onClick(() => {
                          if (this.isFlightSearch) {
                            AppRouter.pop(city)
                          } else {
                            let checkCity: City = new City()
                            checkCity.cityId = 'id_' + city
                            checkCity.cityCode = 'code_' + city
                            checkCity.cityName = city
                            if (this.location === LocationType.DEPARTURE) {
                              this.dataStorage.departureCity = checkCity
                            } else if (this.location === LocationType.DESTINATION) {
                              this.dataStorage.destinationCity = checkCity
                            }
                            AppRouter.pop()
                          }
                        })
                    }
                  })
                }
                .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
              })
            }
            .width('100%')
            .height('100%')
            .sticky(StickyStyle.Header)
            .scrollBar(BarState.Off)
            .padding({ right: 20 })
            .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST,
            })
            .edgeEffect(EdgeEffect.None)
            .onScrollVisibleContentChange((start: VisibleListContentInfo, end: VisibleListContentInfo) => {
              // 向下滑动
              if (this.offsetY > 0) {
                let selectItemIndexer = this.cityTableList[start.index].name
                this.selectedIndex = this.letterList.findIndex((item: string) => item === selectItemIndexer)
              }
              // 向上滑动
              if (this.offsetY < 0) {
                let lastIndex: number = this.cityTableList[start.index].cityList.length - 1
                if (start.itemIndexInGroup === lastIndex && start.itemGroupArea === 1) {
                  let selectItemIndexer = this.cityTableList[start.index].name
                  this.selectedIndex = this.letterList.findIndex((item: string) => item === selectItemIndexer)
                }
              }
              if (this.offsetY !== 0) {
                // 是否显示字母索引组件
                this.showIndexer = start.index > 0 || (start.index === 0 && start.itemIndexInGroup !== undefined)
              }
            })
            .onScrollFrameBegin((offset: number, state: ScrollState) => {
              this.offsetY = offset
              return { offsetRemain: offset }
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .height('calc(100% - 60vp)')
        .padding({ left: 14, right: 14 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)

        Column() {
          AlphabetIndexer({ arrayValue: this.letterList, selected: this.selectedIndex })
            .selectedFont({ size: 12 })
            .selectedColor('#fff')
            .selectedBackgroundColor('#191919')
            .usingPopup(false)// 是否显示弹出框
            .itemSize(16)
            .onSelect((index: number) => {
              let selectIndexer = this.letterList[index]
              let idx = this.cityTableList.findIndex((item: CityType) => item.name === selectIndexer)
              this.listScroller.scrollToItemInGroup(idx, 0, true)
              this.offsetY = 0
              this.showIndexer = true
            })

          Image($r('app.media.ic_back_top'))
            .width(34).height(34)
            .offset({ x: -10, y: 40 })
            .onClick(() => {
              this.listScroller.scrollToItemInGroup(0, 0)
              this.scroller.scrollToIndex(0, true)
              this.offsetY = 0
              this.showIndexer = false
            })
        }
        .visibility(this.showIndexer ? Visibility.Visible : Visibility.Hidden)
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((cxt) => {
      let params = cxt.pathInfo.param as Record<string, LocationType | boolean>
      this.location = params.type as LocationType ?? LocationType.DEPARTURE
      this.isFlightSearch = !!params.isFlightSearch
    })
    .onWillShow(async () => {
      this.isLocationEnabled = checkLocationEnabled()
      // 申请地理位置权限获取定位城市
      this.userGrant = await this.requestLocationPermission()
      if (this.userGrant && this.isLocationEnabled) {
        this.isPositioning = true
        // 获取地址信息
        this.queryLocationCity()
      }
    })
    .onShown(() => {
      this.isLocationEnabled = checkLocationEnabled()
    })
  }
}