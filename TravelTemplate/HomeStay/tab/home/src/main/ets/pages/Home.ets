import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import {
  CalendarUtil,
  DateInfo,
  DateModel,
  getRealTimeDate,
} from 'calendar_select';
import { CommonHeader } from 'component';
import { Constants, NavPathName } from 'constant';
import { RoomType } from 'type';
import { AccountUtil, Logger } from 'util';
import { BasicInfoArea } from '../components/BasicInfoArea';
import { EnhancedSource } from '../model/Index';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HomeBuilder() {
  Home();
}

@Builder
export function HotelHomeBuilder() {
  Home({ isHotelDetail: true });
}

@ComponentV2
export struct Home {
  @Param isHotelDetail: boolean = false;
  vm: HomePageVM = HomePageVM.instance;
  private scrollerForScroll: Scroller = new Scroller();
  private flowScroller: Scroller = new Scroller();
  @Local isShow: boolean = false;
  @Local showIndex: number = 0;
  @Local currentUser: string | undefined = AccountUtil.getUserId();
  @Local breakpoint: string = 'sm';
  @Consumer('homeTabIndex') homeTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

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
    let dates: Promise<undefined> = new Promise(() => {
      if (!AppStorage.get('startDate') && !AppStorage.get('endDate')) {
        let startDate = getRealTimeDate();
        let nextDate = new Date(startDate.year, startDate.month - 1, startDate.day + 1);
        let endDate =
          new DateModel(nextDate.getDate(), nextDate.getDay(), nextDate.getMonth() + 1, nextDate.getFullYear());

        CalendarUtil.setStartDate(startDate);
        CalendarUtil.setCurrentDate(startDate);
        CalendarUtil.setEndDate(endDate);
      }
    });

    dates.then(() => {
      Logger.info('init date success');
    });
  }

  @Builder
  DateAreaBuilder() {
    DateInfo(
      {
        priceList: [],
      })
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16);
  }

  @Builder
  RoomInfoCard(item: RoomType) {
    Column({ space: 8 }) {
      Image(item.roomTypeBanner).height(76).borderRadius(8).width('100%');

      Column({ space: 4 }) {
        Text(item.roomTypeName).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
        Text(`整套${item.bedroomNum}室·${item.roomTypeBedList.length}床·适用${item.occupancyLimit}人`)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(12);
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(4), cross: LengthMetrics.vp(4) } }) {
          ForEach(item.labelList, (item: string) => {
            Text(item)
              .fontSize(10)
              .fontColor($r('sys.color.font_emphasize'))
              .backgroundColor($r('sys.color.comp_emphasize_tertiary'))
              .padding({ top: 4, bottom: 4, left: 7, right: 7 })
              .borderRadius(16);
          }, (item: string) => item);
        };
      }.alignItems(HorizontalAlign.Start).width(Constants.FULL_SCREEN);

      Row() {
        Text(`￥${this.vm.getPriceByDate(item.roomTypePriceList, CalendarUtil.getCurrentDate(), 0)}`)
          .fontSize(14).fontColor($r('sys.color.multi_color_08')).width('50%');

        Button('预订', { type: ButtonType.Normal, stateEffect: true })
          .fontSize($r('sys.float.Body_M'))
          .borderRadius($r('sys.float.corner_radius_level7'))
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .height(28)
          .width('50%')
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4,
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
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding(12)
    .onClick(() => {
      this.mainPathStack.pushPathByName(NavPathName.HOTEL_DETAIL, item);
    });
  }

  @Builder
  RecommendRoomListBuilder() {
    Column() {
      Row() {
        Text('房型推荐')
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Row({ space: 4 }) {
          Text('查看更多')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'));
          Image($r('app.media.icon_direction_right_gray'))
            .size({
              width: 12,
              height: 24,
            })
            .objectFit(ImageFit.Contain);
        }
        .onClick(() => {
          this.mainPathStack.pushPathByName(NavPathName.ROOMS, null);
        })
      }.margin({ bottom: 8 }).justifyContent(FlexAlign.SpaceBetween);

      WaterFlow({ scroller: this.flowScroller }) {
        LazyForEach(this.vm.roomData, (item: RoomType) => {
          if (item.isRecommended) {
            FlowItem() {
              this.RoomInfoCard(item);
            };
          }
        });
      }
      .columnsTemplate(GridRowColSetting.getWaterFloColumns(this.breakpoint))
      .scrollBar(BarState.Off)
      .rowsGap(10)
      .columnsGap(10)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      });
    };
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Scroll(this.scrollerForScroll) {
            Column() {
              Stack() {
                Image($r('app.media.home_head'))
                  .height(276)
                  .width(Constants.FULL_SCREEN)
                  .linearGradientBlur(200,
                    { fractionStops: [[0, 0], [0, 0.33], [1, 0.66], [1, 1]], direction: GradientDirection.Top });
                CommonHeader({
                  title: this.isHotelDetail ? '民宿详情' : '首页',
                  showBackButton: this.isHotelDetail,
                  backButtonClick: () => {
                    this.mainPathStack.pop();
                  },
                })
              }.alignContent(Alignment.TopStart)

              Column({ space: 12 }) {
                BasicInfoArea({ isHome: true });
                this.DateAreaBuilder();
                this.RecommendRoomListBuilder();
              }.borderRadius({ topLeft: 8, topRight: 8 })
              .backgroundColor($r('sys.color.background_secondary'))
              .width(Constants.FULL_SCREEN).padding(12);
            };
          }.scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .backgroundColor($r('sys.color.background_secondary'));
        }
      }
      .onBreakpointChange((breakpoints: string) => {
        this.breakpoint = breakpoints;
      })
    }.hideTitleBar(true);
  }
}