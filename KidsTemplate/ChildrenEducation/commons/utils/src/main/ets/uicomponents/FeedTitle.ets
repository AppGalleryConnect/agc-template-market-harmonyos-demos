import { CommonConstants } from '../constants/CommonConstants';

@Builder
export function FeedTitle(imgUrl: string, title: string, callback: Callback<void>) {
  Row() {
    Image($r(imgUrl))
      .height(30)
      .alignSelf(ItemAlign.Center)
      .padding({ right: 5 });

    Text(title)
      .fontSize(20)
      .alignSelf(ItemAlign.Center)
      .fontWeight(FontWeight.Bold);

    Blank();

    Row() {
      Text('更多')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .opacity(0.6);
      rightArrow();
    }
    .alignSelf(ItemAlign.Center)
    .onClick(() => {
      callback();
    });
  }
  .padding({
    left: '4%',
    right: '4%',
  })
  .width(CommonConstants.FULL_PERCENT);
}

@Builder
export function rightArrow (){
  SymbolGlyph($r('sys.symbol.chevron_right'))
    .fontColor([$r('sys.color.ohos_id_color_foreground')])
    .opacity(0.3)
    .fontSize('24vp');
}
