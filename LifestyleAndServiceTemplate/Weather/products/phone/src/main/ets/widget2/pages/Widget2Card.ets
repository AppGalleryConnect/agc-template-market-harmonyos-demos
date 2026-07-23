const storageLocal2 = new LocalStorage();

interface LocationInfo2 {
  name: string;
  code: string;
}

interface RealTimeWeather2 {
  temp: number;
  maxTemp: number;
  minTemp: number;
  icon: string;
  desc: string;
}

interface HourlyWeather2 {
  time: string;
  temp: number;
  icon: string;
}

interface DailyWeather2 {
  time: string;
  maxTemp: number;
  minTemp: number;
  dayIcon: string;
}

@Entry(storageLocal2)
@Component
struct WidgetCard2 {
  @LocalStorageProp('location') location: LocationInfo2 | null = null;
  @LocalStorageProp('realTimeWeather') realTimeWeather: RealTimeWeather2 | null = null;
  @LocalStorageProp('hourlyWeather') hourlyWeather: HourlyWeather2[] | null = null;
  @LocalStorageProp('dailyWeather') dailyWeather: DailyWeather2[] | null = null;
  @LocalStorageProp('colors') colors: [ResourceColor, number][] =
    this.isDaytime() ? [['#2E6BE0', 0], ['#92C8FD', 1]] : [['#274668', 0], ['#527EAA', 1]];
  readonly actionType: string = 'router';
  readonly abilityName: string = 'PhoneAbility';

  getWeekDay(s: string): string {
    const parts = s.split('-');
    if (parts.length !== 3) {
      return '';
    }
    const d = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    d.setHours(0, 0, 0, 0);
    const diff = (d.getTime() - today.getTime()) / 86400000 | 0;
    if (diff === -1) {
      return '昨天';
    }
    if (diff === 0) {
      return '今天';
    }
    if (diff === 1) {
      return '明天';
    }
    const w = d.getDay();
    return ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][w];
  }

  isDaytime(): boolean {
    const time = new Date();
    const hours = time.getHours();
    return hours >= 6 && hours < 18;
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Column() {
          if (this.location) {
            Row({ space: 4 }) {
              Image($r('app.media.widget_location')).width(12).height(14)
              Text(this.location.name)
                .maxLines(1)
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
            }
          }

          if (this.realTimeWeather) {
            Text(Math.round(this.realTimeWeather.temp) + '°')
              .alignSelf(ItemAlign.Start)
              .fontSize(40)
              .lineHeight(53)
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
          }
        }
        .layoutWeight(1)

        if (this.realTimeWeather) {
          Column() {
            Image($r(`app.media.${this.realTimeWeather.icon}`)).width(18)
            Text(this.realTimeWeather.desc)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_on_primary'))
              .margin({ top: 4, bottom: 2 })
            Text(Math.round(this.realTimeWeather.maxTemp) + '°/' + Math.round(this.realTimeWeather.minTemp) + '°')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_on_primary'))
          }
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      if (this.hourlyWeather?.length) {
        List({ space: 22 }) {
          ForEach(this.hourlyWeather, (weather: HourlyWeather2) => {
            ListItem() {
              Column({ space: 4 }) {
                Text(weather.time)
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Medium)
                Image($r(`app.media.${weather.icon}`)).width(18)
                Text(Math.round(weather.temp) + '°')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
            .width(30)
          }, (weather: HourlyWeather2, index) => JSON.stringify(weather) + '_' + index)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .lanes(1)
        .width('100%')
        .height(54)
      }

      if (this.dailyWeather?.length) {
        List({ space: 12 }) {
          ForEach(this.dailyWeather, (weather: DailyWeather2) => {
            ListItem() {
              Row() {
                Text(this.getWeekDay(weather.time))
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_on_primary'))
                Image($r(`app.media.${weather.dayIcon}`)).width(18)
                Text(Math.round(weather.maxTemp) + '°/' + Math.round(weather.minTemp) + '°')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_on_primary'))
              }
              .height('100%')
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
            .height(20)
          }, (weather: DailyWeather2, index) => JSON.stringify(weather) + '_' + index)
        }
        .padding({top:10})
        .layoutWeight(1)
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .lanes(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .linearGradient({
      angle: 180,
      colors: this.colors,
    })
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: this.abilityName,
      });
    })
  }
}