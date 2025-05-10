import { BaseCalendar } from '../components/BaseCalendar';
import { CalendarVM, ServiceTitle, TextStyleModifier, ThemeModel } from 'common';
import { FestivalSolar } from '../components/FestivalSolar';
import { PersistenceV2 } from '@kit.ArkUI';
import { CalendarTools } from '../components/CalendarTools';

@ComponentV2
export struct PerpetualCalendar {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  vm: CalendarVM = CalendarVM.instance;
  @Param @Require jumpToAlmanac: () => void = () => {
  };

  build() {
    Column() {
      ServiceTitle({
        title: '万年历',
        titleColor: this.theme.themeState.titleColor,
      })
      List() {
        ListItem() {
          BaseCalendar();
        }
        .opacity(0.8)

        ListItem() {
          CalendarTools();
        }

        ListItem() {
          if (this.vm.lunarInfo) {
            Column() {
              Text(this.vm.getLunarDateLabel())
                .attributeModifier(new TextStyleModifier(`${this.theme.themeState.buttonColor}/Subtitle_L/Bold`))
                .width('100%');
              Row() {
                Image($r('app.media.ic_yi_str'))
                  .width(22)
                  .margin({ right: 12 });

                Text() {
                  ForEach(this.vm.todayYiJi?.yi, (value: string) => {
                    Span(value + '  ')
                  })
                }
                .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
                .maxLines(1)
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });

              }
              .margin({ top: 16, bottom: 16 });

              Row() {
                Image($r('app.media.ic_ji_str'))
                  .width(22)
                  .margin({ right: 12 });

                Text() {
                  ForEach(this.vm.todayYiJi?.ji, (value: string) => {
                    Span(value + '  ')
                  })
                }
                .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
                .maxLines(1)
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });

              }.margin({ bottom: 9 })
            }
            .backgroundColor($r('sys.color.background_primary'))
            .margin({ top: 12 })
            .padding(12)
            .borderRadius(16)
            .onClick(() => {
              this.jumpToAlmanac();
            });
          }
        }
        .padding({ left: 16, right: 16 })

        ListItem() {
          FestivalSolar()
        }
        .padding({ left: 16, right: 16 })
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .backgroundImage($r('app.media.calender_bg'))
      .backgroundImageSize(ImageSize.Cover)
    }
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}