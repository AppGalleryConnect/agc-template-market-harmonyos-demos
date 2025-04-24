import { CommonConstants } from '../constants/CommonConstants';


@Builder
export function TagLabelCard(text : string){
  Text(text)
    .fontSize($r('app.float.12fp'))
    .fontColor($r('sys.color.black'))
    .opacity(0.9)
    .textAlign(TextAlign.Center)
    .fontWeight(FontWeight.Regular)
    .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
    .borderRadius(4)
    .backgroundColor($r('app.color.ffeeebeb'))
    .padding({
      left: $r('app.float.8vp'),
      right: $r('app.float.8vp'),
      top: $r('app.float.2vp'),
      bottom: $r('app.float.2vp')
    })
    .margin({right:5})
}