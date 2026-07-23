import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { CalendarUtil, DateInfo } from 'calendar_select';
import { CommonHeader } from 'component';
import { Constants, NavPathName } from 'constant';
import { RoomType } from 'type';
import { Logger, AccountUtil } from 'util';
import { EnhancedSource } from '../model/Index';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function RoomsBuilder() {
  Rooms();
}

@ComponentV2
export struct Rooms {
  vm: HomePageVM = HomePageVM.instance;
  @Local currentUser: string | undefined = AccountUtil.getUserId();
  @Local breakpoint: string = 'sm';
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
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

  reserveRoom(roomTypeItem: RoomType) {
    this.mainPathStack.pushPathByName(NavPathName.RESERVE, {
      source: 'HotelDetail',
      data: roomTypeItem,
    } as EnhancedSource);
  }

  private flowScroller: Scroller = new Scroller();

  @Builder
  RoomListBuilder() {
    WaterFlow({ scroller: this.flowScroller }) {
      LazyForEach(this.vm.roomData, (roomTypeItem: RoomType) => {
        FlowItem() {
          Column({ space: 8 }) {
            Image(roomTypeItem.roomTypeBanner).width(Constants.FULL_SCREEN).height(76).borderRadius(8);

            Column({ space: 4 }) {
              Text(roomTypeItem.roomTypeName).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
              Text(`整套${roomTypeItem.bedroomNum}室·${roomTypeItem.roomTypeBedList.length}床·适用${roomTypeItem.occupancyLimit}人`)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(12);
              Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(4), cross: LengthMetrics.vp(4) } }) {
                ForEach(roomTypeItem.labelList, (item: string) => {
                  Text(item)
                    .fontSize(10)
                    .fontColor($r('sys.color.font_emphasize'))
                    .backgroundColor($r('sys.color.comp_emphasize_tertiary'))
                    .padding({ top: 4, bottom: 4, left: 7, right: 7 })
                    .borderRadius(16);
                }, (item: string) => item);
              };

              Row() {
                Text(`￥${this.vm.getPriceByDate(roomTypeItem.roomTypePriceList, CalendarUtil.getCurrentDate(), 0)}`)
                  .fontSize(14).fontColor($r('sys.color.multi_color_08')).width('50%');

                Button('预订', { type: ButtonType.Normal, stateEffect: true })
                  .fontSize(14)
                  .borderRadius(14)
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
                    if (!this.currentUser) {
                      this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                        this.currentUser = popInfo.result;
                        AccountUtil.setUserId(popInfo.result);
                        (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit('reLogin',
                          popInfo.result);
                        Logger.info('quick login success');
                      });
                    } else {
                      this.reserveRoom(roomTypeItem);
                    }
                  });
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);
            }.alignItems(HorizontalAlign.Start).width(Constants.FULL_SCREEN);
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .padding(12)
          .onClick(() => {
            this.mainPathStack.pushPathByName(NavPathName.HOTEL_DETAIL, roomTypeItem);
          });
        };
      }, (roomTypeItem: RoomType) => roomTypeItem.roomTypeName);
    }
    .columnsTemplate(GridRowColSetting.getWaterFloColumns(this.breakpoint))
    .scrollBar(BarState.Off)
    .rowsGap(10)
    .columnsGap(10);
  }

  @Builder
  DateAreaBuilder() {
    DateInfo(
      {
        priceList: [],
      },
    )
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16);
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Column() {
            CommonHeader({ title: '全部房型', showBackButton: true, backButtonClick: () => {
              this.mainPathStack.pop();
            }});

            Column({ space: 16 }) {
              this.DateAreaBuilder();
              this.RoomListBuilder();
            }
            .padding({
              top: 16,
              left: 16,
              right: 16,
              bottom: this.windowBottomHeight,
            });
          };
        }
      }
      .onBreakpointChange((breakpoints: string) => {
        this.breakpoint = breakpoints;
      })
    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'));
  }
}