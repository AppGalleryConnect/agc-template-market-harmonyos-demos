import { Constants } from '../constants/Constants';

@ComponentV2
export struct ControlPanel {
  @Param isPlaying: boolean = true;
  @Param isLargeSize: boolean = false;
  @Event playOrPause: () => void = () => {
  };
  @Event setVolume: (volume: number) => void = () => {
  };

  build() {
    RelativeContainer() {
      // 播放、暂停
      Row() {
        SymbolGlyph(this.isPlaying ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
          .symbolStyle(this.isLargeSize ? 56 : 40)
          .onClick(() => {
            this.playOrPause();
          })
      }
      .borderRadius(Constants.HALF_PERCENT)
      .clip(true)
      .padding(16)
      .backgroundColor($r('app.color.cast_play_pause_bg'))
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
      })

      // 音量+
      SymbolGlyph($r('sys.symbol.speaker_plus'))
        .symbolStyle(this.isLargeSize ? 48 : 32)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
        })
        .onClick(() => {
          this.setVolume(1);
        })

      // 音量-
      SymbolGlyph($r('sys.symbol.speaker_minus'))
        .symbolStyle(this.isLargeSize ? 48 : 32)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
        })
        .onClick(() => {
          this.setVolume(-1);
        })

      // 上一集
      SymbolGlyph($r('sys.symbol.backward_end_fill'))
        .symbolStyle(this.isLargeSize ? 48 : 32, $r('sys.color.font_tertiary'))
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
        })

      // 下一集
      SymbolGlyph($r('sys.symbol.forward_end_fill'))
        .symbolStyle(this.isLargeSize ? 48 : 32, $r('sys.color.font_tertiary'))
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          right: { anchor: '__container__', align: HorizontalAlign.End },
        })
    }
    .width(this.isLargeSize ? 292 : 208)
    .aspectRatio(1)
    .borderRadius(Constants.HALF_PERCENT)
    .clip(true)
    .padding(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }
}

@Extend(SymbolGlyph)
function symbolStyle(fontSize: number, fgColor?: ResourceColor) {
  .fontColor([fgColor ?? $r('sys.color.font_primary')])
  .fontWeight(FontWeight.Normal)
  .fontSize(fontSize)
}