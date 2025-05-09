import {
  DataStorage,
  RouterPageEnum,
  WebPageParams,
  getDayLabel,
  LocationType,
  DayInfo,
  UserInfoStorage,
  AuthenticationUtil,
  UserInfo,
  ResourceData,
  ResourceInfo,
  City,
  AppRouter,
} from 'common';
import { BaseTabBar, BaseTitle, GlobalDialog } from 'components';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function homePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  vm: HomePageVM = HomePageVM.instance;
  // 设置应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!;
  @Local userInfoStorage: UserInfoStorage =
    PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!
  // 出发地
  @Local departure: string = '';
  // 目的地
  @Local destination: string = '';
  // 出发日期
  @Local departureDate: DayInfo =
    new DayInfo(new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate(), getDayLabel(new Date()));
  @Local weekDay: string = getDayLabel(new Date());
  // banner轮播图数据
  @Local bannerList: ResourceInfo[] = [];
  // 首页底部功能区展示的数据
  @Local homeFunctionalList: ResourceInfo[] = [];
  // 当前选择的航程类型：默认选择单程
  @Local selectedBarIndex: number = 0;

  // 出发地城市
  @Computed
  get dataStorageDepartureCity() {
    return this.dataStorage.departureCity;
  }

  // 目的地城市
  @Computed
  get dataStorageDestinationCity() {
    return this.dataStorage.destinationCity;
  }

  // 出发日期
  @Computed
  get dataStorageDepartureDate() {
    return this.dataStorage.departureDate;
  }

  // 监听出发地城市的选择变化
  @Monitor('dataStorageDepartureCity')
  onDataStorageDepartureCityChange(monitor: IMonitor) {
    this.departure = this.dataStorageDepartureCity?.cityName ?? this.departure;
  }

  // 监听目的地城市的选择变化
  @Monitor('dataStorageDestinationCity')
  onDataStorageDestinationCityChange(monitor: IMonitor) {
    this.destination = this.dataStorageDestinationCity?.cityName ?? this.destination;
  }

  // 监听出发日期的选择变化
  @Monitor('dataStorageDepartureDate')
  onDataStorageDepartureDateChange(monitor: IMonitor) {
    if (this.dataStorageDepartureDate) {
      this.departureDate.year = this.dataStorageDepartureDate.year;
      this.departureDate.month = this.dataStorageDepartureDate.month;
      this.departureDate.date = this.dataStorageDepartureDate.date;
      this.departureDate.weekDay = this.dataStorageDepartureDate.weekDay;

      this.weekDay = getDayLabel(new Date(this.dataStorageDepartureDate.year, this.dataStorageDepartureDate.month - 1,
        this.dataStorageDepartureDate.date));
    }
  }

  @Monitor('selectedBarIndex')
  onChangeSelectedBarIndex(monitor: IMonitor) {
    if (monitor.value()?.now === 1) {
      GlobalDialog.showToast('暂未上线，敬请期待')
      this.selectedBarIndex = 0
    }
  }

  aboutToAppear() {
    // 出发城市 默认选择上海
    let defaultDepartureCity = new City()
    defaultDepartureCity.cityName = '上海'
    defaultDepartureCity.cityId = 'shanghai'
    defaultDepartureCity.cityCode = 'shanghai'
    this.dataStorage.departureCity = defaultDepartureCity
    // 到达城市 默认选择北京
    let defaultDestinationCity = new City()
    defaultDestinationCity.cityName = '北京'
    defaultDestinationCity.cityId = 'beijing'
    defaultDestinationCity.cityCode = 'beijing'
    this.dataStorage.destinationCity = defaultDestinationCity
    this.departure = '上海'
    this.destination = '北京'

    this.initResourceData()
  }
  aboutToDisappear(): void {
    emitter.off(1)
  }

  initResourceData() {
    // 获取预加载的资源文件
    if (AppStorage.get('resourceData')) {
      let resourceData = AppStorage.get('resourceData') as ResourceData
      this.homeFunctionalList = resourceData?.commonServices ?? []
      this.bannerList = resourceData?.bannerServices ?? []
      return
    }

    let event: emitter.InnerEvent = {
      eventId: 1,
    };
    let callback = (eventData: emitter.EventData): void => {
      let resourceData: ResourceData = eventData.data?.resourceData as ResourceData
      this.homeFunctionalList = resourceData?.commonServices ?? []
      this.bannerList = resourceData?.bannerServices ?? []
      AppStorage.setOrCreate('resourceData', resourceData)
    };

    emitter.on(event, callback);
  }

  // 机票预订
  bookFlight() {
    if (this.userInfoStorage.isLogin) {
      AppRouter.push({
        url: 'FlightListPage'
      })
    } else {
      GlobalDialog.showTextDialog({
        title: '关联账号',
        content: '请先关联账号',
        primaryButName: '确定',
        secondaryButName: '取消',
        primaryButAction: async () => {
          // 关闭账号关联弹框
          await GlobalDialog.close()
          // loading弹框
          await GlobalDialog.showLoadingDialog()
          AuthenticationUtil.silentLogin(async (isSuccess: boolean, userInfo: UserInfo) => {
            await GlobalDialog.close()
            // 账号关联登录成功
            if (isSuccess) {
              this.userInfoStorage.isLogin = true;
              this.userInfoStorage.userInfo = userInfo
              AppRouter.push({
                url: 'FlightListPage'
              })
            }
          })
        },
        secondaryButAction: () => {
          GlobalDialog.close()
        },
      })
    }
  }

  @Builder
  FlightBookingView() {
    Column({ space: 16 }) {
      BaseTabBar({
        tabBarList: this.vm.tabBarList,
        currentIndex: this.selectedBarIndex!!,
      });

      Row() {
        Column({ space: 4 }) {
          Text('出发城市')
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          Text(this.departure || '请选择')
            .fontColor(this.departure ? $r('sys.color.ohos_id_color_text_primary') :
            $r('sys.color.ohos_id_color_text_tertiary'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
        }
        .width('40%')
        .justifyContent(FlexAlign.Center)
        .height(64)
        .padding({left: 8, right:8})
        .backgroundColor('#F3F3F3')
        .borderRadius(16)
        .onClick(() => {
          let paramData: Record<string, LocationType | boolean> = {
            'type': LocationType.DEPARTURE,
          }
          AppRouter.push({
            url: 'CitySelectionPage',
            param: paramData
          })
        });

        Image($r('app.media.ic_transfer')).width(36).height(36)
          .onClick(() => {
            if (this.departure && this.destination) {
              let temp = this.departure;
              this.departure = this.destination;
              this.destination = temp;

              if (this.dataStorage.departureCity) {
                this.dataStorage.departureCity.cityName = this.departure
              }
              if (this.dataStorage.destinationCity) {
                this.dataStorage.destinationCity.cityName = this.destination
              }
            }
          });

        Column({ space: 4 }) {
          Text('到达城市')
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          Text(this.destination || '请选择')
            .fontColor(this.destination ? $r('sys.color.ohos_id_color_text_primary') :
            $r('sys.color.ohos_id_color_text_tertiary'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
        }
        .width('40%')
        .justifyContent(FlexAlign.Center)
        .height(64)
        .padding({left: 8, right:8})
        .backgroundColor('#F3F3F3')
        .borderRadius(16)
        .onClick(() => {
          let paramData: Record<string, LocationType | boolean> = {
            'type': LocationType.DESTINATION,
          }
          AppRouter.push({
            url: 'CitySelectionPage',
            param: paramData
          })
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text() {
          Span(`${this.departureDate.month}月${this.departureDate.date}日`)
            .fontSize(20)
            .fontColor($r('sys.color.ohos_id_color_text_primary'));
          Span(' ');
          Span(this.weekDay).fontColor($r('sys.color.ohos_id_color_text_tertiary'));
        };

        Image($r('app.media.ic_right_arrow'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.ohos_id_color_text_tertiary'));
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10 })
      .onClick(() => {
        AppRouter.push({
          url: 'CalendarPage',
        })
      });

      Row() {
        Button('机票预订', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor($r('sys.color.ohos_id_color_emphasize')).width('100%')
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .onClick(() => {
            this.bookFlight()
          });
      }
      .width('100%')
      .margin({ top: 12, bottom: 16 });
    }
    .width('100%')
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
    .padding({ left: 14, right: 14 })
    .shadow(ShadowStyle.OUTER_DEFAULT_XS);
  }

  @Builder
  AdBannerView() {
    // 轮播图
    Swiper() {
      ForEach(this.bannerList, (item: ResourceInfo) => {
        Image(item.imgUrl)
          .width('100%')
          .height(120)
          .draggable(false)
          .onClick(() => {
            const params: WebPageParams = {
              linkUrl: $rawfile('h5page.html'), // item.linkUrl ?? '',
              title: item.name,
            };
            AppRouter.push({
              url: 'WebPage',
              param: params
            })
          });
      });
    }
    .autoPlay(true)
    .interval(3000)
    .loop(true)
    .duration(100)
    .borderRadius(16)
    .itemSpace(0)
    .indicator( // 设置圆点导航点样式
      new DotIndicator()
        .itemWidth(8)
        .itemHeight(8)
        .selectedItemWidth(8)
        .selectedItemHeight(8)
        .color($r('sys.color.ohos_id_color_tertiary'))
        .selectedColor($r('sys.color.white')))
    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
  }

  @Builder
  MultifunctionalArea() {
    Row() {
      ForEach(this.homeFunctionalList, (item: ResourceInfo) => {
        Column({ space: 6 }) {
          Image(item?.imgUrl).width(36).height(36);
          Text(item?.name)
            .fontWeight(FontWeight.Medium)
            .fontSize(12)
        }
        .padding(12)
        .borderRadius(16)
        .backgroundColor(item.bgColor)
        .onClick(() => {
          let fileName = item.id + '.html'
          const params: WebPageParams = {
            linkUrl: $rawfile(fileName), // item.linkUrl ?? '',
            title: item.name ?? '',
          };
          AppRouter.push({
            url: 'WebPage',
            param: params
          })
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .borderRadius(8)
  }

  @Builder
  HomeTitleBuilder() {
    Text('首页')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Bold)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.HomeTitleBuilder()
        }
      })

      List({ space: 16 }) {
        ListItem() {
          this.FlightBookingView()
        }

        ListItem() {
          this.AdBannerView()
        }

        ListItem() {
          this.MultifunctionalArea()
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .margin({ top: 102 })
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.ic_home_bg'), ImageRepeat.NoRepeat)
    .backgroundImageSize(ImageSize.Contain)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}