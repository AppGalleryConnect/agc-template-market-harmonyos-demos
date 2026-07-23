import { display } from '@kit.ArkUI';

/*
 * 左右上角的按钮
 */
@Builder
export function buttonItem(source: Resource, onBack: ()=>void) {
  Button({ type: ButtonType.Circle }) {
    SymbolGlyph(source)
      .fontSize(fp2pxUtil(24))
      .fontColor([$r('sys.color.icon_primary')])
  }
  .accessibilityText('返回')
  .width(40)
  .height(40)
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .onClick(onBack)
}

function fp2pxUtil(fp: number): string {
  const pxStr: string = 'px';
  let pxVal: number = 0;
  let displayClass: display.Display | null = null;
  try {
    displayClass = display.getDefaultDisplaySync();
    pxVal = fp * (displayClass.densityDPI / 160);
  } catch (err) {
  }
  return pxVal + pxStr;
}