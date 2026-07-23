import { site, mapCommon, map } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { PermissionUtil } from '../utils/PermissionUtil';
import { AddressInfo } from '../constants/CommonModel';
import { CommonColorPicker } from './CommonColorPicker';
import { CommonConstants } from '../constants/Constants';
import { Permissions } from '@kit.AbilityKit';


const TAG = '[WaterMark]'

@ComponentV2
export struct WaterMark {
  // 日期格式
  @Local dateArr: string[] = [];
  // 时间格式
  @Local timeArr: string[] = [];
  // 天气格式
  // todo 替换天气数据
  @Local weatherArr: string[] = ['阴 11℃', '阴天 11摄氏度', '11度 阴'];
  // 地址列表
  @Local addressList: AddressInfo[] = [];
  @Local currentDate: Date = new Date();
  // 当前时间
  @Local currentTime: string = '';
  // 当前日期
  @Local currentDay: string = '';
  @Local currentWeather: string = '';
  // 当前时间格式index
  @Local currentTimeIndex: number = 0;
  // 当前日期格式index
  @Local currentDayIndex: number = 0;
  @Local currentWeatherIndex: number = 0;
  // 当前的经纬度坐标
  @Local currentLocation: mapCommon.LatLng | undefined = undefined;
  @Local currentAddress: string = '';
  // 地址搜索关键词
  @Local keywords: string = '';
  // 水印编辑
  @Local isMarkEditShow: boolean = false;
  // 是否选择天气
  @Local hasWeather: boolean = true;
  @Local isDaySheetShow: boolean = false;
  @Local isTimeSheetShow: boolean = false;
  @Local isAddressSheetShow: boolean = false;
  @Local isWeatherSheetShow: boolean = false;
  // 字体颜色
  @Local fontColor: string = '#FFFFFF'
  timer: number = 0;
  context: Context = this.getUIContext().getHostContext() as Context;

  private startX: number = 0;
  private startY: number = 0;
  @Local currentX: number = 0;
  @Local currentY: number = 0;
  @Local markWidth: number = 0;
  @Local markHeight: number = 0;
  @Local containerWidth: number = 0;
  @Local containerHeight: number = 0;

  aboutToAppear() {
    this.requestLocation()
    this.initData();
    this.timer = setInterval(() => {
      this.initData();
    }, 1000);
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  requestLocation() {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION']
    PermissionUtil.requestPermissions(permissions, this.context).then((grant) => {
      if (grant) {
        this.getNearbyAddress();
      }
    })
  }

  initData() {
    this.currentDate = new Date();
    this.timeArr = this.getHourTimeArr();
    this.dateArr = this.getDateArr();
    this.currentTime = this.timeArr[this.currentTimeIndex];
    this.currentDay = this.dateArr[this.currentDayIndex];
    this.currentWeather = this.weatherArr[this.currentWeatherIndex];
  }

  async toSelectAddress() {
    let allow = await PermissionUtil._checkPermissions('ohos.permission.APPROXIMATELY_LOCATION');
    if (allow) {
      await this.getNearbyAddress();
      this.isAddressSheetShow = true;
    } else {
      this.requestLocation();
    }
  }

  getHourTimeArr(): string[] {
    const now = new Date();
    // 补零工具函数
    const padZero = (num: number) => num.toString().padStart(2, '0');
    const hour = now.getHours();
    const minute = padZero(now.getMinutes());
    // 12小时制
    const hourFormat = hour % 12 || 12; // 0点转为12点
    const format1 = `${padZero(hour)}:${minute}`;
    const format2 = `${hour < 12 ? '上午' : '下午'}${hourFormat}点${minute}分`;
    const format3 = `${hourFormat}:${minute} ${hour < 12 ? 'am' : 'pm'}`;
    return [format1, format2, format3];
  }

  getDateArr(): string[] {
    const weeks1 = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weeks2 = ['礼拜天', '礼拜一', '礼拜二', '礼拜三', '礼拜四', '礼拜五', '礼拜六'];
    const weeks3 = ['星期天', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const date: Date = this.currentDate;
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1);
    const day = String(date.getDate());
    const weekIndex = date.getDay();
    const str1 = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')} ${weeks3[weekIndex]}`;
    const str2 = `${year}年${month}月${day}日 ${weeks1[weekIndex]}`;
    const str3 = `${year}年${month}月${day}日 ${weeks2[weekIndex]}`;
    const str4 = `${weeks3[weekIndex]} ${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
    const str5 = `${weeks1[weekIndex]} ${year}年${month}月${day}日`;
    const str6 = `${weeks2[weekIndex]} ${year}年${month}月${day}日`;
    return [str1, str2, str3, str4, str5, str6];
  }

  async getCurrentLocation() {
    try {
      const location = await geoLocationManager.getCurrentLocation();
      // 转换坐标系
      let wgs84Position: mapCommon.LatLng = {
        latitude: location.latitude,
        longitude: location.longitude,
      };
      this.currentLocation =
        map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
    } catch (e) {
      Logger.error(TAG, `getCurrentLocation failed. error: ${JSON.stringify(e)}`);
    }
  }

  async getAddressByText() {
    if (!this.currentLocation) {
      return;
    }
    let params: site.SearchByTextParams = {
      query: this.keywords,
    };
    try {
      const result = await site.searchByText(this.getUIContext().getHostContext(), params);
      if (result.sites) {
        this.addressList = result.sites.map((item) => {
          const fromLatLng: mapCommon.LatLng = {
            latitude: this.currentLocation?.latitude as number,
            longitude: this.currentLocation?.longitude as number,
          };
          const toLatLng: mapCommon.LatLng = {
            latitude: item.location?.latitude as number,
            longitude: item.location?.longitude as number,
          };
          const distance = Math.floor(map.calculateDistance(fromLatLng, toLatLng));
          const addressInfo: AddressInfo = {
            name: item.name as string,
            formatAddress: item.formatAddress as string,
            distance: distance,
          };
          return addressInfo;
        }).sort((a, b) => a.distance - b.distance);
      }
    } catch (e) {
      Logger.error(JSON.stringify(e));
    }
  }

  // 获取附近的地址
  async getNearbyAddress() {
    await this.getCurrentLocation();
    if (this.currentLocation) {
      let params: site.NearbySearchParams = {
        location: {
          latitude: this.currentLocation.latitude,
          longitude: this.currentLocation.longitude,
        },
        radius: 100,
      };
      try {
        const result = await site.nearbySearch(this.getUIContext().getHostContext(), params);
        if (result.sites) {
          this.addressList = result.sites.map((item) => {
            const addressInfo: AddressInfo = {
              name: item.name as string,
              formatAddress: item.formatAddress as string,
              distance: item.distance as number,
            };
            return addressInfo;
          });
          if (!this.currentAddress) {
            this.currentAddress = this.addressList[0].name;
          }
        } else {
          this.addressList = [];
        }
      } catch (error) {
        Logger.error(TAG, `nearbySearch failed. error: ${JSON.stringify(error)}`);
      }
    }
  }

  build() {
    Row({ space: 16 }) {
      Column({ space: 4 }) {
        Row({ space: 4 }) {
          Text(this.currentTime)
            .fontSize(this.currentTimeIndex === 1 ? $r('sys.float.Title_M') : $r('sys.float.Display_S'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.fontColor)
            .textShadow({ radius: 8, color: Color.Black, offsetX: 0, offsetY: 0 })
          Row().width(2).height(40).backgroundColor($r('sys.color.multi_color_01'))
          Column() {
            Text(this.currentDay.split(' ')[0])
              .waterFontExtend(this.fontColor);
            Row({ space: 4 }) {
              Text(this.currentDay.split(' ')[1])
                .waterFontExtend(this.fontColor);
              if (this.hasWeather) {
                Text(this.currentWeather)
                  .waterFontExtend(this.fontColor);
              }
            };
          }.alignItems(HorizontalAlign.Start);
        };

        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.position'))
            .fontColor([$r('sys.color.icon_on_primary')])
            .width(24)
            .height(24)
            .fontSize(24)
          Text(this.currentAddress ? this.currentAddress : '我在这里')
            .waterFontExtend(this.fontColor);
        }
        .onClick(() => {
          this.toSelectAddress();
        })
        .bindSheet($$this.isAddressSheetShow, this.addressBuilder(), {
          title: {
            title: '选择地点',
          },
          preferType: SheetType.CENTER,
          height: 558,
        });
      }
      .offset({ x: this.currentX, y: this.currentY })
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.markWidth = newValue.width as number;
        this.markHeight = newValue.height as number;
      })
      .onClick(() => {
        this.isMarkEditShow = true;
      })
      .gesture(
        PanGesture({ fingers: 1 })
          .onActionStart(() => {
            this.startX = this.currentX;
            this.startY = this.currentY;
          })
          .onActionUpdate((event: PanGestureEvent) => {
            let newX = this.startX + event.offsetX;
            let newY = this.startY + event.offsetY;
            let maxX = this.containerWidth - this.markWidth;
            let maxY = this.containerHeight - this.markHeight;
            this.currentX = Math.min(Math.max(newX, 0), maxX);
            this.currentY = Math.min(Math.max(newY, -maxY), 0);
          })
          .onActionEnd((event: PanGestureEvent) => {
            let newX = this.startX + event.offsetX;
            let newY = this.startY + event.offsetY;
            let maxX = this.containerWidth - this.markWidth;
            let maxY = this.containerHeight - this.markHeight;
            this.currentX = Math.min(Math.max(newX, 0), maxX);
            this.currentY = Math.min(Math.max(newY, -maxY), 0);
          }),
      );
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
    .onAreaChange((_value: Area, newVal: Area) => {
      this.containerWidth = newVal.width as number;
      this.containerHeight = newVal.height as number;
    })
    .bindSheet($$this.isMarkEditShow, this.editBuilder(), {
      title: {
        title: '编辑水印',
      },
      height: 336,
      preferType: SheetType.CENTER,
    });
  }

  // 设置半模态内容
  @Builder
  editBuilder() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Toggle({ isOn: true, type: ToggleType.Switch }).enabled(false);
        Text(`日期：${this.currentDay}`)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .fontSize($r('sys.float.Subtitle_S'));
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(24)
          .width(12)
          .height(24);
      }.width('100%').height(40).bindSheet($$this.isDaySheetShow, this.dayFormatBuilder(), {
        title: {
          title: '选择日期',
        },
        height: 514,
        preferType: SheetType.CENTER,
      })
      .onClick(() => {
        this.dateArr = this.getDateArr();
        this.isDaySheetShow = true;
      });

      Row({ space: 12 }) {
        Toggle({ isOn: true, type: ToggleType.Switch }).enabled(false);
        Text(`时间：${this.currentTime}`)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .fontSize($r('sys.float.Subtitle_S'));
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(24)
          .width(12)
          .height(24);
      }.width('100%').height(40)
      .bindSheet($$this.isTimeSheetShow, this.timeFormatBuilder(), {
        title: {
          title: '选择时间',
        },
        height: 327,
        preferType: SheetType.CENTER,
      })
      .onClick(() => {
        this.isTimeSheetShow = true;
        this.timeArr = this.getHourTimeArr();
      });

      Row({ space: 12 }) {
        Toggle({ isOn: true, type: ToggleType.Switch }).enabled(false);
        Row() {
          Text('地点：')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_S'));

          Text(this.currentAddress ? this.currentAddress : '我在这里')
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .fontSize($r('sys.float.Subtitle_S'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.MARQUEE });


        }.layoutWeight(1);

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(24)
          .width(12)
          .height(24);
      }.width('100%').height(40)
      .onClick(() => {
        this.toSelectAddress();
      });

      Row({ space: 12 }) {
        Toggle({ isOn: $$this.hasWeather, type: ToggleType.Switch });
        Text(`天气：${this.currentWeather}`)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .fontSize($r('sys.float.Subtitle_S'));
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(24)
          .width(12)
          .height(24);
      }.width('100%').height(40)
      .bindSheet($$this.isWeatherSheetShow, this.weatherFormatBuilder(), {
        title: {
          title: '选择天气',
        },
        preferType: SheetType.CENTER,
        height: 327,
      })
      .onClick(() => {
        this.isWeatherSheetShow = true;
      })

      // 颜色选择
      Column() {
        CommonColorPicker({
          onSelectColor: (color: string) => {
            this.fontColor = color;
          }
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_primary'))
    }
    .padding({
      left: CommonConstants.PADDING_L,
      right: CommonConstants.PADDING_L,
      top: CommonConstants.PADDING_M,
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  // 日期格式弹窗
  @Builder
  dayFormatBuilder() {
    List({ space: 14 }) {
      ForEach(this.dateArr, (item: string, index) => {
        ListItem() {
          Row() {
            Text(item).fontColor($r('sys.color.font_primary')).fontSize($r('sys.float.Subtitle_S'));
            Checkbox().select(this.currentDayIndex === index).onChange((res) => {
              if (res) {
                this.currentDayIndex = index;
                this.currentDay = this.dateArr[this.currentDayIndex];
                this.isDaySheetShow = false;
              }
            });
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        }.height(49);
      }, (item: string, index: number) => item);

    }.padding({ left: 16, right: 16, top: 14 }).height('100%').divider({
      strokeWidth: 1,
    });
  }

  // 时间格式弹窗
  @Builder
  timeFormatBuilder() {
    List({ space: 14 }) {
      ForEach(this.timeArr, (item: string, index) => {
        ListItem() {
          Row() {
            Text(item).fontColor($r('sys.color.font_primary')).fontSize($r('sys.float.Subtitle_S'));
            Checkbox().select(this.currentTimeIndex === index).onChange((res) => {
              if (res) {
                this.currentTimeIndex = index;
                this.currentTime = this.timeArr[this.currentTimeIndex];
                this.isTimeSheetShow = false;
              }
            });
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        }.height(49);
      }, (item: string, index: number) => item);

    }.padding({ left: 16, right: 16, top: 14 }).height('100%').divider({
      strokeWidth: 1,
    });
  }

  // 天气格式弹窗
  @Builder
  weatherFormatBuilder() {
    List({ space: 14 }) {
      ForEach(this.weatherArr, (item: string, index) => {
        ListItem() {
          Row() {
            Text(item).fontColor($r('sys.color.font_primary')).fontSize($r('sys.float.Subtitle_S'));
            Checkbox().select(this.currentWeatherIndex === index).onChange((res) => {
              if (res) {
                this.currentWeatherIndex = index;
                this.currentWeather = this.weatherArr[this.currentWeatherIndex];
                this.isWeatherSheetShow = false;
              }
            });
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        }.height(49);
      }, (item: string, index: number) => item);

    }.padding({ left: 16, right: 16, top: 14 }).height('100%').divider({
      strokeWidth: 1,
    });
  }

  // 地址选择弹窗
  @Builder
  addressBuilder() {
    Column({ space: 14 }) {
      Search({ placeholder: '搜索地址', value: this.keywords }).onChange((res) => {
        this.keywords = res;
        if (this.keywords) {
          this.getAddressByText();
        } else {
          this.getNearbyAddress();
        }
      });

      List() {
        ForEach(this.addressList, (item: AddressInfo) => {
          ListItem() {
            Column({ space: 2 }) {
              Text(item.name)
                .lineHeight(21)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.MARQUEE });

              Row({ space: 4 }) {
                Text(`${item.distance}米`)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Caption_M'));
                Divider().vertical(true);
                Text(item.formatAddress)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Caption_M'));
              }.height(14);
            }.alignItems(HorizontalAlign.Start);
          }.height(62).onClick(() => {
            this.currentAddress = item.name;
            this.isAddressSheetShow = false;
          });

        }, (item: AddressInfo) => item.formatAddress);

      }.layoutWeight(1).divider({
        strokeWidth: 1,
      })
      .scrollBar(BarState.Off);
    }.padding({ left: 16, right: 16, top: 14 });
  }
}

@Extend(Text)
function waterFontExtend(fontColor: string) {
  .fontColor(fontColor)
  .fontSize($r('sys.float.Subtitle_S'))
  .lineHeight(19)
  .textShadow({
    radius: 8,
    color: Color.Black,
    offsetX: 0,
    offsetY: 0
  })
}