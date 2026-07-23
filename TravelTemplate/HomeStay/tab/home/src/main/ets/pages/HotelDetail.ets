import { common } from '@kit.AbilityKit';
import { Constants, NavPathName } from 'constant';
import { CommonHeader } from 'component';
import { CalendarUtil, DateInfo, DateModel, Price } from 'calendar_select';
import { RoomType, Tag } from 'type';
import { EnhancedSource } from '../model/Index';
import { Logger, AccountUtil } from 'util';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HotelDetailBuilder() {
  HotelDetail();
}

@ComponentV2
export struct HotelDetail {
  vm: HomePageVM = HomePageVM.instance;
  detailScroller = new Scroller();
  scroller = new Scroller();
  @Local roomType: RoomType = new RoomType();
  @Local scrollIndex: number = 0;
  @Local activeIndex: number = 0;
  @Local startDate: DateModel | undefined = CalendarUtil.getStartDate();
  @Local endDate: DateModel | undefined = CalendarUtil.getEndDate();
  @Local night: number = CalendarUtil.getNight() ?? 1;
  @Local priceList: Price[] = [];
  @Local currentUser: string | undefined = AccountUtil.getUserId();
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

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '房间详情', showBackButton: true, backButtonClick: () => {
          this.mainPathStack.pop();
        }})

        Scroll() {
          Column({ space: 16 }) {
            Image(this.roomType.roomTypeBanner)
              .height(184)
              .width(Constants.FULL_SCREEN)
              .borderRadius(16);

            Row() {
              Text(this.roomType.roomTypeName)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
                .margin({ right: 12 })
              Row({ space: 8 }) {
                ForEach(this.roomType.labelList, (label: string) => {
                  Text(label)
                    .fontSize(10)
                    .fontColor($r('sys.color.font_emphasize'))
                    .backgroundColor($r('sys.color.comp_emphasize_tertiary'))
                    .padding({ top: 4, bottom: 4, left: 7, right: 7 })
                    .borderRadius(16)
                }, (label: string, index: number) => `${label}_${index}`)
              }
            }
            .width(Constants.FULL_SCREEN)
            .alignItems(VerticalAlign.Center)

            Row() {
              Text('价格可能浮动，请尽快预定')
                .fontSize(12)
                .fontColor($r('sys.color.warning'))
              Text(`￥${this.vm.getPriceByDate(this.roomType.roomTypePriceList, CalendarUtil.getCurrentDate(), 0)}`)
                .fontSize(12)
                .fontColor($r('sys.color.warning'))
            }
            .width(Constants.FULL_SCREEN)
            .justifyContent(FlexAlign.SpaceBetween)

            DateInfo({ priceList: [] })
              .backgroundColor($r('sys.color.comp_background_primary')).borderRadius(16)

            Row() {
              ForEach(this.roomType.instructions?.foundations ?? [], (item: Tag) => {
                Column({ space: 4 }) {
                  if (item.tag === '大小') {
                    Image($r('app.media.room_size')).size({ width: 24, height: 24 })
                  } else if (item.tag === '楼层') {
                    Image($r('app.media.floor_level')).size({ width: 24, height: 24 })
                  } else if (item.tag === '网络') {
                    Image($r('app.media.room_internet')).size({ width: 24, height: 24 })
                  } else if (item.tag === '采光') {
                    Image($r('app.media.room_light')).size({ width: 24, height: 24 })
                  } else if (item.tag === '床铺') {
                    Image($r('app.media.room_bed')).size({ width: 24, height: 24 })
                  }
                  Text(item.subTags[0] ?? '')
                    .fontSize(12)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }, (item: Tag, index: number) => `${item.tag}_${index}`)
            }
            .width(Constants.FULL_SCREEN)
            .justifyContent(FlexAlign.SpaceAround)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .padding(12)
            .borderRadius(16)

            Column({ space: 12 }) {
              ForEach(this.roomType.instructions?.reservation ?? [], (item: Tag) => {
                Row({ space: 8 }) {
                  Text(item.tag)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .width(56)
                    .flexShrink(0)
                    .lineHeight(16)
                  Text(item.subTags.join('，'))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_primary'))
                    .layoutWeight(1)
                    .lineHeight(16)
                }.alignItems(VerticalAlign.Top).width(Constants.FULL_SCREEN)
              }, (item: Tag, index: number) => `${item.tag}_${index}`)
            }
            .width(Constants.FULL_SCREEN)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .padding(12)
            .borderRadius(16)

            Button('预订房间')
              .backgroundColor($r('sys.color.background_emphasize'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
              .width(Constants.FULL_SCREEN)
              .height(40)
              .constraintSize({ maxWidth: 448 })
              .borderRadius($r('sys.float.corner_radius_level10'))
              .margin({ top: 8, bottom:  16 })
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
                  this.mainPathStack.pushPathByName(NavPathName.RESERVE, {
                    source: 'HotelDetail',
                    data: this.roomType,
                  } as EnhancedSource);
                }
              })
          }
          .width(Constants.FULL_SCREEN)
          .padding({ left: 16, right: 16, top: 4, bottom: 16 })
          .alignItems(HorizontalAlign.Center)
        }.layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.roomType = context.pathInfo.param as RoomType;
      this.priceList = this.vm.getPriceList(this.roomType.roomTypePriceList);
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
