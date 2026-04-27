import { common } from '@kit.AbilityKit';
import { CommonUtil, Constant, SystemUtil } from 'module_base';
import { AttractionLiveInfo, ParkingSlotInfo, RealTimeInfo, RealTimeItem } from '../model/Index';
import { AttractionLiveVM } from '../viewmodel/AttractionLiveVM';

@Extend(Row)
function realTimeRow() {
  .justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
}

@Extend(Text)
function weatherInfoText() {
  .fontSize(10).opacity(0.6);
}

@ComponentV2
export struct AttractionLive {
  vm: AttractionLiveVM = AttractionLiveVM.instance;
  @Param @Require attractionLiveInfo: AttractionLiveInfo;
  @Local isShow: boolean = false;

  aboutToAppear(): void {
    this.vm.longitude = this.attractionLiveInfo.longitude;
    this.vm.latitude = this.attractionLiveInfo.latitude;
    this.vm.getParkingSlot();
  }

  @Computed
  get currentMonth() {
    if (this.attractionLiveInfo.currentDate) {
      return CommonUtil.padWithZeros(this.attractionLiveInfo.currentDate.getMonth() + 1);
    }
    return '--';
  }

  @Computed
  get apparentTemp() {
    let apparentTemp = '';
    if (!this.attractionLiveInfo.temperature) {
      apparentTemp = '未知';
    } else {
      if (this.attractionLiveInfo.temperature < 0) {
        apparentTemp = '寒冷';
      } else if (0 < this.attractionLiveInfo.temperature ?? 0 <= 10) {
        apparentTemp = '较冷';
      } else if (10 < this.attractionLiveInfo.temperature ?? 0 <= 25) {
        apparentTemp = '舒适';
      } else if (26 < this.attractionLiveInfo.temperature ?? 0 <= 35) {
        apparentTemp = '较热';
      } else {
        apparentTemp = '炎热';
      }
    }
    return apparentTemp;
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
        this.TouristRestriction('当日累计游客数', this.attractionLiveInfo.currentDayVisitors ?? 0);
        this.TouristRestriction('当日最大承载量', this.attractionLiveInfo.maxVisitors ?? 0);
        this.TouristRestriction('瞬时最大承载量', this.attractionLiveInfo.maxInstantVisitors ?? 0);
      }
      .padding(20)
      .backgroundColor($r('sys.color.font_on_primary'))
      .width(Constant.FULL_PERCENT)
      .borderRadius(8)
      .justifyContent(FlexAlign.SpaceBetween);

      Column({ space: 20 }) {
        ForEach(this.vm.parkingSlotList, (item: ParkingSlotInfo) => {
          Row() {
            Row({ space: 8 }) {
              Image($r('app.media.parking')).size({ height: 16, width: 16 });
              Text(item.name).fontSize(10).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(`${(item.distance / 1000).toFixed(2)}km`).fontWeight(500).fontSize(12);
            }.justifyContent(FlexAlign.Start);

            Row({ space: 2 }) {
              Image($r('app.media.navigation')).size({ height: 16, width: 16 });
              Text('导航').fontSize(10).opacity(0.4).onClick(() => {
                SystemUtil.routerToPetalMap(item.latitude, item.longitude, item.name,
                  this.getUIContext().getHostContext() as common.UIAbilityContext);
              });
            }.alignItems(VerticalAlign.Center);
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
        }, (item: ParkingSlotInfo) => item.name);
      }.backgroundColor($r('sys.color.font_on_primary')).width(Constant.FULL_PERCENT).borderRadius(8).padding(12);
    }.backgroundColor('#F1F3F5').padding(16);
  }

  @Builder
  WeatherInfoBuilder() {
    Row({ space: 8 }) {
      Text(`${this.currentMonth}.${CommonUtil.padWithZeros(this.attractionLiveInfo.currentDate?.getDate())}`)
        .fontSize(10)
        .opacity(0.6)
        .weatherInfoText();
      Text('|').weatherInfoText();
      Text(this.attractionLiveInfo.weatherId ?? '未知').weatherInfoText();
      Text(`${this.attractionLiveInfo.temperature}°C`).weatherInfoText();
      Text(this.attractionLiveInfo.atmosphereId ?? '未知').fontColor('#2B7050').fontSize(10);
      Text(`${this.apparentTemp}`).weatherInfoText();
    };
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.attractionLiveInfo.name).fontWeight(500);
        this.WeatherInfoBuilder();
      }.realTimeRow().margin({ top: 20 });

      Column() {
        Row() {
          Row() {
            Column() {
              Image($r('app.media.comfort')).size({ width: 14, height: 14 });
              Text('舒适').fontSize(10).fontColor($r('sys.color.font_on_primary'));
            }.backgroundColor('#64BB5C').borderRadius(8).margin({ right: 12 }).padding(4);

            ForEach(this.attractionLiveInfo.realTimeInfos, (info: RealTimeInfo) => {
              Column() {
                Row({ space: 4 }) {
                  Image(info.icon).size({ width: 14, height: 14 });
                  Text(`${info.count}${info.item === RealTimeItem.CURRENT_VISITOR ? '人' : '车位'}`)
                    .fontWeight(500)
                    .opacity(0.9);
                };

                Text(info.item).fontSize(10).opacity(0.4);
              }.margin({ right: 24 }).alignItems(HorizontalAlign.Center);
            }, (info: RealTimeInfo) => info.item);
          };

          Row() {
            Text('详情').fontSize(14).opacity(0.6);
            Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
          }.onClick(() => {
            this.isShow = true;
          }).bindSheet($$this.isShow, this.RealTimeInfoDetailBuilder(), {
            height: '40%', title: { title: this.attractionLiveInfo.name ?? '' },
            preferType: SheetType.CENTER
          });
        }.realTimeRow();

        Divider().margin({ top: 14, bottom: 14 });

        Row() {
          Row() {
            Image($r('app.media.open_time')).size({ width: 14, height: 14 }).margin({ right: 4 });
            Text() {
              Span('开放时间：');
              Span(this.attractionLiveInfo.openTime);
            }.fontSize(10);
          };

          Row() {
            Image($r('app.media.ticket_time')).size({ width: 14, height: 14 }).margin({ right: 4 });
            Text() {
              Span('售票时间：');
              Span(this.attractionLiveInfo.ticketTime);
            }.fontSize(10);
          };
        }.realTimeRow();
      }.backgroundColor($r('sys.color.font_on_primary')).padding(16).borderRadius(8);
    };
  }
}