import { CommonConstants } from '../constants/CommonConstants';

@ComponentV2
export struct ColorPanPicker {
  @Param selectColor: string = '';
  @Local hexColor: string = '';
  @Param alpha: number = 1;
  @Param percent: string = '100';
  @Param isMark: boolean = false;
  @Param isShowAlpha: boolean = false;
  @Local currentColor: string = '';
  @Event onSelectChange: (color: string) => void = () => {
  };
  @Event onAlphaChange: (alpha: number) => void = () => {
  };

  aboutToAppear(): void {
    this.hexColor = this.selectColor.split('#')[1];
  }

  @Computed
  get formatAlpha() {
    return (this.alpha * CommonConstants.ONE_HUNDRED).toFixed(0)
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.color'))
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.float.margin_bottom') });
        List() {
          ForEach(CommonConstants.COLOR_ARR, (item: string, index: number) => {
            ListItem() {
              Column() {
                Column()
                  .width('100%')
                  .height(26)
                  .borderRadius(5)
                  .backgroundColor(Color.Transparent)
                  .position({ left: 0, bottom: 0 })
                  .border({
                    width: 3,
                    color: '#ffff',
                  })
                  .visibility(this.selectColor === item ? Visibility.Visible : Visibility.None);
              }
              .backgroundColor(item)
              .width('100%')
              .height(24)
              .onClick(() => {
                this.onSelectChange(item);
              });
            };
          }, (item: string) => JSON.stringify(item));
        }
        .lanes(13)
        .height(250)
        .width(CommonConstants.ONE_HUNDRED_PERCENT);
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .margin({ top: $r('app.float.title_bottom') });

      Row() {
        Column()
          .width(36)
          .height(36)
          .borderRadius('50%')
          .backgroundColor(this.selectColor);

        Row({ space: 8 }) {
          Text('Hex:')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(14);
          TextInput({ text: $$this.selectColor })
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(14)
            .enabled(false)
            .onSubmit((value) => {
              this.onSelectChange(`#${value}`)
            })
            .width(102)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 });

      Column() {
        Text($r('app.string.opacity'))
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.font_size'))
          .fontColor($r('sys.color.font_secondary'))
          .margin({ bottom: 3 });
        Row() {
          Stack() {
            Slider({
              style: SliderStyle.InSet,
              value: this.alpha * CommonConstants.ONE_HUNDRED,
            })
              .height($r('app.float.brash_width'))
              .width('80%')
              .minResponsiveDistance(CommonConstants.ONE)
              .selectedColor(this.selectColor)
              .onChange((value: number) => {
                this.onAlphaChange(value);
              });
            if (!this.isMark) {
              Row()
                .backgroundColor(Color.Transparent)
                .width($r('app.float.slider_width'))
                .height($r('app.float.brash_width'));
            }
          };

          Text(this.formatAlpha)
            .width($r('app.float.number'))
            .height(24)
            .fontSize($r('app.float.font_size_l'))
            .borderRadius($r('app.float.border_radius_m'))
            .textAlign(TextAlign.Center)
            .backgroundColor($r('app.color.number_color'));
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.ONE_HUNDRED_PERCENT);
      }.visibility(this.isShowAlpha ? Visibility.Visible : Visibility.None)

      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .margin({ bottom: $r('app.float.margin_bottom') });
    };
  }
}