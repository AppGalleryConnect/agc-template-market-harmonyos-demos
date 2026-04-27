/**
 * @usage: 酒店预订页面，提供酒店搜索和预订功能，支持国内/海外、钟点房、民宿三种模式切换，支持城市选择、日期选择、位置定位
 * @layout: 页面整体采用Stack布局，背景图片在底层，上方是返回按钮和酒店tabs切换卡片，卡片内包含模式切换、
 * 定位权限提示、城市选择、日期选择、查询按钮
 * @constraints: chooseStatus控制当前模式（Domestic国内、Overseas海外、Hourly钟点房、Homestay民宿）；
 * hotelDateModel管理入住和离店日期
 * @isGen: true
 * @fileType: page
 * @zhName: 酒店预订
 * @domain: 旅游
 * @subPage: SearchHotelPage,HotelListPage
 */
import { BarVM, BreakpointModel, getCurrentCityInfo, GlobalContext, PermissionUtil, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { ChooseStatus, HotelPageVM } from '../viewmodel/HotelPageVM'
import { SearchHotelPageBuilder } from './SearchHotelPage'
import { common, Permissions } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { HotelListPageBuilder } from './HotelListPage'
import { DialogType, SwiperDirection, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker'
import { HotelDateModel } from 'common_travel_guide'
import { OVERSEAS_CITY_LIST_SAMPLE } from 'city_select'
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting'


export interface HotelPageParam {
  hotelPageVM: HotelPageVM
  hotelDateModel: HotelDateModel
}

@Builder
export function HotelPageBuilder() {
  HotelPage()
}

@ComponentV2
export struct HotelPage {
  vm: HotelPageVM = new HotelPageVM()
  logTag: string = 'HotelPage';
  @Local today: Date = new Date()
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  @Event paramChangeCallback: (data: HotelDateModel) => void = () => {
  };

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  aboutToAppear(): void {
    this.isCheckPermission()
  }

  // 检查是否开启定位权限
  isCheckPermission() {
    PermissionUtil.checkPermissionGrant('ohos.permission.LOCATION').then((res) => {
      if (res === -1) {
        this.vm.locationPermission = false
      } else {
        getCurrentCityInfo().then((city) => {
          this.vm.currentCity = city?.locality as string
          this.vm.placeName = city?.placeName as string
        })
        this.vm.locationPermission = true
      }
    })
  }

  // 开启定位权限操作
  checkPermission() {
    let permission: Permissions = 'ohos.permission.LOCATION'
    PermissionUtil.checkPermissions(permission).then(() => {
      getCurrentCityInfo().then((city) => {
        this.vm.currentCity = city?.locality as string
        this.vm.placeName = city?.placeName as string
      })
      if (this.vm.chooseStatus === ChooseStatus.Overseas) {
        this.vm.chooseStatus = ChooseStatus.Domestic
      }
      this.vm.locationPermission = true
      this.vm.showLocation = true
    }).catch((err: BusinessError) => {
      this.checkPermissionGrant()
    })
  }

  checkPermissionGrant() {
    PermissionUtil.checkPermissionGrant('ohos.permission.LOCATION').then((res) => {
      if (res === -1) {
        promptAction.openCustomDialog({
          builder: () => {
            this.CustomDialog('需要获取您的位置才能提供服务，请在系统设置中开启权限', () => {
              let context = getContext(this) as common.UIAbilityContext;
              context.startAbility({
                bundleName: 'com.huawei.hmos.settings',
                abilityName: 'com.huawei.hmos.settings.MainAbility',
                uri: 'application_info_entry',
                parameters: {
                  pushParams: 'com.huawei.travelguide'  // 替换为实际应用包名
                }
              });
            })
          },
          alignment: DialogAlignment.Bottom,
          width: '90%'
        })
          .then((id) => {
            this.vm.dialogId = id
          })
      }
    })
  }

  private CustomDialog(msg: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '去设置',
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  public confirm(date: Date | Date[]) {
    let dates: Date[] = date as Date[];
    this.vm.hotelDateModel.checkInDate = dates[0];
    this.vm.hotelDateModel.checkOutDate = dates[1];
    this.paramChangeCallback?.(this.vm.hotelDateModel)
  }

  public confirmData(date: Date | Date[]) {
    let dates: Date = date as Date;
    this.vm.hotelDateModel.checkInDate = dates;
    this.paramChangeCallback?.(this.vm.hotelDateModel)
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ic_hotel_bg')).width('100%').objectFit(ImageFit.Contain)
      Column() {
        Row() {
          Image($r('app.media.ic_back_white')).height(40).width(40)
            .onClick(() => {
              phoneRouterControl.popPage()
            })
        }
        .margin({ top: BarVM.instance.staBarH, bottom: this.collapseExpandState ? 105 : 55 })
        .width('100%')
        .justifyContent(FlexAlign.Start)

        // 酒店tabs切换
        this.hotelTabsBuilder()

      }.margin({ left: 16, right: 16 })
    }
  }

  // 酒店tabs切换
  @Builder
  hotelTabsBuilder() {
    Column() {
      Row() {
        // 国内/海外tab
        this.domesticOverseasTabsBuilder()
        // 钟点房tab
        this.hourlyRoomTabsBuilder()
        // 民宿tab
        this.homestayBuilder()
      }
      .backgroundColor('rgba(255, 255, 255, 0.8)')
      .width('100%')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        //  位置权限申请
        this.locationPermissionBuilder()
        // 选择城市和跳转搜索酒店页面
        this.selectCityBuilder()
        // 选择入职日期和离店日期
        this.selectHotelDateBuilder()

        Column() {
          Text('查询').fontSize(16).fontColor('#333333').fontWeight(500)
        }
        .onClick(() => {
          const param: HotelPageParam = {
            hotelPageVM: this.vm,
            hotelDateModel: this.vm.hotelDateModel
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.HOTEL_LIST_PAGE,
            builder: wrapBuilder(HotelListPageBuilder),
            param: param
          })
        })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(43)
        .margin({ top: 12, bottom: 12 })
        .backgroundColor('#FEE231')
        .borderRadius(24)
      }
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })

    }.width(this.collapseExpandState ? '70%' : '100%')
  }

  // 国内\海外的tabs
  @Builder
  domesticOverseasTabsBuilder() {
    if (this.vm.chooseStatus === ChooseStatus.Domestic || this.vm.chooseStatus === ChooseStatus.Overseas) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_domestic')).width('45%').objectFit(ImageFit.Contain)
        Row() {
          Text('国内')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Domestic ? '#000000' : 'rgba(0, 0, 0, 0.50)')
            .onClick(() => {
              this.vm.chooseStatus = ChooseStatus.Domestic
              if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.vm.currentCity)) {
                this.vm.currentCity = '南京市'
              }
              this.vm.searchContent = ''
            })
          Text('海外')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Overseas ? '#000000' : 'rgba(0, 0, 0, 0.50)')
            .onClick(() => {
              this.vm.chooseStatus = ChooseStatus.Overseas
              this.vm.currentCity = '东京'
              this.vm.searchContent = ''
              this.vm.showLocation = false
            })

        }.width('33.3%').justifyContent(FlexAlign.SpaceAround).alignItems(VerticalAlign.Center)
      }
    } else {
      Row() {
        Text() {
          Span('国内')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Domestic ? '#000000' : 'rgba(0, 0, 0, 0.50)')
            .onClick(() => {
              this.vm.chooseStatus = ChooseStatus.Domestic
              if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.vm.currentCity)) {
                this.vm.currentCity = '南京市'
              }
              this.vm.searchContent = ''
              this.vm.hotelDateModel.checkInDate = new Date()
              this.vm.hotelDateModel.checkOutDate = new Date();
              this.vm.hotelDateModel.checkOutDate.setDate(this.vm.hotelDateModel.checkInDate.getDate() + 1)
            })
          Span('·')
          Span('海外')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Overseas ? '#000000' : 'rgba(0, 0, 0, 0.50)')
            .onClick(() => {
              this.vm.chooseStatus = ChooseStatus.Overseas
              this.vm.currentCity = '东京'
              this.vm.searchContent = ''
              this.vm.showLocation = false
              this.vm.hotelDateModel.checkInDate = new Date()
              this.vm.hotelDateModel.checkOutDate = new Date();
              this.vm.hotelDateModel.checkOutDate.setDate(this.vm.hotelDateModel.checkInDate.getDate() + 1)
            })
        }

      }.width('36%').justifyContent(FlexAlign.Center)
    }
  }

  // 钟点房tabs
  @Builder
  hourlyRoomTabsBuilder() {
    if (this.vm.chooseStatus === ChooseStatus.Hourly) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_hourly_room')).width('41%').objectFit(ImageFit.Contain)
        Row() {
          Text('钟点房')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Hourly ? '#000000' : 'rgba(0, 0, 0, 0.50)')
        }.width('33.3%').justifyContent(FlexAlign.Center)
      }
    } else {
      Row() {
        Text('钟点房')
          .fontSize(16)
          .fontColor(this.vm.chooseStatus === ChooseStatus.Hourly ? '#000000' : 'rgba(0, 0, 0, 0.50)')
      }.width('19%')
      .justifyContent(this.vm.chooseStatus === ChooseStatus.Homestay ? FlexAlign.Center : FlexAlign.Start)
      .onClick(() => {
        if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.vm.currentCity)) {
          this.vm.currentCity = '南京市'
        }
        this.vm.searchContent = ''
        this.vm.chooseStatus = ChooseStatus.Hourly
        this.vm.hotelDateModel.checkInDate = new Date()
      })
    }
  }

  // 民宿tabs
  @Builder
  homestayBuilder() {
    if (this.vm.chooseStatus === ChooseStatus.Homestay) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_homestay')).width('36%').objectFit(ImageFit.Contain)
        Row() {
          Text('民宿')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Homestay ? '#000000' : 'rgba(0, 0, 0, 0.50)')
        }.width('33.3%').justifyContent(FlexAlign.Center)

      }
    } else {
      Row() {
        Text('民宿')
          .fontSize(16)
          .fontColor(this.vm.chooseStatus === ChooseStatus.Homestay ? '#000000' : 'rgba(0, 0, 0, 0.50)')
      }
      .width(this.vm.chooseStatus === ChooseStatus.Hourly ? '26%' : '36%')
      .justifyContent(this.vm.chooseStatus === ChooseStatus.Hourly ? FlexAlign.Start : FlexAlign.Center)
      .onClick(() => {
        if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.vm.currentCity)) {
          this.vm.currentCity = '南京市'
        }
        this.vm.searchContent = ''
        this.vm.chooseStatus = ChooseStatus.Homestay
        this.vm.hotelDateModel.checkInDate = new Date()
        this.vm.hotelDateModel.checkOutDate = new Date();
        this.vm.hotelDateModel.checkOutDate.setDate(this.vm.hotelDateModel.checkInDate.getDate() + 1)
      })
    }
  }

  // 开启位置权限
  @Builder
  locationPermissionBuilder() {
    if (this.vm.locationPermission) {
      if (this.vm.showLocation) {
        Row() {
          Image($r('app.media.ic_location')).width(10).height(13)
          Text('已定位到').margin({ left: 5 }).fontSize(12).fontColor('#0053AC')
          Text() {
            Span(`${this.vm.currentCity},`)
            Span(this.vm.placeName)
          }
          .layoutWeight(1)
          .fontSize(12)
          .fontColor('#000000')
          .maxLines(1)
          .margin({ left: 12 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding({ left: 10, right: 10 })
        .margin({
          top: 8,
          bottom: 8
        })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .height(38)
        .width('100%')
        .backgroundColor('#EBF5FF')
        .borderRadius(8)
      }

    } else {
      Row() {
        Text('开启定位权限，为你搜索附近酒店').fontColor('#C1771C').fontSize(12)
        Text('开启权限')
          .onClick(() => {
            this.checkPermission()
          })
          .fontColor('#C1771C')
          .fontSize(12)
          .padding({
            left: 10,
            right: 10,
            top: 4,
            bottom: 4
          })
          .borderRadius(11)
          .borderColor('#C1771C')
          .borderWidth(0.5)
      }
      .padding({ left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .height(38)
      .margin({
        top: 8,
        bottom: 8
      })
      .width('100%')
      .backgroundColor('#FFFADB')
      .borderRadius(8)
    }
  }

  // 选择城市和跳转搜索酒店页面
  @Builder
  selectCityBuilder() {
    Row() {
      Text(this.vm.currentCity).fontSize(18).fontColor('#333333').fontWeight(500)
        .onClick(() => {
          this.vm.jumpCitySelectPage();
        })
      Image($r('app.media.ic_down')).width(20).height(20).margin({ left: 2 })

      TextInput({ text: $$this.vm.searchContent, placeholder: '位置/品牌/酒店' })
        .margin({ right: 10 })
        .focusable(false)
        .layoutWeight(1)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.SEARCH_HOTEL_PAGE,
            builder: wrapBuilder(SearchHotelPageBuilder),
            param: this.vm,
            onPop: (popInfo: PopInfo) => {
              let result = popInfo?.result as string;
              if (result) {
                this.vm.searchContent = result
              }
            }
          })
        })
      Column() {
        Image($r('app.media.ic_position')).width(20).height(20)
        Text('我的位置').fontSize(10).fontColor('#333333')
      }
      .onClick(() => {
        this.checkPermission()
      })
    }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween).height(56)
  }

  // 选择入职日期和离店日期
  @Builder
  selectHotelDateBuilder() {
    Column() {
      Row() {
        Text('入住日期').fontColor('#9E9E9E').fontSize(12)
        if (this.vm.chooseStatus !== ChooseStatus.Hourly) {
          Text('离店日期').fontColor('#9E9E9E').fontSize(12)
        }
      }
      .width('100%')
      .justifyContent(this.vm.chooseStatus !== ChooseStatus.Hourly ? FlexAlign.SpaceBetween : FlexAlign.Start);

      if (this.vm.chooseStatus === ChooseStatus.Hourly) {
        this.datePickerHourBuilder()
      } else {
        this.datePickerBuilder()
      }

    }.width('100%').height(66).justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  datePickerBuilder() {
    UICalendarPicker({
      type: TypePicker.RANGE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.today.getFullYear(),
      endYear: this.today.getFullYear() + 1,
      rangeLimit: [this.vm.hotelDateModel.startDate],
      detents: [SheetSize.MEDIUM],
      selectDates: [this.vm.hotelDateModel.checkInDate, this.vm.hotelDateModel.checkOutDate],
      onSelected: (date: Date | Date[]) => {
        this.confirm(date);
      },
    }) {
      Row() {
        Row() {
          Text(this.vm.hotelDateModel.getDateLabel(this.vm.hotelDateModel.checkInDate))
            .textStyle()
        }.justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)

        Text('共' + this.vm.hotelDateModel.totalDays + '晚').fontSize(14).fontColor('#333333')

        Row() {
          Text(this.vm.hotelDateModel.getDateLabel(this.vm.hotelDateModel.checkOutDate))
            .textStyle()
        };
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder
  datePickerHourBuilder() {
    UICalendarPicker({
      type: TypePicker.SINGLE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.HORIZONTAL,
      startYear: this.today.getFullYear(),
      rangeLimit: [this.vm.hotelDateModel.startDate],
      endYear: this.today.getFullYear() + 1,
      detents: [SheetSize.MEDIUM],
      selected: this.vm.hotelDateModel.checkInDate,
      onSelected: (date: Date | Date[]) => {
        this.confirmData(date);
      }
    }) {
      Row() {
        Row() {
          Text(this.vm.hotelDateModel.getDateLabel(this.vm.hotelDateModel.checkInDate))
            .textStyle()
        }.justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)

      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
  }
}

@Extend(Text)
function textStyle() {
  .fontSize(18)
  .lineHeight(21)
  .fontWeight(500);
}