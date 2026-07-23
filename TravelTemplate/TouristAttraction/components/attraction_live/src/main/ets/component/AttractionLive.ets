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
  .fontSize($r('sys.float.Caption_L')).fontColor($r('sys.color.font_secondary'));
}

@ComponentV2
export struct AttractionLive {
  vm: AttractionLiveVM = AttractionLiveVM.instance;
  @Param @Require attractionLiveInfo: AttractionLiveInfo;
  @Local isShow: boolean = false;

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

  aboutToAppear(): void {
    this.vm.longitude = this.attractionLiveInfo.longitude;
    this.vm.latitude = this.attractionLiveInfo.latitude;
    this.vm.getParkingSlot();
  }

  @Builder
  TouristRestriction(key: string, value: number) {
    Column({ space: 4 }) {
      Text(`${value}`)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
      Text(key).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_secondary'));
    }.alignItems(HorizontalAlign.Center).layoutWeight(1);
  }

  @Builder
  RealTimeInfoDetailBuilder() {
    Column({ space: 12 }) {
      Row() {
        this.TouristRestriction('当日累计游客数', this.attractionLiveInfo.currentDayVisitors ?? 0);
        this.TouristRestriction('当日最大承载量', this.attractionLiveInfo.maxVisitors ?? 0);
        this.TouristRestriction('瞬时最大承载量', this.attractionLiveInfo.maxInstantVisitors ?? 0);
      }
      .padding({
        top: 16,
        bottom: 16,
        left: 12,
        right: 12,
      })
      .backgroundColor($r('sys.color.comp_background_primary'))
      .width(Constant.FULL_PERCENT)
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceBetween);

      Column() {
        ForEach(this.vm.parkingSlotList, (item: ParkingSlotInfo) => {
          Row({ space: 8 }) {
            Row({ space: 8 }) {
              Image($r('app.media.parking_fill')).size({ height: 16, width: 16 });
              Text(`${item.name}：`)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1);
              Text(this.vm.getDistance(item.distance))
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_primary'));
            }.layoutWeight(1);

            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.location_north_up_right'))
                .fontSize(16)
                .width(16)
                .height(16)
                .fontColor([$r('sys.color.icon_primary')]);
              Text('导航').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary')).onClick(() => {
                SystemUtil.routerToPetalMap(item.latitude, item.longitude, item.name,
                  this.getUIContext().getHostContext() as common.UIAbilityContext);
              });
            }.alignItems(VerticalAlign.Center);
          }.width(Constant.FULL_PERCENT).height(40).justifyContent(FlexAlign.SpaceBetween);
        }, (item: ParkingSlotInfo) => item.name);
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .width(Constant.FULL_PERCENT)
      .borderRadius(16)
      .padding({
        top: 8,
        bottom: 8,
        left: 12,
        right: 12,
      });
    }.backgroundColor($r('sys.color.background_secondary')).padding({ left: 16, right: 16 });
  }

  @Builder
  WeatherInfoBuilder() {
    Row({ space: 8 }) {
      Text(`${this.currentMonth}.${CommonUtil.padWithZeros(this.attractionLiveInfo.currentDate?.getDate())}`)
        .weatherInfoText();
      Text('|').weatherInfoText();
      Text(this.attractionLiveInfo.weatherId ?? '未知').weatherInfoText();
      Text(`${this.attractionLiveInfo.temperature}°C`).weatherInfoText();
      Text(this.attractionLiveInfo.atmosphereId ?? '未知').weatherInfoText().fontColor('#2B7050');
      Text(`${this.apparentTemp}`).weatherInfoText();
    };
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.attractionLiveInfo.name)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold);
        this.WeatherInfoBuilder();
      }.realTimeRow();

      Column() {
        Row() {
          Row({ space: 12 }) {
            Column() {
              Image($r('app.media.comfort')).size({ width: 16, height: 16 });
              Text('舒适')
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_on_primary'))
                .margin({ top: 2 });
            }.backgroundColor('#64BB5C').borderRadius(8).margin({ right: 12 }).padding(4);

            Row({ space: 24 }) {
              ForEach(this.attractionLiveInfo.realTimeInfos, (info: RealTimeInfo) => {
                Column({ space: 4 }) {
                  Row({ space: 4 }) {
                    Image(info.icon).size({ width: 16, height: 16 });
                    Text(`${info.count}${info.item === RealTimeItem.CURRENT_VISITOR ? '人' : '车位'}`)
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'));
                  };

                  Text(info.item).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_tertiary'));
                }.alignItems(HorizontalAlign.Center);
              }, (info: RealTimeInfo) => info.item);
            };

          };

          Row({ space: 4 }) {
            Text('详情').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_tertiary'));
            Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
          };
        }.realTimeRow();

        Divider().margin({ top: 12, bottom: 12 });

        Row() {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.clock_fill'))
              .fontColor([$r('sys.color.icon_tertiary')])
              .fontSize(16);
            Text() {
              Span('开放时间：');
              Span(this.attractionLiveInfo.openTime);
            }.fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_primary'));
          };

          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.ticket_fill'))
              .fontColor([$r('sys.color.icon_tertiary')])
              .fontSize(16);
            Text() {
              Span('售票时间：');
              Span(this.attractionLiveInfo.ticketTime);
            }.fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_primary'));
          };
        }.realTimeRow();
      }
      .backgroundColor($r('sys.color.font_on_primary'))
      .padding({
        top: 16,
        bottom: 16,
        left: 12,
        right: 12,
      })
      .borderRadius(16);
    }.margin({ top: 24 }).onClick(() => {
      this.isShow = true;
    }).bindSheet($$this.isShow, this.RealTimeInfoDetailBuilder(), {
      height: 321,
      detents: [321, 322],
      title: { title: this.attractionLiveInfo.name ?? '' },
      preferType: SheetType.CENTER,
    });
  }
}