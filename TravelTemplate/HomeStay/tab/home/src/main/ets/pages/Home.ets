import { common } from '@kit.AbilityKit';
import {
  CalendarUtil,
  CustomCalendarPickerDialog,
  DateInfo,
  DateModel,
  getLastDayOfMonth,
  getRealTimeDate,
  Price,
} from 'calendar_select';
import { Constants, NavPathName } from 'constant';
import { CarouselImage, RoomType } from 'type';
import { AccountUtil, Logger } from 'util';
import { BasicInfoArea } from '../components/BasicInfoArea';
import { EnhancedSource } from '../model/Index';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HomeBuilder() {
  Home();
}

@ComponentV2
export struct Home {
  vm: HomePageVM = HomePageVM.instance;
  private swiperController: SwiperController = new SwiperController();
  private scrollerForScroll: Scroller = new Scroller();
  @Local isShow: boolean = false;
  @Local showIndex: number = 0;
  @Local night: number = CalendarUtil.getNight() ?? 1;
  @Local readyCloseDialog: boolean = false;
  @Local priceList: Price[] = [];
  @Local currentMonthDay: number[] = [];
  @Local startDate: DateModel = CalendarUtil.getStartDate();
  @Local endDate: DateModel = CalendarUtil.getEndDate();
  @Local currentUser: string | undefined = AccountUtil.getUserId();
  @Consumer('homeTabIndex') homeTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomCalendarPickerDialog({
      priceList: this.priceList,
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    onWillDismiss: () => {
      this.dialogController.close();
    },
  });

  aboutToAppear() {
    this.initialDate();
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.on('reLogin',
      (uid: string) => {
        AccountUtil.setUserId(uid);
        if (!AccountUtil.getAvatar()) {
          AccountUtil.setAvatar($r('app.media.avatar'));
          AccountUtil.setNickName('华为用户');
        }
      });
  }

  aboutToDisappear(): void {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.off('reLogin');
  }

  initialDate() {
    // 首次初始化
    let dates: Promise<undefined> = new Promise(() => {
      if (!AppStorage.get('startDate') && !AppStorage.get('endDate')) {
        this.startDate = getRealTimeDate();
        let date = new Date();
        let days = getLastDayOfMonth(date.getFullYear(), date.getMonth());
        if (this.startDate.day >= days) {
          this.endDate =
            new DateModel(this.startDate.day - days + 1, this.startDate.week, this.startDate.month + 1,
              this.startDate.year);
        } else {
          this.endDate =
            new DateModel(this.startDate.day + 1, this.startDate.week, this.startDate.month, this.startDate.year);
        }

        CalendarUtil.setStartDate(this.startDate);
        CalendarUtil.setCurrentDate(this.startDate);
        CalendarUtil.setEndDate(this.endDate);
      }
    });

    dates.then(() => {
      Logger.info('init date success with startDate ' + this.startDate);
    });
  }

  @Builder
  DateAreaBuilder() {
    DateInfo(
      {
        priceList: [],
      })
      .backgroundColor('#f5f6fa')
      .borderRadius(8);
  }

  @Builder
  RoomInfoCard(item: RoomType) {
    Column({ space: 8 }) {
      Image(item.roomTypeBanner).height(120).borderRadius(8).width('100%');

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
          Span(`${this.vm.getPriceByDate(item.roomTypePriceList, CalendarUtil.getCurrentDate(), 0)}`)
            .fontWeight(500);
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
            let currentUser = AccountUtil.getUserId();
            if (!currentUser) {
              this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                this.currentUser = popInfo.result;
                AccountUtil.setUserId(popInfo.result);
                (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit('reLogin',
                  popInfo.result);
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
    }.width('100%').onClick(() => {
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
      }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);
    }.hideTitleBar(true);
  }
}