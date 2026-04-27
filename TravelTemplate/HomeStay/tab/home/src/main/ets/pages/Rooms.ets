import { common } from '@kit.AbilityKit';
import { CalendarUtil, CustomCalendarPickerDialog, DateInfo, DateModel, Price } from 'calendar_select';
import { TitleBar } from 'component';
import { Constants, NavPathName } from 'constant';
import { RoomType } from 'type';
import { Logger, AccountUtil } from 'util';
import { EnhancedSource } from '../model/Index';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function RoomsBuilder() {
  Rooms();
}

@Extend(Button)
function operateButton() {
  .fontSize(12)
  .height(28)
  .padding({
    left: 12,
    right: 12,
    top: 6,
    bottom: 6,
  });
}

@ComponentV2
export struct Rooms {
  vm: HomePageVM = HomePageVM.instance;
  @Local night: number = CalendarUtil.getNight() ?? 1;
  @Local isShowPrice: boolean = true;
  @Local currentUser: string | undefined = AccountUtil.getUserId();
  @Local priceList: Price[] = [];
  @Local currentMonthDay: number[] = [];
  @Local currentMonth: number = CalendarUtil.getCurrentDate().month;
  @Local currentDay: number = CalendarUtil.getCurrentDate().day;
  @Local currentYear: number = CalendarUtil.getCurrentDate().year;
  @Local startDate: DateModel = CalendarUtil.getStartDate();
  @Local endDate: DateModel = CalendarUtil.getEndDate();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
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

  @Builder
  RoomListBuilder() {
    List({ space: 16 }) {
      LazyForEach(this.vm.roomData, (roomTypeItem: RoomType) => {
        ListItem() {
          Column({ space: 10 }) {
            Image(roomTypeItem.roomTypeBanner).width(Constants.FULL_SCREEN).height(176).borderRadius(8);

            Column() {
              Column({ space: 8 }) {
                Text(roomTypeItem.roomTypeName).fontSize(16);
                Text(`${roomTypeItem.roomTypeBedList.length}床·适用${roomTypeItem.occupancyLimit}人`);
                Row({ space: 4 }) {
                  ForEach(roomTypeItem.labelList, (item: string) => {
                    Text(item).fontSize(10).fontColor('#007DFF');
                  }, (item: string) => item);
                };
              }.width(Constants.FULL_SCREEN).alignItems(HorizontalAlign.Start);

              Row() {
                Text() {
                  Span('￥').fontSize(12).fontWeight(500);
                  Span(`${this.vm.getPriceByDate(roomTypeItem.roomTypePriceList, CalendarUtil.getCurrentDate(),
                    0)}`)
                    .fontWeight(500);
                };

                Row({ space: 12 }) {
                  Button('价格日历',
                    { type: ButtonType.Normal, stateEffect: true })
                    .onClick(() => {
                      this.priceList = this.vm.getPriceList(roomTypeItem.roomTypePriceList);

                      this.isShowPrice = true;
                      this.dialogController.open();
                    })
                    .operateButton()
                    .backgroundColor(Color.White)
                    .border({ width: 1, color: '#007DFF', radius: 4 })
                    .fontColor(Color.Black);

                  Button('预订', { type: ButtonType.Normal, stateEffect: true })
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
                    })
                    .operateButton()
                    .borderRadius(4)
                    .backgroundColor('#007DFF')
                    .fontColor(Color.White);
                };
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);
            }.padding({ left: 10, right: 10, bottom: 10 });
          }.backgroundColor(Color.White).borderRadius(8).onClick(() => {
            this.mainPathStack.pushPathByName(NavPathName.HOTEL_DETAIL, roomTypeItem);
          });
        };
      }, (roomTypeItem: RoomType) => roomTypeItem.roomTypeName);
    }.height('calc(100% - 172vp)')
    .scrollBar(BarState.Off);
  }

  @Builder
  DateAreaBuilder() {
    DateInfo(
      {
        priceList: [],
      },
    )
      .backgroundColor(Color.White)
      .borderRadius(8)
      .onClick(() => {
        this.isShowPrice = false;
      });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '房型列表', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column({ space: 16 }) {
          this.DateAreaBuilder();
          this.RoomListBuilder();
        }
        .padding({
          top: 16,
          left: 16,
          right: 16,
          bottom: this.windowBottomHeight,
        })
        .backgroundColor('#F5F6FA');
      };
    }.hideTitleBar(true);
  }
}