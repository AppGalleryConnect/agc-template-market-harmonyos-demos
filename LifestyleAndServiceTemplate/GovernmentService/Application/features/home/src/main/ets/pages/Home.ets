import { ItemInfo, NavigationParams } from 'common';
import { getDataFromJSON } from 'h5';
import { buildSwiperArea } from 'components';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct HomePage {
  bannerInfo: ItemInfo[] = [];
  gridItems: Array<ItemInfo>[] = [];
  tabBarNames: string[] = [];
  hotServiceItems: ItemInfo[] = [];
  @State newsList: string[] = [];
  @State subTabBarIndex: number = 0;
  @StorageLink('mineItem') mineItemList: ItemInfo[] = [];
  @StorageLink('recentlyUsed') recentlyUsed: Set<ItemInfo> = new Set();
  @StorageLink('isLogin') isLogin: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack

  initDateSource() {
    this.bannerInfo = getDataFromJSON<ItemInfo>('HomePage-TopRibbonBanner.json', this);
    this.gridItems = getDataFromJSON<Array<ItemInfo>>('HomePage-MainFunctionalAreaGrid.json', this);
    this.hotServiceItems = getDataFromJSON<ItemInfo>('HomePage-HotService.json', this);
    this.mineItemList = getDataFromJSON<ItemInfo>('HomePage-MineItem.json', this);
    this.tabBarNames = getDataFromJSON<string>('HomePage-TabName.json', this);
    this.newsList = getDataFromJSON<string>('HomePage-NewsList.json', this);
  }

  goSearchPage = () => {
    this.pageInfos.pushPathByName('SearchPage', null)
  }
  goLevel2Page = () => {
    this.pageInfos.pushPathByName('ServiceManage', null)
  }
  goEmptyPage = (title: ResourceStr) => {
    this.pageInfos.pushPathByName('Empty', new NavigationParams(title))
  }
  mainToGoH5 = (info: ItemInfo) => {
    this.goEmptyPage(info.name)
  }

  addRecentlyUsed(info: ItemInfo) {
    this.goEmptyPage(info.name)
    this.recentlyUsed.add(info)
  }

  build() {
    Column() {
      this.buildSearchBar()
      List() {
        ListItem() {
          Column() {
            this.buildTopRibbonBanner()
            this.buildMainAreaSwiper()
            this.buildRollingBulletin()
            buildSwiperArea({
              swiperHeight: '25%',
              isNeedPadding: true,
            })
            this.buildCommonFuncTabs()
            this.buildSpecializedServices()
          }
          .padding({ left: 12, right: 12 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  @Builder
  buildSpecializedServices() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r('app.string.specialized_services'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(27)

      Row() {
        Column() {
          Text($r('app.string.physical_examination_services'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
          Text($r('app.string.physical_examination_services_query'))
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 10 })
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular);
        }
        .width('48%')
        .height(80)
        .borderRadius($r('sys.float.corner_radius_level5'))
        .backgroundImage($r('app.media.home_page_pic15'))
        .backgroundImageSize(ImageSize.Cover)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.goEmptyPage($r('app.string.physical_examination_services')));

        Column() {
          Text($r('app.string.sports_fitness'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
          Text($r('app.string.venue_reservation'))
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 10 })
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular);
        }
        .width('48%')
        .height(80)
        .borderRadius($r('sys.float.corner_radius_level5'))
        .backgroundImage($r('app.media.home_page_pic14'))
        .backgroundImageSize(ImageSize.Cover)
        .padding({ left: 10 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.goEmptyPage($r('app.string.sports_fitness')));
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .margin({ top: 16 })
    .padding(12)
    .borderRadius($r('sys.float.corner_radius_level5'))
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  buildCommonFuncTabs() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          ForEach(this.tabBarNames, (tabBarName: string, idx: number) => {
            Column() {
              Text(`${tabBarName}`)
                .fontColor(this.subTabBarIndex === idx ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                .fontWeight(this.subTabBarIndex === idx ? FontWeight.Bold : FontWeight.Regular)
                .fontSize($r('sys.float.Body_M'))
                .onClick(() => this.subTabBarIndex = idx);
              if (this.subTabBarIndex === idx) {
                Divider()
                  .width(20)
                  .height(2)
                  .color($r('sys.color.comp_background_emphasize'))
                  .strokeWidth(2);
              }
            }.margin({ right: 12 })
          }, (tabBarName: string) => tabBarName);
        }

        buildMoreIconComponent($r('app.string.management'), this.goLevel2Page);
      }
      .height(20)
      .width('100%')

      if (this.subTabBarIndex === 0) {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.hotServiceItems, (itemInfo: ItemInfo) => {
            GridItem() {
              buildMainAreaItem(itemInfo, (itemInfo: ItemInfo) => {
                this.mainToGoH5(itemInfo)
              });
            }
          }, (itemInfo: ItemInfo) => JSON.stringify(itemInfo));
        }
        .margin({ top: 14 })
      }
      if (this.subTabBarIndex === 1) {
        Grid() {
          ForEach(this.mineItemList, (mineItem: ItemInfo) => {
            GridItem() {
              buildMainAreaItem(mineItem, (mineItem: ItemInfo) => {
                this.mainToGoH5(mineItem)
              });
            }
          }, (mineItem: ItemInfo) => JSON.stringify(mineItem));
        }
        .margin({ top: 14 })
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(12)
      }
      if (this.subTabBarIndex === 2) {
        Grid() {
          ForEach(Array.from(this.recentlyUsed), (mineItem: ItemInfo) => {
            GridItem() {
              buildMainAreaItem(mineItem, (mineItem: ItemInfo) => {
                this.mainToGoH5(mineItem)
              });
            }
          }, (mineItem: ItemInfo) => JSON.stringify(mineItem));
        }
        .margin({ top: 14 })
        .columnsTemplate('1fr 1fr 1fr 1fr')
      }
    }
    .margin({ top: 16 })
    .padding({
      left: 18,
      right: 18,
      top: 12,
      bottom: 12,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  buildRollingBulletin() {
    Row() {
      Image($r('app.media.home_page_pic16'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain);
      Swiper() {
        ForEach(this.newsList, (news: string) => {
          Text(news)
            .width('80%')
            .height('100%')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontColor(FontWeight.Regular)
            .onClick(() => {
              this.pageInfos.pushPathByName('H5', new NavigationParams(news, 'news.html'))
            })
        }, (news: string) => news)
      }
      .height(50)
      .autoPlay(true)
      .interval(2500)
      .indicator(false)
      .vertical(true)
      .margin({ left: 8 })
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level5'))
    .backgroundColor($r('sys.color.background_primary'))
    .padding(8)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildMainAreaSwiper() {
    Swiper() {
      ForEach(this.gridItems, (item: ItemInfo[]) => {
        this.buildMainFunctionalAreaGrid(item)
      }, (item: ItemInfo[]) => JSON.stringify(item))
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({
      bottom: 12,
    })
    .padding({
      top: 12,
      bottom: 20,
    })
    .loop(true)
    .indicator(
      Indicator.dot()
        .top('70%')
        .selectedColor($r('sys.color.comp_background_emphasize')),
    )
    .autoPlay(false)
    .interval(1000)
  }

  /**
   * 主功能区栅格
   */
  @Builder
  buildMainFunctionalAreaGrid(item: Array<ItemInfo>) {
    Flex({ justifyContent: FlexAlign.SpaceAround, wrap: FlexWrap.Wrap, alignItems: ItemAlign.Auto }) {
      ForEach(item, (itemInfo: ItemInfo) => {
        Column() {
          buildMainAreaItem(itemInfo, (itemInfo: ItemInfo) => {
            this.addRecentlyUsed(itemInfo)
          })
        }
        .width('25%')
        .padding({ bottom: 13 })
      }, (itemInfo: ItemInfo) => JSON.stringify(itemInfo));
    }
  }

  /**
   * 主功能区banner
   */
  @Builder
  buildTopRibbonBanner() {
    Grid() {
      ForEach(this.bannerInfo, (itemInfo: ItemInfo) => {
        GridItem() {
          Column() {
            Image($r(itemInfo.pic))
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain);
            Text(`${itemInfo.name}`)
              .margin({ top: 5 })
              .textAlign(TextAlign.Center)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontColor(FontWeight.Regular)
          }
          .onClick(() => {
            if (itemInfo.name === '身份码') {
              this.pageInfos.pushPathByName('CodeMock', new NavigationParams(itemInfo.name))
              return
            }
            this.goEmptyPage((itemInfo.name))
          });
        }
      }, (itemInfo: ItemInfo) => JSON.stringify(itemInfo));
    }
    .columnsTemplate('1fr 1fr 1fr')
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  buildSearchBar() {
    Column() {
      this.buildSearchComponent('app.media.home_page_pic12', $r('app.string.searching_for'));
    }.width('100%')
    .padding({
      right: 16,
      left: 16,
    })
  }

  @Builder
  buildSearchComponent(icon: string, message: ResourceStr, buttonName?: ResourceStr) {
    Row() {
      Row() {
        Image($r(icon))
          .width(16)
          .height(16)
          .margin({
            top: 5,
            bottom: 5,
            left: 10,
          })
        Text(message)
          .fontColor('#999999')
          .margin({ left: 5 })
          .fontSize($r('app.integer.text_font_normal'));
      };

      Row({ space: 10 }) {
        Text(buttonName)
          .fontColor($r('sys.color.comp_background_emphasize'))
          .fontSize($r('app.integer.text_font_big'));
        Image($r('app.media.ic_public_scans')).size({ width: 16, height: 16 })
          .onClick(() => {
            // 定义扫码参数options
            let options: scanBarcode.ScanOptions = {
              scanTypes: [scanCore.ScanType.ALL],
              enableMultiMode: true,
              enableAlbum: true,
            };
            try {
              // 可调用getContext接口获取当前页面关联的UIAbilityContext
              scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
                // 解析码值结果跳转应用服务页
                hilog.info(0x0001, '[Scan CPSample]',
                  `Succeeded in getting ScanResult by promise with options, result is ${JSON.stringify(result)}`);
                this.pageInfos.pushPathByName('ScanCodeResult', new NavigationParams(result.originalValue))
              }).catch((error: BusinessError) => {
                hilog.error(0x0001, '[Scan CPSample]',
                  `Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`);
              });
            } catch (error) {
              hilog.error(0x0001, '[Scan CPSample]',
                `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
            }
          })
      }.margin({ right: 20 })
    }
    .width('100%')
    .height(40)
    .borderWidth($r('sys.float.corner_radius_none'))
    .borderColor('#F0F0F0')
    .borderRadius(50)
    .shadow({ radius: 50, color: '#F0F0F0' })
    .backgroundColor($r('sys.color.background_primary'))
    .opacity(1)
    .margin({
      top: 15,
      bottom: 12,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(this.goSearchPage)
  }

  aboutToAppear() {
    this.initDateSource()
  }
}

@Builder
function buildMoreIconComponent(promptMessage: ResourceStr, event?: () => void | undefined) {
  Row() {
    Text(promptMessage)
      .fontColor($r('sys.color.font_secondary'))
      .fontSize($r('sys.float.Body_S'))
      .fontWeight(FontWeight.Regular)
    Image($r('app.media.home_page_pic13'))
      .width(12)
      .height(12)
      .objectFit(ImageFit.Cover);
  }
  .alignItems(VerticalAlign.Center)
  .onClick(event);
}

@Builder
function buildMainAreaItem(itemInfo: ItemInfo, event: (itemInfo: ItemInfo) => void) {
  Column() {
    Image($r(itemInfo.pic))
      .width(40)
      .height(40)
    Text(itemInfo.name)
      .margin({ top: 5 })
      .textAlign(TextAlign.Center)
      .fontSize($r('sys.float.Body_S'))
      .fontColor($r('sys.color.font_primary'))
      .fontColor(FontWeight.Regular)
  }
  .onClick(() => {
    event(itemInfo)
  });
}
