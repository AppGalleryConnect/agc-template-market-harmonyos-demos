const storageLocal1 = new LocalStorage();

interface LocationInfo1 {
  name: string;
  code: string;
}

interface RealTimeWeather1 {
  temp: number;
  maxTemp: number;
  minTemp: number;
  icon: string;
  desc: string;
}

interface HourlyWeather1 {
  time: string;
  temp: number;
  icon: string;
}

@Entry(storageLocal1)
@Component
struct WidgetCard1 {
  @LocalStorageProp('location') location: LocationInfo1 | null = null;
  @LocalStorageProp('realTimeWeather') realTimeWeather: RealTimeWeather1 | null = null;
  @LocalStorageProp('hourlyWeather') hourlyWeather: HourlyWeather1[] | null = null;
  @LocalStorageProp('colors') colors: [ResourceColor, number][] =
    this.isDaytime() ? [['#2E6BE0', 0], ['#92C8FD', 1]] : [['#274668', 0], ['#527EAA', 1]];
  readonly actionType: string = 'router';
  readonly abilityName: string = 'PhoneAbility';

  isDaytime(): boolean {
    const time = new Date();
    const hours = time.getHours();
    return hours >= 6 && hours < 18;
  }

  build() {
    RelativeContainer() {
      Column() {
        if (this.location) {
          Row({ space: 4 }) {
            Image($r('app.media.widget_location')).width(12).height(14)
            Text(this.location.name)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
              .padding({ right: 16 })
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
          }
        }

        if (this.realTimeWeather) {
          Text(Math.round(this.realTimeWeather.temp) + '°')
            .fontSize(40)
            .lineHeight(53)
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .alignRules({
        'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
        'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
      })

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
        .alignItems(HorizontalAlign.End)
        .alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
          'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
        })

      }

      if (this.hourlyWeather?.length) {
        List({ space: 22 }) {
          ForEach(this.hourlyWeather, (weather: HourlyWeather1) => {
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
          }, (weather: HourlyWeather1, index) => JSON.stringify(weather) + '_' + index)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .lanes(1)
        .width('100%')
        .height(54)
        .alignRules({
          'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
        })
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