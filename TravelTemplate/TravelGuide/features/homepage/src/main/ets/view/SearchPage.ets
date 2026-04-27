/**
 * @usage: 搜索页面，提供旅游攻略搜索功能，包含搜索历史、热门推荐、热搜榜（周边热搜榜、景点热搜榜、酒店热搜榜）
 * @layout: 页面整体采用垂直布局（Column），顶部是搜索组件，下方是分类快捷入口、热门推荐、搜索历史、热搜榜列表
 * @constraints: allClassificationList包含火车票、机票、酒店、景点四个快捷入口；热搜榜数据来源于vm中的
 * hotSearchList、hotTourList、hotHotelList
 * @isGen: true
 * @fileType: page
 * @zhName: 搜索页面
 * @domain: 旅游
 * @subPage: PlaneTicketPage,HotelPage,AttractionPage,TourDetailPage,HotelDetailsPage
 * @component: SearchComponent
 */
import { phoneRouterControl } from 'oh_router';
import { SearchComponent, SearchController } from 'search';
import { AppStorageV2, LengthMetrics, PersistenceV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, GlobalContext, RouterMap, UserInfo } from 'common';
import { SearchPageVM } from '../viewmodel/SearchPageVM';
import { HotSearchType, SearchImgType } from '../common/model';
import { HotelPageBuilder } from './HotelPage';
import { HotelDateModel, HotelModel } from 'common_travel_guide';
import { AttractionPageBuilder } from './AttractionPage';
import { HotelDetailsParam } from './HotelListPage';
import { HotelDetailsPageBuilder } from './HotelDetailsPage';
import { TourDetailPageBuilder } from './TourDetailPage';
import { PlaneTicketPageBuilder } from './PlaneTicketPage';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { HotelPageVM } from '../viewmodel/HotelPageVM';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
export struct SearchPage {
  vm: SearchPageVM = new SearchPageVM()
  scroller: Scroller = new Scroller();
  private searchController: SearchController = SearchController.instance;
  @Local searchKey: string = '';
  @Local textWidth: number = 0;
  uiContext = GlobalContext.getUIContext()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  aboutToDisappear() {
    this.searchController.isShowResult = false;
  }

  jumpPage(index: number) {
    if (!this.userInfo.isLogin) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE
      })
    } else {
      switch (index) {
        case 0:
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PLANE_TICKET_PAGE,
            builder: wrapBuilder(PlaneTicketPageBuilder),
            param: '火车票'
          })
          break;
        case 1:
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PLANE_TICKET_PAGE,
            builder: wrapBuilder(PlaneTicketPageBuilder),
            param: '机票'
          })
          break;
        case 2:
          phoneRouterControl.jumpPage({
            pageName: RouterMap.HOTEL_PAGE,
            builder: wrapBuilder(HotelPageBuilder)
          })
          break;
        case 3:
          phoneRouterControl.jumpPage({
            pageName: RouterMap.ATTRACTION_PAGE,
            builder: wrapBuilder(AttractionPageBuilder)
          })
          break;
      }
    }
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.searchController.searchCondition = ''
      phoneRouterControl.popPage()
      return true
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      SearchComponent({
        imageBuilder: this.imageBuilder.bind(this),
        hotSearchBuilder: this.hotSearch.bind(this),
        historySearchBuilder: this.historyBuilderSearch.bind(this),
        searchResultBuilder: this.searchResultBuilder.bind(this),
        getSearchResult: this.getSearchOptionResult.bind(this),
        placeholderText: '请输入搜索内容',
        popPage: () => {
          this.searchController.searchCondition = ''
          phoneRouterControl.popPage()
        },
      })
        .padding({
          left: 16,
          right: 16,
        });
      // 热搜榜适配折叠屏
      if (!this.searchController.isShowResult) {
        this.rankingList()
      }
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')

  }

  getSearchOptionResult() {
    this.vm.searchList = this.vm.hotelList.filter(item => item.name.includes(this.searchController.searchCondition))
  }

  @Builder
  collapseExpandAttractionList(title: string, data: HotSearchType[]) {
    Column() {
      Text(title).fontSize(15).fontColor('#AD5D24').margin({ bottom: 12 })
      ForEach(data, (item: HotSearchType, index: number) => {
        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Image(index > 2 ? $r('app.media.ic_ranking_second') : $r('app.media.ic_ranking_first'))
              .width(14)
              .height(16)
            Text((index + 1).toString()).fontColor(index > 2 ? 'rgba(0, 0, 0, 0.50)' : '#C1753F').fontSize(10)
          }

          Column() {
            Text(item.name).fontSize(13).fontColor('#333333')
            Row() {
              Text(item.rating).fontSize(11).fontColor('#C1753F').margin({ right: 8 })
              Text(item.distance).fontSize(11).fontColor('#C1753F')
            }
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .height('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.Start)
        }.height(32).margin({ top: 16 })
        .onClick(() => {
          if (!this.userInfo.isLogin) {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.LOGIN_PAGE
            })
            return
          }
          if (index === 0 && title === '周边热搜榜') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.TOUR_DETAIL_PAGE,
              builder: wrapBuilder(TourDetailPageBuilder),
              param: this.vm.mockTourList[1]
            })
          }
          if (index === 0 && title === '景点热搜榜') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.TOUR_DETAIL_PAGE,
              builder: wrapBuilder(TourDetailPageBuilder),
              param: this.vm.mockTourList[0]
            })
          }
          if (index === 0 && title === '酒店热搜榜') {
            const param: HotelDetailsParam = {
              hotelModel: this.vm.hotelList[0],
              hotelDate: new HotelDateModel(),
              hotelPageVM: new HotelPageVM()
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HOTEL_DETAILS_PAGE,
              builder: wrapBuilder(HotelDetailsPageBuilder),
              param: param
            })
          }
        })
      }, (item: HotSearchType) => item.toString())
    }
    .layoutWeight(1)
    .borderRadius(12)
    .borderColor('#FAD7BD')
    .borderWidth(0.5)
    .alignItems(HorizontalAlign.Start)
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向
      colors: [['#FFFAF6', 0.0], ['#FFFFFF', 1]]
    })
    .padding(10)
  }

  @Builder
  attractionList(title: string, data: HotSearchType[]) {
    Column() {
      Text(title).fontSize(15).fontColor('#AD5D24').margin({ bottom: 12 })
      ForEach(data, (item: HotSearchType, index: number) => {
        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Image(index > 2 ? $r('app.media.ic_ranking_second') : $r('app.media.ic_ranking_first'))
              .width(14)
              .height(16)
            Text((index + 1).toString())
              .fontColor(index > 2 ? 'rgba(0, 0, 0, 0.50)' : '#C1753F')
              .fontSize(10)
          }

          Column() {
            Text(item.name)
              .fontSize(13)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Row() {
              Text(item.rating).fontSize(11).fontColor('#C1753F').margin({ right: 8 })
              Text(item.distance).fontSize(11).fontColor('#C1753F')
            }
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
        }.height(32).margin({ top: 16 })
        .onClick(() => {
          if (index === 0 && !this.userInfo.isLogin) {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.LOGIN_PAGE
            })
            return
          }
          if (index === 0 && title === '周边热搜榜') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.TOUR_DETAIL_PAGE,
              builder: wrapBuilder(TourDetailPageBuilder),
              param: this.vm.mockTourList[1]
            })
          }
          if (index === 0 && title === '景点热搜榜') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.TOUR_DETAIL_PAGE,
              builder: wrapBuilder(TourDetailPageBuilder),
              param: this.vm.mockTourList[0]
            })
          }
          if (index === 0 && title === '酒店热搜榜') {
            const param: HotelDetailsParam = {
              hotelModel: this.vm.hotelList[0],
              hotelDate: new HotelDateModel(),
              hotelPageVM: new HotelPageVM()
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HOTEL_DETAILS_PAGE,
              builder: wrapBuilder(HotelDetailsPageBuilder),
              param: param
            })
          }
        })
      }, (item: HotSearchType) => item.toString())
    }
    .alignItems(HorizontalAlign.Start)
    .width('42%')
    .borderRadius(12)
    .borderColor('#FAD7BD')
    .borderWidth(0.5)
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向
      colors: [['#FFFAF6', 0.0], ['#FFFFFF', 1]]
    })
    .padding(10)
  }

  @Builder
  rankingList() {
    if (this.collapseExpandState) {
      Scroll(this.scroller) {
        Row({ space: 8 }) {
          this.collapseExpandAttractionList('周边热搜榜', this.vm.hotSearchList)
          this.collapseExpandAttractionList('景点热搜榜', this.vm.hotTourList)
          this.collapseExpandAttractionList('酒店热搜榜', this.vm.hotHotelList)
        }
        .padding({ left: 16, right: 16 }).width('100%').justifyContent(FlexAlign.SpaceBetween)
      }.scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off).layoutWeight(1).edgeEffect(EdgeEffect.Spring)

    } else {
      Scroll(this.scroller) {
        Column() {
          Scroll(this.scroller) {
            Row({ space: 8 }) {
              this.attractionList('周边热搜榜', this.vm.hotSearchList)
              this.attractionList('景点热搜榜', this.vm.hotTourList)
              this.attractionList('酒店热搜榜', this.vm.hotHotelList)
            }
            .padding({ left: 16, right: 16 })
          }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
        }
      }.scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off).layoutWeight(1).edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  imageBuilder() {
    Row() {
      ForEach(this.vm.allClassificationList, (item: SearchImgType, index: number) => {
        Row() {
          Image(item.img)
            .width(14)
            .height(14)
            .objectFit(ImageFit.Contain)
            .margin({ right: 5 })

          Text(item.text)
            .fontSize(12)
            .lineHeight(14)
            .fontColor('#333333')
        }
        .width(75)
        .height(28)
        .backgroundColor('#F3F3F3')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .borderRadius(14)
        .onClick(() => {
          this.jumpPage(index)
        })
      }, (item: SearchImgType) => item.toString())
    }
    .margin({ top: 8 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  hotSearch() {
    Column() {
      Row() {
        Text('热门推荐').fontSize(16).fontColor('rgba(0,0,0,0.90)');
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 17 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.searchController.hotSearch, (item: string) => {
          Text(item)
            .labelStyle()
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchOptionResult();
            });
        }, (item: string, index) => item + index.toString());
      };
    }.margin({ bottom: 26 })
  }

  @Builder
  historyBuilderSearch() {
    Column() {
      Row() {
        Text('搜索历史').fontSize(16).fontColor('rgba(0,0,0,0.90)');
        Blank();
        if (this.vm.isDeleteStatus) {
          Row() {
            Text('全部删除').fontSize(14).fontColor('rgba(0, 0, 0, 0.50)')
              .onClick(() => {
                this.searchController.historySearch = [];
              });
            Column().width(1).height(10).backgroundColor('rgba(0, 0, 0, 0.10)').margin({ left: 12, right: 12 })
            Text('完成').fontSize(14).fontColor('rgba(0, 0, 0, 0.50)')
              .onClick(() => {
                this.vm.isDeleteStatus = false;
              });
          }
        } else {
          Text('删除').fontSize(14).fontColor('rgba(0, 0, 0, 0.50)')
            .onClick(() => {
              this.vm.isDeleteStatus = true;
            });
        }
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.searchController.historySearch, (item: string, index: number) => {
          if (this.vm.isDeleteStatus) {
            Row() {
              Text(item).fontColor('rgba(0,0,0,0.60)').fontSize(14)
              Image($r('app.media.ic_search_delete')).height(14).margin({ left: 2 }).width(14)
            }.padding({
              top: 6,
              bottom: 6,
              left: 12,
              right: 12,
            })
            .backgroundColor('#F8F8F8')
            .borderRadius(15)
            .onClick(() => {
              this.searchController.historySearch.splice(index, 1);
            })

          } else {
            Text(item).labelStyle()
              .onClick(() => {
                this.searchController.searchCondition = item;
                this.searchController.isShowResult = true;
                this.searchController.updateHistorySearch(item);
                this.getSearchOptionResult();
              });
          }
        }, (item: string) => item.toString());
      };
    }
    .padding({
      bottom: px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  @Builder
  searchResultBuilder() {
    Column() {
      ForEach(this.vm.searchList, (item: HotelModel) => {
        Row() {
          Image($r('app.media.ic_search_item'))
            .width(16)
            .height(16);

          Text() {
            Span(this.searchController.searchCondition)
              .fontColor('#3F7FFF')
            Span(item.name.replaceAll(this.searchController.searchCondition, ''))
              .fontColor('#333333')
          }
          .fontSize(14)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .padding({
            left: 10,
          })

        }
        .height(44)
        .width('100%')
        .margin({
          top: 7,
          bottom: 7,
        })
        .onClick(() => {
          if (!this.userInfo.isLogin) {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.LOGIN_PAGE
            })
          } else {
            const param: HotelDetailsParam = {
              hotelModel: item,
              hotelDate: new HotelDateModel(),
              hotelPageVM: new HotelPageVM()
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HOTEL_DETAILS_PAGE,
              builder: wrapBuilder(HotelDetailsPageBuilder),
              param: param
            })
          }
        });
      }, (item: HotelModel) => item.toString());
    }.margin({ top: 8 })
  }
}

@Extend(Text)
function labelStyle() {
  .padding({
    top: 6,
    bottom: 6,
    left: 12,
    right: 12,
  })
  .backgroundColor('#F8F8F8')
  .fontSize(14)
  .borderRadius(15)
  .fontColor('rgba(0,0,0,0.60)')
  .focusable(true)
  .focusOnTouch(true);
}
