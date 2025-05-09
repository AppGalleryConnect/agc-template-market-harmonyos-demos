import { AccountUtil } from 'account';
import {
  CalenderUtil,
  CustomCalendarPickerDialog,
  DateInfo,
  DateModel,
  getLastDayOfMonth,
  getRealTimeDate,
  Price,
} from 'calendar';
import { Constants, NavPathName } from 'constant';
import { CarouselImage, RoomType } from 'type';
import { Logger } from 'util';
import { BasicInfoArea } from '../components/BasicInfoArea';
import { EnhancedSource } from '../model/Index';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HomeBuilder() {
  Home();
}

@Component
export struct Home {
  vm: HomePageVM = HomePageVM.instance;
  private swiperController: SwiperController = new SwiperController();
  private scrollerForScroll: Scroller = new Scroller();
  @State isShow: boolean = false;
  @State showIndex: number = 0;
  @StorageLink('night') night: number = CalenderUtil.getNight() ?? 1;
  @State isShowPrice: boolean = true;
  @State readyCloseDialog: boolean = false;
  @State priceList: Price[] = [];
  @State currentMonthDay: number[] = [];
  @State currentMonth: number | undefined = CalenderUtil.getCurrentDate()?.month;
  @State currentDay: number | undefined = CalenderUtil.getCurrentDate()?.day;
  @State currentYear: number | undefined = CalenderUtil.getCurrentDate()?.year;
  @StorageLink('startDate') startDate: DateModel | undefined = CalenderUtil.getStartDate();
  @StorageLink('endDate') endDate: DateModel | undefined = CalenderUtil.getEndDate();
  @StorageLink('currentUser') currentUser: string | undefined = AccountUtil.getCurrentUser();
  @Consume('homeTabIndex') homeTabIndex: number;
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomCalendarPickerDialog({
      currentMonth: this.currentMonth,
      currentDay: this.currentDay,
      currentYear: this.currentYear,
      startDate: this.startDate,
      endDate: this.endDate,
      night: this.night,
      cancel: this.onCancel,
      isShowPrice: this.isShowPrice,
      readyCloseDialog: this.readyCloseDialog,
      priceList: this.priceList,
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    onWillDismiss: () => {
      this.readyCloseDialog = true;
      setTimeout(() => {
        this.readyCloseDialog = false;
      }, Constants.TRANSITION_DURATION);
    },
  });

  // 点击遮障层退出时的回调
  onCancel() {
  }

  aboutToAppear() {
    this.initialDate();
  }

  initialDate() {
    // 首次初始化
    let dates: Promise<undefined> = new Promise(() => {
      if (!AppStorage.get('startDate') && !AppStorage.get('endDate')) {
        this.startDate = getRealTimeDate();
        let days = getLastDayOfMonth(this.currentYear ?? 2025, this.currentMonth ?? 0);
        if (this.startDate.day >= days) {
          this.endDate =
            new DateModel(this.startDate.day - days + 1, this.startDate.week, this.startDate.month + 1,
              this.startDate.year);
        } else {
          this.endDate =
            new DateModel(this.startDate.day + 1, this.startDate.week, this.startDate.month, this.startDate.year);
        }

        AppStorage.setOrCreate('currentDate', this.startDate);
        AppStorage.setOrCreate('startDate', this.startDate);
        AppStorage.setOrCreate('endDate', this.endDate);
      }
    });

    dates.then(() => {
      Logger.info('init date success with startDate ' + this.startDate);
    });
  }

  @Builder
  BasicInfoBuilder() {
    Row({ space: 8 }) {
      Image($r('app.media.brand')).size({ width: 60, height: 60 }).borderRadius(8);

      Column({ space: 6 }) {
        Row() {
          Text(this.vm.hotelInfo.appInfo.appName)
            .fontSize(20)
            .fontWeight(500)
            .fontColor('#111111')
            .width(200)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Row({ space: 16 }) {
            Image($r('app.media.navigating')).size({ height: 16, width: 16 });
            Image($r('app.media.phone')).size({ height: 16, width: 16 });
          };
        }.justifyContent(FlexAlign.SpaceBetween).width(Constants.FULL_SCREEN);

        Row({ space: 4 }) {
          Image($r('app.media.icon_position')).size({ height: 12, width: 12 });
          Text(this.vm.hotelInfo.appInfo.address).fontSize(12);
        }.alignSelf(ItemAlign.Start);
      }.width('80%');
    }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);
  }

  @Builder
  DateAreaBuilder() {
    DateInfo({
      startDate: CalenderUtil.getStartDate(),
      endDate: CalenderUtil.getEndDate(),
      night: this.night,
      isShowPrice: false,
      priceList: [],
    })
      .backgroundColor('#f5f6fa')
      .borderRadius(8)
      .onClick(() => {
        this.isShowPrice = false;
        this.dialogController.open();
      });
  }

  @Builder
  RoomInfoCard(item: RoomType) {
    Column({ space: 8 }) {
      Image(item.roomTypeBanner).height(120).borderRadius(8);

      Column({ space: 4 }) {
        Text(item.roomTypeName).fontColor('#111111');
        Text(`${item.roomTypeBedList.length}床·适用${item.occupancyLimit}人`).opacity(0.6).fontSize(14);
        Row({ space: 4 }) {
          ForEach(item.labelList, (item: string) => {
            Text(item)
              .fontSize(10)
              .fontColor('#007DFF')
              .backgroundColor('#10007DFF')
              .padding(4)
              .borderRadius(4);
          }, (item: string) => item);
        };
      }.alignItems(HorizontalAlign.Start).width(Constants.FULL_SCREEN);

      Row() {
        Text() {
          Span('￥').fontSize(12).fontWeight(500);
          Span(`${this.vm.getPriceByDate(item.roomTypePriceList, CalenderUtil.getCurrentDate(), 0)}`)
            .fontWeight(500);
          Span('.00').fontSize(12).fontWeight(500);
        };

        Button('预订', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(12)
          .borderRadius(4)
          .backgroundColor('#007DFF')
          .width(48)
          .height(24)
          .padding({
            left: 10,
            right: 10,
            top: 6,
            bottom: 6,
          })
          .onClick(() => {
            if (!this.currentUser) {
              this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                this.currentUser = popInfo.result;
                Logger.info('quick login success');
              });
            } else {
              this.mainPathStack.pushPathByName(NavPathName.RESERVE, {
                source: 'HotelDetail',
                data: item,
              } as EnhancedSource);
            }
          });
      }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);
    }.onClick(() => {
      this.mainPathStack.pushPathByName(NavPathName.HOTEL_DETAIL, item);
    });
  }

  @Builder
  RecommendRoomListBuilder() {
    Column() {
      Grid() {
        LazyForEach(this.vm.roomData, (item: RoomType) => {
          if (item.isRecommended) {
            GridItem() {
              this.RoomInfoCard(item);
            };
          }
        });
      }
      .columnsTemplate('1fr 1fr')
      .scrollBar(BarState.Off)
      .rowsGap(10)
      .columnsGap(10)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      }) ;

      Row() {
        Text('查看更多')
          .fontSize(12)
          .fontColor('#999999');
        Image($r('app.media.icon_direction_right_gray'))
          .size({
            width: 12,
            height: 12,
          })
          .objectFit(ImageFit.Contain);
      }
      .onClick(() => {
        this.mainPathStack.pushPathByName(NavPathName.ROOMS, null);
      })
      .margin({ top: 24 })
      .padding({
        left: 16,
        right: 16,
        top: 4,
        bottom: 4,
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#F5F6FA')
      .borderRadius(4);
    };
  }

  build() {
    NavDestination() {
      Scroll(this.scrollerForScroll) {
        Column() {
          Swiper(this.swiperController) {
            LazyForEach(this.vm.swiperData, (item: CarouselImage) => {
              Image(item.image).height(320).width(Constants.FULL_SCREEN);
            }, (item: CarouselImage) => item.id.toString());
          }.cachedCount(2).loop(false).indicator(new DotIndicator()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .color('#F5F6FA')
            .selectedColor($r('sys.color.comp_background_emphasize')));

          Column({ space: 20 }) {
            BasicInfoArea({ isHome: true });
            this.DateAreaBuilder();
            this.RecommendRoomListBuilder();
          }.borderRadius({ topLeft: 8, topRight: 8 })
          .width(Constants.FULL_SCREEN).padding(12);
        };
      }.scrollBar(BarState.Off);
    }.hideTitleBar(true);
  }
}