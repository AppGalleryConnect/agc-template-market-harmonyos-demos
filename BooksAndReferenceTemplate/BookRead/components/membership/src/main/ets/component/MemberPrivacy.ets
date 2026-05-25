@Builder
export function MemberPrivacy(content: string) {
  Scroll() {
    Text(content).fontSize(14).fontColor($r('sys.color.font_primary')).lineHeight(20);
  }.height('100%').align(Alignment.Top).padding(16).scrollBar(BarState.Off);
}