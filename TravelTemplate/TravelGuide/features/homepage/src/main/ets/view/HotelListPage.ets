/**
 * @usage: 酒店列表页面，展示酒店搜索结果，支持智能排序、位置距离、价格/星级、筛选等多种过滤方式
 * @layout: 页面整体采用垂直布局（Column），顶部是搜索栏和日期选择抽屉，中间是筛选条件栏，下方是酒店列表
 * @constraints: hotelList为酒店数据源，根据筛选条件动态过滤；filterOptions包含智能排序、位置距离、价格/星级、筛选四个选项
 * @isGen: true
 * @fileType: page
 * @zhName: 酒店列表
 * @domain: 旅游
 * @image: screenshots/homepage/HotelList.jpg
 * @subPage: HotelDetailsPage,SearchHotelPage,CitySelectPage,OverseasCitySelectPage
 * @component: Drawer,IntelligentDialog,LocationDialog,PriceDialog,FilterDialog
 */
import { BarVM, RouterMap, TValueType } from 'common'
import { phoneRouterControl } from 'oh_router'
import { FilterItem, HotelListPageVM } from '../viewmodel/HotelListPageVM'
import { DialogType, SwiperDirection, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker'
import { promptAction } from '@kit.ArkUI'
import { Drawer, DrawerController } from 'module_filter_list'
import { HotelPageParam } from './HotelPage'
import { ChooseStatus, HotelPageVM } from '../viewmodel/HotelPageVM'
import { IntelligentDialog } from '../components/IntelligentDialog'
import { LocationDialog } from '../components/LocationDialog'
import { PriceDialog } from '../components/PriceDialog'
import { FilterDialog } from '../components/FilterDialog'
import { HotelDateModel, HotelModel, MockOverseasService, MockService } from 'common_travel_guide'
import { HotelDetailsPageBuilder } from './HotelDetailsPage'
import { SearchHotelPageBuilder } from './SearchHotelPage'
import { CitySelectPageBuilder } from './CitySelectPage'
import { OverseasCitySelectPageBuilder } from './OverseasCitySelectPage'
import { City, OVERSEAS_CITY_LIST_SAMPLE } from 'city_select'

export interface HotelDetailsParam {
  hotelModel: HotelModel
  hotelDate: HotelDateModel
  hotelPageVM: HotelPageVM
}

@Builder
export function HotelListPageBuilder(params: TValueType) {
  HotelListPage({
    pageParam: params as HotelPageParam
  })
}

@ComponentV2
export struct HotelListPage {
  vm: HotelListPageVM = new HotelListPageVM()
  @Param pageParam: TValueType = null
  tabController: DrawerController = new DrawerController();
  controller: DrawerController = new DrawerController();
  @Local typeIndex: number = 0;
  @Local styleIndex: number = 0;
  @Local listArr: string[] = new Array(5).fill('');
  @Local today: Date = new Date()
  @Event paramChangeCallback: (data: HotelDateModel) => void = () => {
  };

  public handleConfirm(data: Date | Date[]) {
    let dates: Date[] = data as Date[];
    this.vm.hotelDate.checkInDate = dates[0];
    this.vm.hotelDate.checkOutDate = dates[1];
    this.paramChangeCallback?.(this.vm.hotelDate)
  }

  public handleConfirmData(data: Date | Date[]) {
    let dates: Date = data as Date;
    this.vm.hotelDate.checkInDate = dates;
    this.paramChangeCallback?.(this.vm.hotelDate)
  }

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
    this.vm.hotelPageVM = (this.pageParam as HotelPageParam)?.hotelPageVM
    this.vm.hotelDate = (this.pageParam as HotelPageParam)?.hotelDateModel
    this.vm.searchContent = this.vm.hotelPageVM.searchContent
    this.search()
  }

  search() {
    if (this.vm.hotelPageVM.chooseStatus === ChooseStatus.Overseas) {
      this.vm.mockHotelList =
        MockOverseasService.hotelResult.filter(item => item.city === this.vm.hotelPageVM.currentCity)
    } else {
      this.vm.mockHotelList = MockService.hotelResult.filter(item => item.city === this.vm.hotelPageVM.currentCity)
    }
    // 默认智能排序
    this.vm.hotelList = this.vm.mockHotelList.filter(item => item.city === this.vm.hotelPageVM.currentCity)
      .sort((a, b) => a.reviewCount - b.reviewCount)
    this.vm.hotelList = this.vm.hotelList.filter(item => item.name.includes(this.vm.searchContent))
    this.vm.hotelPageVM.searchContent = this.vm.searchContent
  }

  @Builder
  render() {
    Column() {
      this.searchBuilder()
      Drawer({
        controller: this.tabController,
        onDrawChange: (res) => {
          this.vm.isShow = res;
        },
      }) {
        Column() {
          Row() {
            Text() {
              Span(this.vm.hotelPageVM.currentCity)
              if (this.vm.searchContent) {
                Span(`${this.vm.searchContent}附近`).margin({ left: 16 })
              }

            }.fontSize(20).fontColor('#333333')
          }
          .onClick(() => {
            if (this.vm.hotelPageVM.chooseStatus === ChooseStatus.Overseas) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.OVERSEAS_CITY_SELECT_PAGE,
                builder: wrapBuilder(OverseasCitySelectPageBuilder),
                param: this.vm.hotelPageVM.currentCity,
                onPop: (popInfo: PopInfo) => {
                  let result = popInfo?.result as City;
                  if (result && result.name) {
                    this.vm.hotelPageVM.currentCity = result.name
                  }
                  this.vm.hotelPageVM.showLocation = false
                  if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.vm.hotelPageVM.currentCity)) {
                    this.vm.hotelPageVM.chooseStatus = ChooseStatus.Overseas
                  }
                }
              })
            } else {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.CITY_SELECT_PAGE,
                builder: wrapBuilder(CitySelectPageBuilder),
                param: this.vm.hotelPageVM.currentCity,
                onPop: (popInfo: PopInfo) => {
                  let result = popInfo?.result as City;
                  if (result && result.name) {
                    this.vm.hotelPageVM.currentCity = result.name
                  }
                  this.vm.hotelPageVM.showLocation = false
                  if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.vm.hotelPageVM.currentCity)) {
                    this.vm.hotelPageVM.chooseStatus = ChooseStatus.Overseas
                  }
                }
              })
            }
          })
          .height(47)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .margin({ top: 8 })

          Column() {
            Row() {
              Text('入住日期').fontSize(12).fontColor('#9E9E9E')
              if (this.vm.hotelPageVM.chooseStatus !== ChooseStatus.Hourly) {
                Text('离店日期').fontSize(12).fontColor('#9E9E9E')
              }
            }
            .width('100%')
            .justifyContent(this.vm.hotelPageVM.chooseStatus === ChooseStatus.Hourly ? FlexAlign.Start :
            FlexAlign.SpaceBetween);

            if (this.vm.hotelPageVM.chooseStatus === ChooseStatus.Hourly) {
              this.datePickerHourBuilder()
            } else {
              this.datePickerBuilder()
            }
          }.width('100%').height(66).justifyContent(FlexAlign.SpaceAround)

          Column() {
            Text('完成').fontSize(16).fontColor('#333333')
          }
          .onClick(() => {
            this.search()
            this.tabController.close();
          })
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(43)
          .borderRadius(24)
          .backgroundColor('#FEE231')
          .margin({ top: 12 })
        }
        .width('100%')
        .zIndex(100)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .height(185)
        .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      };

      this.filterContent()
    }
    .padding({
      top: BarVM.instance.staBarH,
      left: 16,
      right: 16,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
  }

  @Builder
  searchBuilder() {
    Row() {
      Image($r('app.media.icon_back')).height('100%').width(40)
        .onClick(() => {
          phoneRouterControl.popPage()
        })
      Row() {
        Row() {
          Text(this.vm.hotelPageVM.currentCity)
          Column() {
            Text(this.vm.hotelDate.getDateNum(this.vm.hotelDate.checkInDate))
              .searchLabelStyle()
            if (this.vm.hotelPageVM.chooseStatus !== ChooseStatus.Hourly) {
              Text(this.vm.hotelDate.getDateNum(this.vm.hotelDate.checkOutDate))
                .searchLabelStyle()
            }
          }
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(this.vm.hotelPageVM.chooseStatus === ChooseStatus.Hourly ? FlexAlign.Center :
          FlexAlign.SpaceBetween)
          .margin({ left: 6 })

          Column() {
            Text('入住').fontSize(11).fontColor('#A7A7A7')
            Text('离店').fontSize(11).fontColor('#A7A7A7')
          }
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ left: 6 })
        }
        .onClick(() => {
          if (this.vm.isShow) {
            this.tabController.close();
          } else {
            this.tabController.open();
          }
        })

        Text(this.vm.searchContent ? this.vm.searchContent : '位置/品牌/酒店')
          .maxLines(1)
          .layoutWeight(1)
          .fontSize(14)
          .fontColor(this.vm.searchContent ? $r('sys.color.font_primary') : 'rgba(0, 0, 0, 0.30)')
          .margin({ left: this.vm.searchContent ? 16 : 8 })
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
        if (this.vm.searchContent) {
          Image($r('app.media.icon_delete')).width(16).height(16).margin({ left: 5 })
            .onClick(() => {
              this.vm.searchContent = ''
            })
        }
      }
      .height('100%')
      .margin({ left: 10, right: 10 })
      .backgroundColor('#F2F4F5')
      .borderRadius(20)
      .layoutWeight(1)
      .padding({
        left: 16,
        top: 6,
        bottom: 6,
        right: 9
      })

      Text('搜索')
        .borderColor('rgba(0, 0, 0, 0.10)')
        .borderRadius(20)
        .borderWidth(0.5)
        .fontSize(14)
        .fontColor('#333333')
        .padding({
          left: 15,
          top: 12,
          right: 15,
          bottom: 12
        })
        .onClick(() => {
          this.search()
        })
    }.justifyContent(FlexAlign.SpaceBetween).height(40).margin({ top: 8, bottom: 8 })
  }

  @Builder
  filterContent() {
    Column() {
      Column() {
        Row() {
          ForEach(this.vm.filterOptions, (item: FilterItem, index) => {
            Row() {
              Text(item.name)
                .fontSize(13)
                .fontWeight(FontWeight.Regular)
                .fontColor('#333333')
              Image(this.vm.selectName === item.name ? $r('app.media.ic_filter_up') :
              $r('app.media.ic_filter_down'))
                .width(12).height(12);
            }
            .padding(8)
            .backgroundColor(this.vm.selectName === item.name ? '#FEE231' : '#F6F8F9')
            .borderRadius(8)
            .onClick(() => {
              if (this.vm.isDrawOpen) {
                this.controller.close();
                this.vm.selectName = ''
              } else {
                this.controller.open();
                this.vm.selectName = item.name
              }
            });
          }, (item: FilterItem) => item.name);
        }
        .width('100%')
        .height(39)
        .margin({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.SpaceBetween)

        Drawer({
          controller: this.controller,
          onDrawChange: (res) => {
            this.vm.isDrawOpen = res;
            if (!this.vm.isShow) {
              this.vm.selectName = ''
            }
          },
        }) {
          if (this.vm.selectName === '智能排序' || this.vm.selectName === '低价优先' ||
            this.vm.selectName === '高价优先' || this.vm.selectName === '高星优先') {
            IntelligentDialog({
              contentArr: this.vm.intelligentTypes,
              selectIntelligentIndex: this.vm.selectIntelligentIndex,
              onItemClick: (index) => {
                //根据不同字段对列表数据进行排序
                this.vm.sortHotelList(this.vm.mockHotelList,index)
                this.controller.close();
              },
            }).margin({ top: 8 })
          } else if (this.vm.selectName === '位置距离') {
            LocationDialog({
              vm: this.vm,
              currentCity: this.vm.hotelPageVM.currentCity,
              onSearchClick: (data?: string) => {
                this.vm.currentPriceIndex = -1
                this.vm.currentStarIndex = -1
                this.vm.priceMinString = ''
                this.vm.priceMaxString = ''
                this.vm.selectedItems = new Set()
                if(!data) {
                  this.search()
                  this.controller.close()
                } else {
                  this.vm.hotelList = this.vm.addressSearchList(data) as HotelModel[]
                  this.controller.close()
                }
                this.vm.sortHotelList(this.vm.hotelList, this.vm.selectIntelligentIndex)
              },
              clear:() => {
                this.search()
              }
            })
          } else if (this.vm.selectName === '价格/星级') {
            PriceDialog({
              vm: this.vm,
              onSearch: (minPrice: string, maxPrice: string, star: string) => {
                this.vm.selectedItems = new Set()
                this.vm.currentIndex = 0
                this.vm.currentSubIndex = -1
                this.vm.starPriceSearchList(minPrice, maxPrice, star)
                this.vm.sortHotelList(this.vm.hotelList, this.vm.selectIntelligentIndex)
                this.controller.close()
              },
              clear:() => {
                this.search()
                this.vm.sortHotelList(this.vm.hotelList, this.vm.selectIntelligentIndex)
              }
            })
          } else {
            FilterDialog({
              selectedItems: this.vm.selectedItems,
              searchHotel: (data: Set<string>) => {
                this.vm.currentPriceIndex = -1
                this.vm.currentStarIndex = -1
                this.vm.priceMinString = ''
                this.vm.priceMaxString = ''
                this.vm.currentIndex = 0
                this.vm.currentSubIndex = -1
                this.vm.dialogSearchList(data)
                this.vm.sortHotelList(this.vm.hotelList, this.vm.selectIntelligentIndex)
                this.controller.close()
              },
            })
          }
        };

        this.content()
      }.width('100%').layoutWeight(1);
    }.layoutWeight(1);
  }

  @Builder
  datePickerBuilder() {
    UICalendarPicker({
      type: TypePicker.RANGE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.today.getFullYear(),
      endYear: this.today.getFullYear() + 1,
      rangeLimit: [this.vm.hotelDate.startDate],
      detents: [SheetSize.MEDIUM],
      selectDates: [this.vm.hotelDate.checkInDate, this.vm.hotelDate.checkOutDate],
      onSelected: (date: Date | Date[]) => {
        this.handleConfirm(date);
      },
    }) {
      Row() {
        Row() {
          Text(this.vm.hotelDate.getDateLabel(this.vm.hotelDate.checkInDate))
            .textLabelStyle()
        }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

        Text('共' + this.vm.hotelDate.totalDays + '晚').fontSize(14).fontColor('#333333')

        Row() {
          Text(this.vm.hotelDate.getDateLabel(this.vm.hotelDate.checkOutDate))
            .textLabelStyle()
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
      endYear: this.today.getFullYear() + 1,
      rangeLimit: [this.vm.hotelDate.startDate],
      detents: [SheetSize.MEDIUM],
      selected: this.vm.hotelDate.checkInDate,
      onSelected: (date: Date | Date[]) => {
        this.handleConfirmData(date);
      }
    }) {
      Row() {
        Row() {
          Text(this.vm.hotelDate.getDateLabel(this.vm.hotelDate.checkInDate))
            .textLabelStyle()
        }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  content() {
    if (this.vm.hotelList.length > 0) {
      List({ space: 12 }) {
        ForEach(this.vm.hotelList, (item: HotelModel, index: number) => {
          ListItem() {
            this.hotelItem(item)
          }.onClick(() => {
            const param: HotelDetailsParam = {
              hotelModel: item,
              hotelDate: this.vm.hotelDate,
              hotelPageVM: this.vm.hotelPageVM
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HOTEL_DETAILS_PAGE,
              builder: wrapBuilder(HotelDetailsPageBuilder),
              param: param
            })
          })
        }, (item: HotelModel, index: number) => `${item.name}_${index}}`)
      }.layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    } else {
      Column() {
        Image($r('app.media.ic_no_hotel')).height(106).objectFit(ImageFit.Contain).margin({ bottom: 20 })
        Text('暂无内容').fontSize(15).fontColor('rgba(0, 0, 0, 0.60)')
      }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
    }

  }

  @Builder
  hotelItem(item: HotelModel) {
    Row() {
      Image($r(item.image)).width(114).height(152).borderRadius(16).objectFit(ImageFit.Contain)
      Column() {
        Column() {
          Row() {
            Text(item.name).fontSize(14).fontColor('#333333')
            Text(item.type)
              .fontSize(10)
              .fontColor('#333333')
              .padding({
                top: 2,
                bottom: 2,
                left: 4,
                right: 4
              })
              .borderRadius(4)
              .backgroundColor('#FFF6DC')
              .margin({ left: 4 })
          }.margin({ top: 6 })


          Row({ space: 2 }) {
            Text(item.rating.toString())
              .fontColor('#333333')
              .fontSize(12)
              .backgroundColor('#FEE231')
              .padding(4)
              .borderRadius(8
              )
            Text() {
              Span(`${item.reviewCount.toString()}点评 · `)
              Span(`${item.favoriteCount.toString()}收藏`)
            }.fontWeight(500).fontSize(12).fontColor('#333333')
          }.margin({ top: 8 })

          Text(item.distance).fontSize(12).fontColor('#717376').margin({ top: 4 })
          Row({ space: 2 }) {
            ForEach(item.facility, (facility: string, index: number) => {
              Text(facility)
                .fontSize(10)
                .fontColor('#505257')
                .backgroundColor('#F3F3F3')
                .padding({
                  top: 2,
                  bottom: 2,
                  left: 4,
                  right: 4
                })
                .borderRadius(4)
            }, (facility: string) => JSON.stringify(facility))
          }.margin({ top: 8 })
        }.alignItems(HorizontalAlign.Start)


        Column() {
          Row() {
            Text() {
              Span('¥')
              Span(item.originalPrice.toString())
            }
            .fontSize(10).fontColor('#717376')
            .decoration({
              type: TextDecorationType.LineThrough, // 删除线
              color: Color.Blue,
              style: TextDecorationStyle.DASHED
            })
            .margin({ right: 4 })

            Text() {
              Span('¥')
              Span(item.price.toString()).fontSize(18)
              Span('起')
            }.fontSize(10).fontColor('#FF4A26')
          }
        }.width('100%').margin({ bottom: 6 }).alignItems(HorizontalAlign.End).justifyContent(FlexAlign.End)
      }
      .layoutWeight(1)
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 10, top: 6 })
    }.height(152)
  }
}

@Extend(Text)
function searchLabelStyle() {
  .fontSize(11)
  .lineHeight(13)
  .fontWeight(500);
}

@Extend(Text)
function textLabelStyle() {
  .fontSize(18)
  .lineHeight(21)
  .fontWeight(500);
}