import { display } from '@kit.ArkUI'

export function getDisplayWidthOfVp() {
  return px2vp(display.getDefaultDisplaySync().width)
}