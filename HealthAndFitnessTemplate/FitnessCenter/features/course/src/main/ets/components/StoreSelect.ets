import {
  CoachCourseInfo,
  CourseBookingInfo, Logger, MockService,
  SportType
} from 'external_interactions';
import { ScreenPropStorage , BookingRestQuotaUpdate, BookJumpSearch} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { EmitterConstant } from 'external_interactions'
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { CategoryItem, CategoryList, LayoutType, StoreItem } from 'category_list';
import { storeData2, storeData1 } from './StoreData';
import { PresentationType, SearchItem, SearchView, SearchViewController } from 'search';

const TAG: string = '[StoreSelect]';

@ComponentV2
export struct StoreSelectPage {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local bookingRestQuotaUpdateStorage : BookingRestQuotaUpdate = AppStorageV2.connect(BookingRestQuotaUpdate, 'BookingRestQuotaUpdate', () =>new BookingRestQuotaUpdate())!
  @Local bookJumpSearchStorage : BookJumpSearch = AppStorageV2.connect(BookJumpSearch, 'BookJumpSearch', () =>new BookJumpSearch())!

  teachTypeList: string[] = ['团课', '私教'];
  @Local teachTypeIndex: number = 0;
  @Local sportTypeList: SportType[] = [];
  @Local sportTypeIndex: number = 0;
  @Local dateList: Date[] = [];
  @Local dateSelectIndex: number = 0;
  @Local storeInfoList: StoreItem[] = [];
  @Local coachCourseInfoList: CoachCourseInfo[] = [];
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local searchWord: string = ''
  @Local cardIndex: number = 0
  @Local bookingRestQuotaUpdate: boolean = this.bookingRestQuotaUpdateStorage.bookingRestQuotaUpdate
  @Param mainTabIndex: number = 0;
  @Local update: boolean = false
  @Local currentCity: string = AppStorage.get('currentCity') ?? '北京'
  @Local currentIndex: number = 0
  @Local themeColor: ResourceColor = '#0A59F7'

  @Local list1: StoreItem[] = [];
  @Local storeCategoryList: StoreItem[] = this.list1
  @Local tabList: CategoryItem[] = [{
    id: '1',
    label: '全市'
  }];
  @Local breakpoint: string = '';
  controller: SearchViewController = new SearchViewController();

  aboutToAppear(): void {
    this.initData()
    try {
      emitter.on(EmitterConstant.REFRESH_DATA, () =>{
        this.initData()
      })
    } catch (e) {
      Logger.error(TAG, `emitter on failed. error: ${JSON.stringify(e)}`)
    }
    this.getUIContext().getHostContext()?.eventHub.on('currentCity', (currentCity: string) => {
      this.currentCity = currentCity
    })
    if (this.currentCity.includes('北京')) {
      this.storeCategoryList = storeData1
    } else if (this.currentCity.includes('南京')) {
      this.storeCategoryList = storeData2
    }
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()?.eventHub.off('currentCity')
  }

  private initData(){
    this.dateList = this.buildDateList();
    this.searchStoreList();
  }
  private buildDateList(): Date[] {
    let dateSelectList: Date[] = [];
    let newDate: Date = new Date();
    for (let index = 0; index < 7; index++) {
      dateSelectList.push(new Date(newDate));
      newDate.setTime(newDate.getTime() + 24 * 60 * 60 * 1000);
    }
    return dateSelectList;
  }
  @Monitor('bookingRestQuotaUpdateStorage.bookingRestQuotaUpdate')
  searchStoreList() {
    let list: StoreItem[] = []
    if (this.currentCity.includes('北京')) {
      storeData1.forEach((item: StoreItem) => {
        if (item.name.includes(this.searchWord)) {
          list.push(item)
        }
      })
    } else if (this.currentCity.includes('南京')) {
      storeData2.forEach((item: StoreItem) => {
        if (item.name.includes(this.searchWord)) {
          list.push(item)
        }
      })
    }
    this.storeInfoList = list
  }

  @Builder
  itemBuilder(item: StoreItem) {
    Row() {
      Row() {
        Image($r('app.media.store'))
          .width(24)
          .margin({ right: 8 })
        Text(item.name)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
      }
      Text(item.distance)
        .width(36)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    Text(item.address)
      .width('100%')
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(TextAlign.Start)
      .margin({ top: 8 })
  }

  getStoreList(tabItem: CategoryItem) {
    if (this.currentCity.includes('北京')) {
      this.storeCategoryList = storeData1.filter(store => store.categoryName === tabItem.label);
      if (tabItem.label === '全市') {
        this.storeCategoryList = storeData1
      }
    } else if (this.currentCity.includes('南京')) {
      this.storeCategoryList = storeData2.filter(store => store.categoryName === tabItem.label);
      if (tabItem.label === '全市') {
        this.storeCategoryList = storeData2
      }
    }
  }

  @Builder
  storeSearchBuilder(item: StoreItem) {
    Row() {
      Row() {
        Image($r('app.media.store'))
          .width(24)
          .margin({ right: 8 })
        Text(item.name)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .margin({ left: 8 })
      }

      Text(item.distance)
        .width(36)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    Text(item.address)
      .width('100%')
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(TextAlign.Start)
      .margin({ top: 8 })
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '选择门店',
          onBackClick:()=>{
            this.pathStack.pop()
          }
        })
          .width('95%')
        // 搜索框
        Row() {
          SearchView({
            presentationType: this.breakpoint === 'sm' ? PresentationType.SEARCH_ICON : PresentationType.SEARCH_BOX,
            entranceText: ['搜索门店...'],
            routerStack: this.pathStack,
            controller: this.controller,
            isShallowWindow: true,
            storeSearchResult: this.storeInfoList,
            onClickGetMore: () => {
              this.getUIContext().getPromptAction().showToast({ message: '前往更多页，暂未开发' })
            },
            onClickResultItem: (listItem: SearchItem) => {
              this.getUIContext().getPromptAction().showToast({ message: '前往详情页，暂未开发' })
            },
          })
        }
        .width('95%')
        .justifyContent(FlexAlign.Center)

        RelativeContainer() {
          CategoryList({
            categoryTabs: this.tabList,
            productList: this.storeCategoryList,
            initIndex: this.currentIndex,
            layoutType: LayoutType.GRID,
            themeColor: this.themeColor,
            tabBarScroller: new Scroller(),
            subBarScroller: new Scroller(),
            scroller: new Scroller(),
            itemBuilderParam: this.itemBuilder,
            onTabClick: (tabItem: CategoryItem) => {
              this.getStoreList(tabItem)
            },
            onItemClick: (itemDetail: StoreItem) => {
              // 待实现，跳转详情页
              AppStorage.setOrCreate('currentStore', itemDetail.name)
              this.getUIContext().getHostContext()?.eventHub.emit('currentStore', itemDetail.name)
              this.pathStack.pop()
            },
          })
        }.height('80%').width('100%')
      }
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('app.color.main_background_color'))
      .padding({ top: this.getUIContext().px2vp(this.screenPropStorage.topRectHeight) })
      .height('100%')
      .width('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      this.currentCity = ctx?.pathInfo?.param as string
      if (this.currentCity.includes('北京')) {
        this.tabList.push({
          id: '3',
          label: '东城区'
        },
          {
            id: '4',
            label: '西城区'
          },
          {
            id: '5',
            label: '朝阳区'
          },
          {
            id: '6',
            label: '丰台区'
          },
          {
            id: '7',
            label: '石景山区'
          },
          {
            id: '8',
            label: '海淀区'
          },
          {
            id: '9',
            label: '门头沟区'
          },
          {
            id: '10',
            label: '房山区'
          },
          {
            id: '11',
            label: '通州区'
          },
          {
            id: '12',
            label: '顺义区'
          },
          {
            id: '13',
            label: '昌平区'
          },
          {
            id: '14',
            label: '大兴区'
          },
          {
            id: '15',
            label: '怀柔区'
          },
          {
            id: '16',
            label: '平谷区'
          },
          {
            id: '17',
            label: '密云区'
          },
          {
            id: '18',
            label: '延庆区'
          })
      }
      if (this.currentCity.includes('南京')) {
        this.tabList.push({
          id: '20',
          label: '玄武区'
        },
          {
            id: '21',
            label: '秦淮区'
          },
          {
            id: '22',
            label: '建邺区'
          },
          {
            id: '23',
            label: '鼓楼区'
          },
          {
            id: '24',
            label: '浦口区'
          },
          {
            id: '25',
            label: '栖霞区'
          },
          {
            id: '26',
            label: '雨花台区'
          },
          {
            id: '27',
            label: '江宁区'
          },
          {
            id: '28',
            label: '六合区'
          },
          {
            id: '29',
            label: '溧水区'
          },
          {
            id: '30',
            label: '高淳区'
          })
      }
    })
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

@ComponentV2
struct NoCourse {
  build() {
    Column() {
      Image($r('app.media.no_result'))
        .width(144)
        .height(144)
        .margin({ bottom: 12 })
      Text('该日程无排课')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor('#999999')
      Text('请另选时间预约吧~')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor('#999999')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('80%')
  }
}


