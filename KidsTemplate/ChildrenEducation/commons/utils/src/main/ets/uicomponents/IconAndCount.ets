@Builder
export function IconAndCount(anchorName: string, isVip: boolean, updateCount: number, totalCount: number,
  iconPercent: string, countCompletePercent: string, countUnCompletePercent: string) {
  IconLoc(anchorName, isVip, iconPercent);
  CountLoc(anchorName, updateCount, totalCount, countCompletePercent, countUnCompletePercent);
}

@Builder
export function Icon(anchorName: string, isVip: boolean, iconPercent: string) {
  IconLoc(anchorName, isVip, iconPercent);
}

@Builder
export function IconLoc(anchorName: string, isVip: boolean, percent: string) {
  Image(isVip ? $r('app.media.icon_vip_top_start') : $r('app.media.icon_free_top_start'))
    .iconStyle(anchorName, percent);
}

@Builder
export function CountLoc(anchorName: string, updateCount: number, totalCount: number, countCompletePercent: string,
  countUnCompletePercent: string) {
  if (updateCount === totalCount) {
    Stack() {
      if (updateCount === totalCount) {
        Text('共' + totalCount + '集')
          .textStyle();
      }
      Button()
        .backgroundColor($r('sys.color.black'))
        .width(countCompletePercent)
        .height(20)
        .opacity(0.4)
        .zIndex(1);
    }
    .alignRules({
      bottom: { anchor: anchorName, align: VerticalAlign.Bottom },
      right: { anchor: anchorName, align: HorizontalAlign.End },
    })
    .margin({
      right: $r('app.float.5px'),
      bottom: $r('app.float.4px'),
    });

  } else {
    Stack() {
      Text('更新至' + updateCount + '/' + totalCount)
        .textStyle();
      Button()
        .backgroundColor($r('sys.color.black'))
        .width(countUnCompletePercent)
        .height(20)
        .opacity(0.4)
        .zIndex(1);
    }
    .alignRules({
      bottom: { anchor: anchorName, align: VerticalAlign.Bottom },
      right: { anchor: anchorName, align: HorizontalAlign.End },
    })
    .margin({
      right: $r('app.float.5px'),
      bottom: $r('app.float.4px'),
    });
  }
}

@Extend(Image)
function iconStyle(anchorName: string, percent: string) {
  .width(percent)
  .alignRules({
    top: { anchor: anchorName, align: VerticalAlign.Top },
    left: { anchor: anchorName, align: HorizontalAlign.Start },
  });
}

@Extend(Text)
function textStyle() {
  .fontColor($r('sys.color.white'))
  .fontSize(12)
  .zIndex(2);
}