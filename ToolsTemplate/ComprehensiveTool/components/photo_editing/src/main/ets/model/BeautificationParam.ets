export interface FilterOptions {
  blur: number,
  invert: boolean,
  colorMatrix: Array<number>,
  brightness: number,
  grayscale: boolean
}

@ObservedV2
export class StickerModel {
  @Trace id: string = ''
  @Trace positionX: number = 0
  @Trace positionY: number = 0
  @Trace img: ResourceStr = ''
}

@ObservedV2
export class CanvasTextItem {
  @Trace currentColor: string
  @Trace fontSize: number
  @Trace opacity: number
  @Trace isBold: boolean
  @Trace isItalics: boolean
  @Trace isUnderline: boolean
  @Trace font: string = 'HarmonyOS Sans Condensed';
  @Trace text: string
  @Trace dx: number
  @Trace dy: number

  constructor(currentColor: string, fontSize: number, opacity: number, isBold: boolean, isItalics: boolean,
    isUnderline: boolean, font: string, text: string, dx: number, dy: number) {
    this.currentColor = currentColor
    this.fontSize = fontSize
    this.opacity = opacity
    this.isBold = isBold
    this.isItalics = isItalics
    this.isUnderline = isUnderline
    this.font = font
    this.text = text
    this.dx = dx
    this.dy = dy
  }

  clone(): CanvasTextItem {
    return new CanvasTextItem(this.currentColor, this.fontSize, this.opacity, this.isBold, this.isItalics,
      this.isUnderline, this.font, this.text, this.dx, this.dy)
  }
}
