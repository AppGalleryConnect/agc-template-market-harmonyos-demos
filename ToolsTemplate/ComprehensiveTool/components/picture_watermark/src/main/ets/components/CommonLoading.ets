import { StyleConstants } from '../constants/Styles';

@Builder
export function loading(text: string) {
  Column({ space: StyleConstants.SPACE_2 }) {
    Text(text)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)
      .height(56)

    LoadingProgress().size({ width: 36, height: 36 })
  }
  .justifyContent(FlexAlign.Center)
  .width('calc(100% - 32vp)')
  .height(104)
  .backgroundColor($r('sys.color.comp_background_primary'))
  .borderRadius(StyleConstants.RADIUS_32)
}