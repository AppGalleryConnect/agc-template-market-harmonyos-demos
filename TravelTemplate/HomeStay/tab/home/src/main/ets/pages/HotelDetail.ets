import { Constants, NavPathName } from 'constant';
import { TitleBar } from 'component';
import { CalenderUtil, DateInfo, DateModel, Price } from 'calendar';
import { RoomType } from 'type';
import { Foundations } from '../components/Foundations';
import { Reservation } from '../components/Reservation';
import { Checkout } from '../components/Checkout';
import { EnhancedSource } from '../model/Index';
import { AccountUtil } from 'account';
import { Logger } from 'util';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HotelDetailBuilder() {
  HotelDetail();
}

@Component
export struct HotelDetail {
  vm: HomePageVM = HomePageVM.instance;
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  detailScroller = new Scroller();
  scroller = new Scroller();
  @State roomType: RoomType = new RoomType();
  @State scrollIndex: number = 0;
  @State activeIndex: number = 0;
  @State startDate: DateModel | undefined = CalenderUtil.getStartDate();
  @State endDate: DateModel | undefined = CalenderUtil.getEndDate();
  @State night: number = CalenderUtil.getNight() ?? 1;
  @State priceList: Price[] = [];
  @StorageLink('currentUser') currentUser: string | undefined = AccountUtil.getCurrentUser();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          TitleBar({
            isShowBack: true, title: this.vm.tenantInfo?.appName ?? '', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Scroll() {
            Column() {
              Swiper() {
                Image(this.roomType.roomTypeBanner).height(300);
              }.indicator(new DotIndicator()
                .itemWidth(6)
                .itemHeight(6)
                .selectedItemWidth(12)
                .selectedItemHeight(6)
                .color('#F5F6FA')
                .selectedColor($r('sys.color.comp_background_emphasize')))
              .width(Constants.FULL_SCREEN);

              Column() {
                Column() {
                  Text(this.roomType.roomTypeName)
                    .fontSize(20)
                    .fontWeight(500)
                    .width(Constants.FULL_SCREEN)
                    .textAlign(TextAlign.Start)
                    .padding({ left: 16, right: 16, top: 16 });

                  Column({ space: 16 }) {
                    DateInfo({
                      startDate: this.startDate,
                      endDate: this.endDate,
                      night: this.night,
                      isShowPrice: true,
                      priceList: this.priceList,
                    })
                      .backgroundColor('#F5F6FA').borderRadius(8);
                  }.padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start).margin({ top: 16 });
                };

                Column() {
                  Foundations({ foundations: this.roomType.instructions?.foundations })
                    .padding({ left: 16, right: 16 }).margin({ top: 16 });
                  Reservation({
                    reservation: this.roomType.instructions?.reservation,
                  }).padding({ left: 16, right: 16 }).margin({ top: 16 });
                  Checkout({
                    checkOut: this.roomType.instructions.checkOut,
                  }).padding({ left: 16, right: 16 });
                };
              };
            };
          }.height('75%').align(Alignment.Top).scrollBar(BarState.Off);
        };

        Row() {
          Text() {
            Span('￥').fontSize(12).fontWeight(500).fontColor('#F0353A');
            Span(`${this.vm.getPriceByDate(this.roomType.roomTypePriceList, CalenderUtil.getCurrentDate(), 0)
              .toFixed(2)}`)
              .fontSize(20)
              .fontWeight(500)
              .fontColor('#F0353A');
          };

          Button('预订')
            .backgroundColor('#007DFF')
            .fontSize(14)
            .width(72)
            .height(32)
            .borderRadius(8)
            .padding({
              left: 12,
              right: 12,
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
                  data: this.roomType,
                } as EnhancedSource);
              }
            });
        }
        .position({ y: '90%' })
        .height('10%')
        .padding({ left: 16, right: 16 })
        .shadow({
          radius: 2,
          color: '#F5F6FA',
          offsetX: 0,
          offsetY: -5,
        })
        .width(Constants.FULL_SCREEN)
        .justifyContent(FlexAlign.SpaceBetween);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.roomType = context.pathInfo.param as RoomType;
      this.priceList = this.vm.getPriceList(this.roomType.roomTypePriceList);
    });
  }
}
