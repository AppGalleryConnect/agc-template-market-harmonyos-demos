import { ServiceEntryItem , SwiperBanner} from '../../types/Types'
import { SERVICE_ENTRY_LIST, SWIPER_BANNER } from '../../constants/Constants'
import { TitleBarView } from '@ohos_agcit/car_beauty_care_componentlib'
import { PackagesCardView, PackageVM, PackageCardModel } from '@ohos_agcit/car_beauty_care_package'
import { ShowCardView, LocationVM } from '@ohos_agcit/car_beauty_care_shop'
import { site } from '@kit.MapKit';
import { CityCallBack } from '@ohos_agcit/car_beauty_care_cityselect'
import { CommonModel, CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@ComponentV2
export struct HomeView {
  vm: CommonModel = CommonModel.instance;
  locationVM: LocationVM = LocationVM.instance;
  packageVM: PackageVM = PackageVM.instance;
  scroller:Scroller = new Scroller();
  topRectHeight: number = 0;
  bottomRectHeight: number = 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();

  @Builder
  serviceEntry(item:ServiceEntryItem, index:number) {
    Column() {
      Image(item.icon)
        .height(index%2 === 0?40:25)
        .margin({
          bottom:4
        })

      Text(item.label)
        .fontColor('#000')
        .fontSize(12)
    }
    .onClick(() => {
      if (item.tabIndex === 7) {
        this.appPathStack.pushPathByName('appointmentView', true)
      } else {
        this.vm.curIndex = 1;
        this.vm.secondTabIndex = item.tabIndex;
      }
    })
  }

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.vm.getLocationName().then((address: string) => {
      try {
        if (address) {
          const name = address || this.locationVM.locationName;
          this.locationVM.updataLocationName(name)
        }
      } catch (e) {
        console.log(JSON.stringify(e))
      }
    });
  }

  @Styles cardStyle() {
    .backgroundColor('#fff')
    .borderRadius(16)
  }

  updateLocationName: (cityName: string | Resource) => void = (cityName: string | Resource) => {
    this.locationVM.updataLocationName(cityName)
  }

  getLocationName: () => string | Resource = () => {
    return this.locationVM.locationName;
  }

  build() {
    Stack({alignContent: Alignment.TopStart}) {
      RelativeContainer() {
        Image($r('app.media.bg'))
          .width(CommonConstants.FULL_WIDTH)
          .height(220)

        // 顶部banner
        Row() {
          Text(this.locationVM.locationName)
            .margin({
              left:16
            })

          Image($r('app.media.arrow_bottom'))
            .width(24)
            .height(24)
        }
        .height(36)
        .margin({
          top:px2vp(this.topRectHeight) + 10,
          left:16
        })
        .padding({
          right:8
        })
        .alignItems(VerticalAlign.Center)
        .id('areaPicker')
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(20)
        .onClick(() => {
          const param: CityCallBack = {updateLocationName:this.updateLocationName,
            getLocationName: this.getLocationName}
          this.appPathStack.pushPathByName('cityselect', param)
        })

        Scroll(this.scroller) {
          Column({space:12}) {
            Column({space: 12}) {
              // 服务入口
              List() {
                ForEach(SERVICE_ENTRY_LIST, (item:ServiceEntryItem, index:number) => {
                  ListItem() {
                    this.serviceEntry(item, index)
                  }
                  .width('25%')
                })
              }
              .listDirection(Axis.Horizontal)
              .lanes(2)
              .width(CommonConstants.FULL_WIDTH)
              .height(160)
              .padding({
                top:16,
              })
              .cardStyle()

              // 轮播广告
              Swiper() {
                ForEach(SWIPER_BANNER,(item:SwiperBanner) => {
                  Image(item.imgUrl)
                    .width(CommonConstants.FULL_WIDTH)
                    .height(CommonConstants.FULL_HEIGHT)
                    .onClick(() => {
                      this.appPathStack.pushPathByName('atomicWeb',item.href)
                    })
                })
              }
              .loop(true)
              .autoPlay(true)
              .height(72)
              .cardStyle()

              // 附近好店
              Column() {
                TitleBarView({
                  title: $r('app.string.near_good_shop'),
                  routePath: 'shop',
                  showRight: true,
                })
                  .margin({
                    bottom:16
                  })

                ShowCardView({
                  card:this.locationVM.nearByGoodShop
                })
              }
              .width(CommonConstants.FULL_WIDTH)
              .padding({
                top:24,
                bottom:16,
                left: 16,
                right: 16
              })
              .cardStyle()

              Column() {
                TitleBarView({
                  title: $r('app.string.recommended_packages'),
                  routePath: 'package',
                  showRight: true,
                })
                  .margin({
                    bottom:16
                  })

                List({space:12}) {
                  ForEach(this.packageVM.packageData.slice(0,3), (item:PackageCardModel) => {
                    ListItem() {
                      PackagesCardView({
                        card: item
                      })
                    }
                  })
                }
              }
              .cardStyle()
              .padding({
                top: 24,
                left: 12,
                right: 12,
                bottom: 12,
              })

            }
            .width(CommonConstants.FULL_WIDTH)
            .padding({
              top:10,
              bottom:10,
              left: 16,
              right: 16
            })
          }
          .width(CommonConstants.FULL_WIDTH)
          .backgroundColor(Color.Transparent)
        }
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .alignRules({
          top:{anchor:'areaPicker', 'align': VerticalAlign.Bottom}
        })
        .margin({
          top:10,
          bottom: 76
        })
      }
    }
    .backgroundColor('#eee')
  }
}


