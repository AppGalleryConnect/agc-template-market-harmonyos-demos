import { common } from '@kit.AbilityKit';
import { Constant, padWithZeros, routerToPetalMap } from 'common';
import { FullLoadingComponent, SwiperComponent, ViewDetailComponent } from 'components';
import { FunctionModuleData, getFunctionModuleInfo } from '../model/FunctionModuleInfo';
import { RealTimeInfo, RealTimeItem } from '../model/Index';
import { HomePageVM } from '../viewmodel/HomePageVM';
import { getHotAreaInfo, HotAreaInfo } from '../model/HotAreaInfo';
import { ParkingSlotInfo } from '../model/ParkingSlotInfo';

@Builder
export function HomeBuilder() {
  HomeView();
}

@Extend(Text)
function weatherInfoText() {
  .fontSize(10).opacity(0.6);
}

@Extend(Row)
function realTimeRow() {
  .justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
}

@ComponentV2
export struct HomeView {
  vm: HomePageVM = HomePageVM.instance;
  @Local isShow: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Computed
  get currentMonth() {
    if (this.vm.rollUpInfo?.currentDate) {
      return padWithZeros(this.vm.rollUpInfo?.currentDate.getMonth() + 1);
    }
    return '--';
  }

  @Computed
  get apparentTemp() {
    let apparentTemp = '';
    if (!this.vm.rollUpInfo?.temperature) {
      apparentTemp = '未知';
    } else {
      if (this.vm.rollUpInfo?.temperature < 0) {
        apparentTemp = '寒冷';
      } else if (0 < this.vm.rollUpInfo?.temperature ?? 0 <= 10) {
        apparentTemp = '较冷';
      } else if (10 < this.vm.rollUpInfo?.temperature ?? 0 <= 25) {
        apparentTemp = '舒适';
      } else if (26 < this.vm.rollUpInfo?.temperature ?? 0 <= 35) {
        apparentTemp = '较热';
      } else {
        apparentTemp = '炎热';
      }
    }
    return apparentTemp;
  }

  @Builder
  RealTimeInfoBuilder() {
    Column({ space: 8 }) {
      Row() {
        Text(this.vm.rollUpInfo?.name).fontWeight(500);
        this.WeatherInfoBuilder();
      }.realTimeRow().margin({ top: 20 });

      Column() {
        Row() {
          Row() {
            Column() {
              Image($r('app.media.comfort')).size({ width: 14, height: 14 });
              Text('舒适').fontSize(10).fontColor(Color.White);
            }.backgroundColor('#64BB5C').borderRadius(8).margin({ right: 12 }).padding(4);

            ForEach(this.vm.realTimeInfos, (info: RealTimeInfo) => {
              Column() {
                Row({ space: 4 }) {
                  Image(info.icon).size({ width: 14, height: 14 });
                  Text(`${info.count}${info.item === RealTimeItem.CURRENT_VISITOR ? '人' : '车位'}`)
                    .fontWeight(500)
                    .opacity(0.9);
                };

                Text(info.item).fontSize(10).opacity(0.4);
              }.margin({ right: 24 }).alignItems(HorizontalAlign.Center);
            }, (item: RealTimeInfo)=> item.icon.toString());
          };

          ViewDetailComponent().onClick(() => {
            this.isShow = true;
          }).bindSheet($$this.isShow, this.RealTimeInfoDetailBuilder(), {
            height: '40%', title: { title: this.vm.rollUpInfo?.name ?? '' },
          });
        }.realTimeRow();

        Divider().margin({ top: 14, bottom: 14 });

        Row() {
          Row() {
            Image($r('app.media.open_time')).size({ width: 14, height: 14 }).margin({ right: 4 });
            Text() {
              Span('开放时间：');
              Span(this.vm.rollUpInfo?.openTime);
            }.fontSize(10);
          };

          Row() {
            Image($r('app.media.ticket_time')).size({ width: 14, height: 14 }).margin({ right: 4 });
            Text() {
              Span('售票时间：');
              Span(this.vm.rollUpInfo?.ticketTime);
            }.fontSize(10);
          };
        }.realTimeRow();
      }.backgroundColor(Color.White).padding(16).borderRadius(8);
    };
  }

  @Builder
  WeatherInfoBuilder() {
    Row({ space: 8 }) {
      Text(`${this.currentMonth}.${padWithZeros(this.vm.rollUpInfo?.currentDate?.getDate())}`)
        .fontSize(10)
        .opacity(0.6)
        .weatherInfoText();
      Text('|').weatherInfoText();
      Text(this.vm.rollUpInfo?.weatherId ?? '未知').weatherInfoText();
      Text(`${this.vm.rollUpInfo?.temperature}°C`).weatherInfoText();
      Text(this.vm.rollUpInfo?.atmosphereId ?? '未知').fontColor('#2B7050').fontSize(10);
      Text(`${this.apparentTemp}`).weatherInfoText();
    };
  }

  @Builder
  TouristRestriction(key: string, value: number) {
    Column() {
      Text(`${value}`).fontSize(10);
      Text(key).opacity(0.4).fontSize(10);
    }.alignItems(HorizontalAlign.Center);
  }

  @Builder
  RealTimeInfoDetailBuilder() {
    Column({ space: 12 }) {
      Row() {
        this.TouristRestriction('当日累计游客数', this.vm.rollUpInfo?.currentDayVisitors ?? 0);
        this.TouristRestriction('当日最大承载量', this.vm.rollUpInfo?.maxVisitors ?? 0);
        this.TouristRestriction('瞬时最大承载量', this.vm.rollUpInfo?.maxInstantVisitors ?? 0);
      }
      .padding(20)
      .backgroundColor(Color.White)
      .width(Constant.FULL_PERCENT)
      .borderRadius(8)
      .justifyContent(FlexAlign.SpaceBetween);

      Column({ space: 20 }) {
        LazyForEach(this.vm.parkingSlotList, (item: ParkingSlotInfo) => {
          Row() {
            Row({ space: 8 }) {
              Image($r('app.media.parking')).size({ height: 16, width: 16 });
              Text(item.name).fontSize(10).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(`${(item.distance / 1000).toFixed(2)}km`).fontWeight(500).fontSize(12);
            }.justifyContent(FlexAlign.Start);

            Row({ space: 2 }) {
              Image($r('app.media.navigation')).size({ height: 16, width: 16 });
              Text('导航').fontSize(10).opacity(0.4).onClick(() => {
                routerToPetalMap(item.latitude, item.longitude, item.name,
                  getContext(this) as common.UIAbilityContext);
              });
            }.alignItems(VerticalAlign.Center);
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
        });
      }.backgroundColor(Color.White).width(Constant.FULL_PERCENT).borderRadius(8).padding(12);
    }.backgroundColor('#F1F3F5').padding(16);
  }

  @Builder
  FunctionModuleBuilder() {
    Row() {
      ForEach(getFunctionModuleInfo(this.mainPathStack), (item: FunctionModuleData) => {
        Column() {
          Image(item.icon).size({ width: 48, height: 48 });
          Text(item.title).fontSize(12).margin({ top: 4 });
        }.onClick(item.click);
      }, (item: FunctionModuleData) => JSON.stringify(item));
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constant.FULL_PERCENT)
    .backgroundColor(Color.White)
    .padding(16)
    .borderRadius(8);
  }

  @Builder
  HotInfoBuilder(itemName: string, component: WrappedBuilder<[]>, routeEvent: (event: ClickEvent) => void) {
    Column() {
      Row() {
        Text(itemName).fontWeight(700).fontSize(18);
        Row() {
          Text('更多');
          Image($r('app.media.chevron_right')).size({ width: 12, height: 12 });
        }.onClick(routeEvent);
      }.realTimeRow().margin({ bottom: 8 });

      component.builder();
    }.margin({ top: 24 });
  }

  @Builder
  ScenicInfoBuilder() {
    Row() {
      // 展示首条
      Text(`${this.vm.bulletinList.getData(0)?.title ?? '查看公告'}`)
        .fontColor('rgb(43, 112, 80)')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%');
      Image($r('app.media.chevron_right')).size({ width: 12, height: 12 });
    }
    .onClick(() => {
      this.mainPathStack.pushPathByName('Bulletins', null, false);
    })
    .padding(12)
    .backgroundColor('#E3EDE6')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  aboutToAppear(): void {
    this.vm.getBulletinList();
  }

  build() {
    NavDestination() {
      if (this.vm.isLoading) {
        FullLoadingComponent();
      } else {
        List() {
          ListItem() {
            SwiperComponent(this.vm.scenicImages);
          };

          ListItem() {
            Column() {
              this.ScenicInfoBuilder();
              this.FunctionModuleBuilder();
              this.RealTimeInfoBuilder();
              ForEach(getHotAreaInfo(this.mainPathStack), (item: HotAreaInfo) => {
                this.HotInfoBuilder(item.itemTitle, item.component, item.routeEvent);
              }, (item: HotAreaInfo) => JSON.stringify(item.itemTitle));
            }.padding(12).height(Constant.FULL_PERCENT);
          };
        }
        .backgroundColor('#F1F3F5')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }.hideTitleBar(true);
  }
}