import { getDataFromJSON } from 'h5';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LeftTab, LeftTabContent, NavigationParams, RequestPermission, SubTabContent, TabData } from 'common';

@Component
export struct OfficePage {
  @StorageLink('selectedCity') selectedCity: ResourceStr = $r('app.string.please_select');
  @Consume('pageInfos') pageInfos: NavPathStack
  private requestPermission: RequestPermission = new RequestPermission()
  @State activateIndex: number = 1;
  @State selectedLeft: number = 0;
  @State selectedClassify: number = 0;
  @State tabDataList: Array<TabData> = [];
  @State leftTabList: Array<LeftTab> = [];
  @State leftTabContentList: Array<LeftTabContent> = [];
  private ERROR_INFO = $r('app.string.repositioning')

  /**
   * 初始化数据
   */
  initDataSource() {
    this.tabDataList = getDataFromJSON<TabData>('OfficePage-TabDataList.json', this);
    this.leftTabList = this.tabDataList[0].leftTabList;
    this.leftTabContentList = this.tabDataList[0].leftTabList[0].leftTabContentList;
  }

  goSiteListPage = () => {
    this.pageInfos.pushPathByName('SiteList', null)
  }
  goSearchPage = () => {
    this.pageInfos.pushPathByName('SearchPage', null)
  }

  // 获取当前经纬度信息，并坐标转化地理位置信息
  async getCurrentLocationInfo() {
    const requestInfo: geoLocationManager.CurrentLocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
      'timeoutMs': 3000,
    };

    try {
      console.log('TAG getCurrentLocation')
      const location = await geoLocationManager.getCurrentLocation(requestInfo);
      AppStorage.setOrCreate('latitude', location.latitude);
      AppStorage.setOrCreate('longitude', location.longitude);

      // 坐标转化地理位置信息
      await this.getLocationAddress(location.latitude, location.longitude);
    } catch (err) {
      console.error(`Failed to get current location. Code is ${err.code}, message is ${err.message}`);
    }
  }

  // 坐标转化地理位置信息
  async getLocationAddress(latitude: number, longitude: number) {
    let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
      'latitude': latitude,
      'longitude': longitude,
      'maxItems': 1,
    };

    try {
      // 调用 getAddressesFromLocation，坐标转化地理位置信息
      let result = await geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest);
      this.selectedCity = result[0].locality === undefined ? this.ERROR_INFO : result[0].locality;
      AppStorage.setOrCreate('city', result[0].locality);
    } catch (err) {
      this.selectedCity = this.ERROR_INFO;
      console.error('errCode:' + (err as BusinessError).code + ',errMessage:' + (err as BusinessError).message);
    }
  }

  build() {
    Column() {
      // 构建位置选择区、自定义搜索组件
      this.buildSearchWithLocationSelect()
      this.buildOfficeTabs()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .padding({ bottom: 200 })
  }

  @Builder
  buildSearchWithLocationSelect() {
    Column() {
      // 自定义搜索组件
      this.buildSearchComponent('app.media.office_page_pic2', $r('app.string.lookup_service'), $r('app.string.search'));
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      left: 16,
      right: 16,
      top: Number(AppStorage.get('topRectHeight')),
      bottom: 8,
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildLocationSelectZone() {
    Row() {
      Text(this.selectedCity)
        .fontColor($r('sys.color.font_primary'))
        .margin({ right: 4 })
        .fontSize($r('sys.float.Body_S'))
      Image($r('app.media.down_arrow'))
        .width(16)
        .height(16)
        .objectFit(ImageFit.Cover);
    }
    .margin({ top: 18, right: 10 })
    .onClick(this.goSiteListPage)
  }

  @Builder
  buildSearchComponent(icon: string, message: ResourceStr, buttonName: ResourceStr) {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      // 位置选择区
      this.buildLocationSelectZone();
      Row() {
        Row() {
          Image($r(icon))
            .width(13)
            .height(13)
            .margin({
              top: 5,
              bottom: 5,
              left: 10,
            })
          Text(message)
            .fontColor('#999999')
            .margin({ left: 5 })
            .fontSize($r('app.integer.text_font_normal'))
        };

        Text(buttonName)
          .fontColor('#58a8ff')
          .margin({ right: 10 })
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'));
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius(8)
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .onClick(this.goSearchPage)
      .flexGrow(1)
    }
    .height(40)
    .margin({
      top: 15,
      bottom: 12,
    })

  }

  @Builder
  buildOfficeTabs() {
    // 构建tabBar
    this.buildTabBar();

    // 左侧tabBar+tabContent
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      this.buildLeftTabBar();
      this.buildLeftTabContentView();
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabDataList, (tabData: TabData) => {
        this.buildCustomTabBar(tabData);
      }, (tabData: TabData) => JSON.stringify(tabData));
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  buildLeftTabBar() {
    List() {
      ForEach(this.leftTabList, (leftTab: LeftTab, idx: number) => {
        ListItem() {
          Text(leftTab.leftTabName)
            .width('100%')
            .backgroundColor(this.selectedLeft === idx ? $r('sys.color.background_primary') :
            $r('sys.color.background_secondary'))
            .borderRadius({
              topLeft: 16,
              topRight: 0,
              bottomRight: 0,
              bottomLeft: 16,
            })
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(this.selectedLeft === idx ? FontWeight.Bold : FontWeight.Regular)
            .padding(15)
            .fontSize($r('sys.float.Body_M'))
            .onClick(() => this.refreshRightDate(leftTab, idx));
        }
        .width('100%');
      }, (leftTab: LeftTab) => JSON.stringify(leftTab));
    }
    .width('35%')
  }

  @Builder
  buildLeftTabContentView() {
    if (this.leftTabContentList?.length > 0) {
      List() {
        ForEach(this.leftTabContentList, (leftTabContent: LeftTabContent) => {
          ListItem() {
            Column() {
              Text(leftTabContent.title)
                .borderWidth({ left: 2 })
                .fontColor($r('sys.color.font_primary'))
                .margin({ top: 19, left: 10 })
                .padding({ left: 5 })
                .fontWeight(FontWeight.Bold)
                .fontSize($r('sys.float.Body_M'))
              ForEach(leftTabContent.list, (subTabContent: SubTabContent) => {
                Row() {
                  Image($r(subTabContent.icon))
                    .width(24)
                    .height(24)
                    .objectFit(ImageFit.Cover);
                  Text(`${subTabContent.text}`)
                    .width('75%')
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                  Image($r('app.media.office_page_pic3'))
                    .width(16)
                    .height(16)
                    .objectFit(ImageFit.Cover)
                    .margin({ right: 12 });
                }
                .width('100%')
                .margin({ top: 22 })
                .padding({ left: 20 })
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(() => {
                  this.pageInfos.pushPathByName('Empty', new NavigationParams(subTabContent.text))
                })
              }, (subTabContent: SubTabContent) => JSON.stringify(subTabContent));
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%');
        }, (leftTabContent: LeftTabContent) => JSON.stringify(leftTabContent));
      }
      .height('100%')
      .flexGrow(1)
      .borderRadius({
        topLeft: 0,
        topRight: 16,
        bottomRight: 16,
        bottomLeft: 16,
      })
      .backgroundColor($r('sys.color.background_primary'))
      .padding({ bottom: 20 })
    } else {
      Column() {
        // 如果没有办事项，做个提示。
        Text($r('app.string.no_service'))
          .height(30)
          .fontColor(Color.Black)
          .padding({ left: 19 })
          .fontSize($r('app.integer.text_font_small'))

      }
      .borderRadius({
        topLeft: 0,
        topRight: 16,
        bottomRight: 16,
        bottomLeft: 16,
      })
      .height('100%')
      .width('100%')
      .flexGrow(1)
      .backgroundColor($r('sys.color.background_primary'))
    }
  }

  @Builder
  buildCustomTabBar(tabData: TabData) {
    Column() {
      Text(`${tabData.tabName}`)
        .fontColor(this.selectedClassify === tabData.tabIndex ? $r('sys.color.font_on_primary') :
        $r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium);
    }
    .margin({ bottom: 10, top: 10 })
    .backgroundColor(this.selectedClassify === tabData.tabIndex ? '#007DFD' : $r('sys.color.comp_background_tertiary'))
    .padding({
      left: 22,
      right: 22,
      top: 9,
      bottom: 9,
    })
    .borderRadius(21)
    .onClick(() => this.refreshLeftAndRightDate(tabData))
  }

  refreshLeftAndRightDate(tabData: TabData) {
    this.leftTabList = tabData.leftTabList;
    this.selectedClassify = tabData.tabIndex;
    this.selectedLeft = 0;
    this.leftTabContentList =
      tabData.leftTabList.length > 0 ? tabData.leftTabList[this.selectedLeft].leftTabContentList : [];
  }

  refreshRightDate(leftTab: LeftTab, index: number) {
    this.selectedLeft = index;
    this.leftTabContentList = leftTab.leftTabContentList;
  }

  aboutToAppear() {
    this.initDataSource();
    this.requestPermission.checkLocationPermission().then((data) => {
      if (data === 'pass') {
        this.getCurrentLocationInfo();
      }
    })
  }
}