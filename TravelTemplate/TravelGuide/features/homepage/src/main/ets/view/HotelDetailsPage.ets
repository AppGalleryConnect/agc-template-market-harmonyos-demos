import { BarVM, RouterMap, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { SearchImgType } from '../common/model';
import { HotelDetailsPageVM } from '../viewmodel/HotelDetailsPageVM';
import { SharePicker } from 'aggregated_share';
import { HotelFacilityPageBuilder } from './HotelFacilityPage';
import { SubmitOrderPageBuilder } from './SubmitOrderPage';
import { MapPageBuilder } from './MapPage';
import { HotelDateModel, HotelModel } from 'common_travel_guide';
import { HotelDetailsParam } from './HotelListPage';
import { DialogType, SwiperDirection, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { promptAction } from '@kit.ArkUI';
import { HotelPageVM, ChooseStatus } from '../viewmodel/HotelPageVM';

@Builder
export function HotelDetailsPageBuilder(params: TValueType) {
  HotelDetailsPage({
    pageParams: params as HotelDetailsParam
  })
}

export interface HotelOrderParam {
  hotelModel: HotelModel
  hotelDate: HotelDateModel
  hotelPageVM: HotelPageVM
  roomType: string
}

@ComponentV2
export struct HotelDetailsPage {
  @Param pageParams: TValueType = null
  @Local today: Date = new Date()
  @Local hotelModel: HotelModel = Object()
  @Local hotelDate: HotelDateModel = Object()
  @Local hotelPageVM: HotelPageVM = Object()
  vm: HotelDetailsPageVM = new HotelDetailsPageVM()
  @Event paramChange: (data: HotelDateModel) => void = () => {
  };

  aboutToAppear(): void {
    this.hotelModel = (this.pageParams as HotelDetailsParam)?.hotelModel
    this.hotelDate = (this.pageParams as HotelDetailsParam)?.hotelDate
    this.hotelPageVM = (this.pageParams as HotelDetailsParam)?.hotelPageVM
    this.vm.hotelClassificationList[0].text = this.hotelModel.decorationTime + '装修'
  }

  build() {
    NavDestination() {
      this.render()
    }
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  public confirm(date: Date | Date[]) {
    let dates: Date[] = date as Date[];
    this.hotelDate.checkInDate = dates[0];
    this.hotelDate.checkOutDate = dates[1];
    this.paramChange?.(this.hotelDate)
  }

  public confirmData(date: Date | Date[]) {
    let dates: Date = date as Date;
    this.hotelDate.checkInDate = dates;
    this.paramChange?.(this.hotelDate)
  }

  jumpPage(params: HotelOrderParam) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.SUBMIT_ORDER_PAGE,
      builder: wrapBuilder(SubmitOrderPageBuilder),
      param: params
    })
  }

  @Builder
  render() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.icon_hotel_bg')).height(280).width('100%')
        Row() {
          Image($r('app.media.ic_back_white')).width(40).height(40)
            .onClick(() => {
              phoneRouterControl.popPage()
            })
          Image($r('app.media.ic_share')).width(28).height(28)
            .onClick(() => {
              const picker: SharePicker = new SharePicker({
                title: 'HarmonyOS官方模板集成创新活动',
              });
              picker.show();
            })
        }
        .width('100%')
        .margin({ top: BarVM.instance.staBarH })
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16 })
      }

      this.detailContent()
    }
  }

  @Builder
  imageBuilder() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        ForEach(this.vm.hotelClassificationList, (item: SearchImgType, index: number) => {
          Column({ space: 6 }) {
            // 图标
            Image(item.img)
              .width(34)
              .height(34)
              .objectFit(ImageFit.Contain)

            // 文字
            Text(item.text)
              .fontSize(10)
              .fontColor('#000000')
          }.width('18%')
        }, (item: SearchImgType) => item.toString())
      }.width('100%').justifyContent(FlexAlign.Start).margin({ top: 12 })

      Row() {
        Column() {
          Text('设施').fontSize(12).fontColor('#000000')
          Text('政策').fontSize(12).fontColor('#000000')
        }

        Image($r('app.media.ic_right_facility')).width(16).height(16).margin({ left: 2 })
      }
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.HOTEL_FACILITY_PAGE,
          builder: wrapBuilder(HotelFacilityPageBuilder),
          param: this.hotelModel
        })
      })
      .backgroundColor('#FFFFFF')
      .width(57)
      .height(68)
      .padding({ left: 8, top: 12 })
      .margin({ right: -16 })
    }
  }

  @Builder
  detailContent() {

    Column() {
      Text() {
        Span(this.hotelModel?.name)
          .fontSize(17)
          .fontWeight(500)
          .fontColor('#333333')
        Span('  ')
        Span(this.hotelModel?.type)
          .textBackgroundStyle({
            color: '#FFF6DC',
            radius: 4
          })
          .fontSize(10)
          .fontWeight(500)
          .fontColor('#333333')
      }.lineHeight(24).maxLines(2)

      this.imageBuilder()

      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.ic_map_bg')).width('100%').height(79).borderRadius(12)
        Row() {
          Column() {
            Text(this.hotelModel?.position)
              .fontSize(12)
              .fontColor('#333333')
              .fontWeight(500)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.hotelModel?.distance).fontSize(10).fontColor('#717376').fontWeight(400)
          }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween).height('100%').width('80%')

          Column() {
            Image($r('app.media.ic_location_bg')).width(32).height(32)
            Text('地图').fontSize(12).fontColor('#333333').fontWeight(400)
          }.justifyContent(FlexAlign.SpaceBetween).height('100%')
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.MAP_PAGE,
              builder: wrapBuilder(MapPageBuilder),
              param: this.hotelModel
            })
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 12, right: 16, top: 12, bottom: 12 })
        .height('100%')
        .width('100%')
      }.margin({ top: 16 }).height(79)

      Column() {
        Row() {
          Text('入住日期').fontSize(12).fontColor('#9E9E9E')
          if (this.hotelPageVM.chooseStatus !== ChooseStatus.Hourly) {
            Text('离店日期').fontSize(12).fontColor('#9E9E9E')
          }
        }
        .width('100%')
        .justifyContent(this.hotelPageVM.chooseStatus !== ChooseStatus.Hourly ? FlexAlign.SpaceBetween :
        FlexAlign.Start);

        if (this.hotelPageVM.chooseStatus === ChooseStatus.Hourly) {
          this.datePickerHourBuilder()
        } else {
          this.datePickerBuilder()
        }

      }.width('100%').height(66).justifyContent(FlexAlign.SpaceAround).margin({ top: 12, bottom: 24 })

      Scroll() {
        Column() {
          Row() {
            Image($r('app.media.ic_luxury_room'))
              .width(78)
              .height(104)
              .borderRadius(8)
              .margin({ right: 8 })
            Column() {
              Column() {
                Text('豪华大床房').fontSize(14).fontColor('#333333').fontWeight(400)
                Text() {
                  Span('1张1.55米双人床 20-22m')
                  Span('  2人入住')
                  Span('  1-3层')
                }.fontSize(11).fontColor('#333333').fontWeight(400)

                Text() {
                  Span('有窗')
                  Span('  自助餐')
                  Span('  入住当天17:00前可免费取消').fontColor('#C1771C')
                }.fontSize(11).fontColor('#333333').fontWeight(400)
              }.alignItems(HorizontalAlign.Start).width('100%').height(58).justifyContent(FlexAlign.SpaceAround)

              Row() {
                Text() {
                  Span('¥')
                  Span(this.hotelModel?.price.toString())
                }.fontSize(14).fontColor('#FF4A26').fontWeight(400)

                Text('订')
                  .padding({ left: 20, right: 20, top: 8, bottom: 8 })
                  .fontSize(15)
                  .fontColor('#333333')
                  .fontWeight(400)
                  .backgroundColor('#FEE231')
                  .borderRadius(24)
                  .onClick(() => {
                    const params: HotelOrderParam = {
                      hotelModel: this.hotelModel,
                      hotelDate: this.hotelDate,
                      hotelPageVM: this.hotelPageVM,
                      roomType: '豪华大床房'
                    }
                    this.jumpPage(params)
                  })
              }.justifyContent(FlexAlign.SpaceBetween).width('100%').alignItems(VerticalAlign.Bottom)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }.margin({ bottom: 24 })

          Row() {
            Image($r('app.media.ic_comfortable_one'))
              .width(78)
              .height(104)
              .borderRadius(8)
              .margin({ right: 8 })
            Column() {
              Column() {
                Text('舒适大床房').fontSize(14).fontColor('#333333').fontWeight(400)
                Text() {
                  Span('1张1.35米双人床 20-22m')
                  Span('  2人入住')
                  Span('  4-5层')
                }.fontSize(11).fontColor('#333333').fontWeight(400)

                Text() {
                  Span('无窗')
                  Span('  自助餐')
                  Span('  入住当天17:00前可免费取消').fontColor('#C1771C')
                }.fontSize(11).fontColor('#333333').fontWeight(400)
              }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceAround).width('100%').height(58)

              Row() {
                Text() {
                  Span('¥')
                  Span(this.hotelModel?.bigRoomPrice.toString())
                }.fontSize(14).fontColor('#FF4A26').fontWeight(400)

                Text('订')
                  .padding({ left: 20, right: 20, top: 8, bottom: 8 })
                  .fontColor('#333333')
                  .fontWeight(400)
                  .fontSize(15)
                  .onClick(() => {
                    const params: HotelOrderParam = {
                      hotelModel: this.hotelModel,
                      hotelDate: this.hotelDate,
                      hotelPageVM: this.hotelPageVM,
                      roomType: '舒适大床房'
                    }
                    this.jumpPage(params)
                  })
                  .backgroundColor('#FEE231')
                  .borderRadius(24)
              }.justifyContent(FlexAlign.SpaceBetween).width('100%').alignItems(VerticalAlign.Bottom)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }.margin({ bottom: 24 })

          Row() {
            Image($r('app.media.ic_comfortable_two'))
              .width(78)
              .height(104)
              .borderRadius(8)
              .margin({ right: 8 })
            Column() {
              Column() {
                Text('舒适双床房').fontSize(14).fontColor('#333333').fontWeight(400)
                Text() {
                  Span('1张1.35米双人床 20-22m')
                  Span('  2人入住')
                  Span('  1-3层')
                }.fontSize(11).fontColor('#333333').fontWeight(400)

                Text() {
                  Span('无窗')
                  Span('  自助餐')
                  Span('  入住当天17:00前可免费取消').fontColor('#C1771C')
                }.fontSize(11).fontColor('#333333').fontWeight(400)
              }.alignItems(HorizontalAlign.Start).width('100%').height(58).justifyContent(FlexAlign.SpaceAround)

              Row() {
                Text() {
                  Span('¥')
                  Span(this.hotelModel?.doubleBedRoomPrice.toString())
                }.fontSize(14).fontColor('#FF4A26').fontWeight(400)

                Text('订')
                  .fontSize(15)
                  .fontColor('#333333')
                  .fontWeight(400)
                  .padding({
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 8
                  })
                  .onClick(() => {
                    const params: HotelOrderParam = {
                      hotelModel: this.hotelModel,
                      hotelDate: this.hotelDate,
                      hotelPageVM: this.hotelPageVM,
                      roomType: '舒适双床房'
                    }
                    this.jumpPage(params)
                  })
                  .backgroundColor('#FEE231')
                  .borderRadius(24)
              }.justifyContent(FlexAlign.SpaceBetween).width('100%').alignItems(VerticalAlign.Bottom)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
        }
      }
      .padding({ bottom: BarVM.instance.aiBarH })
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: -24 })
    .borderRadius({ topLeft: 24, topRight: 24 })
    .backgroundColor('#FFFFFF')
    .padding({ top: 12, left: 16, right: 16 })
    .layoutWeight(1)

  }

  @Builder
  datePickerBuilder() {
    UICalendarPicker({
      type: TypePicker.RANGE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.today.getFullYear(),
      rangeLimit: [this.hotelDate.startDate],
      endYear: this.today.getFullYear() + 1,
      detents: [SheetSize.MEDIUM],
      selectDates: [this.hotelDate.checkInDate, this.hotelDate.checkOutDate],
      onSelected: (date: Date | Date[]) => {
        this.confirm(date);
      },
    }) {
      Row() {
        Row() {
          Text(this.hotelDate.getDateLabel(this.hotelDate.checkInDate))
            .dateTextStyle()
        }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
        Text('共' + this.hotelDate.totalDays + '晚').fontSize(14).fontColor('#333333')
        Row() {
          Text(this.hotelDate.getDateLabel(this.hotelDate.checkOutDate))
            .dateTextStyle()
        };
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  datePickerHourBuilder() {
    UICalendarPicker({
      type: TypePicker.SINGLE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.HORIZONTAL,
      startYear: this.today.getFullYear(),
      rangeLimit: [this.hotelDate.startDate],
      endYear: this.today.getFullYear() + 1,
      detents: [SheetSize.MEDIUM],
      selected: this.hotelDate.checkInDate,
      onSelected: (date: Date | Date[]) => {
        this.confirmData(date);
      }
    }) {
      Row() {
        Row() {
          Text(this.hotelDate.getDateLabel(this.hotelDate.checkInDate))
            .dateTextStyle()
        }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
  }
}

@Extend(Text)
function dateTextStyle() {
  .fontSize(18)
  .lineHeight(21)
  .fontWeight(500);
}