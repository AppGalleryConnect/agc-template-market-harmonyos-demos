const storageLocal0 = new LocalStorage();

interface LocationInfo0 {
  name: string;
  code: string;
}

interface RealTimeWeather0 {
  temp: number;
  maxTemp: number;
  minTemp: number;
  icon: string;
  desc: string;
}

@Entry(storageLocal0)
@Component
struct WidgetCard {
  @LocalStorageProp('location') location: LocationInfo0 | null = null;
  @LocalStorageProp('realTimeWeather') realTimeWeather: RealTimeWeather0 | null = null;
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
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
            if (this.realTimeWeather) {
              Image($r(`app.media.${this.realTimeWeather.icon}`)).width(18)
            }
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


      Column({ space: 2 }) {
        if (this.realTimeWeather) {
          Text(this.realTimeWeather.desc)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_on_primary'))

          Text(Math.round(this.realTimeWeather.maxTemp) + '°/' + Math.round(this.realTimeWeather.minTemp) + '°')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .alignRules({
        'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
        'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
      })
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