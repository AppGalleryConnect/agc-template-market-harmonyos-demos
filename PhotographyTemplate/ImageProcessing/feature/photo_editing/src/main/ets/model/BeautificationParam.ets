import { ICanvasText } from './ImageModel'

@ObservedV2
export class StickerModel {
  @Trace id: string = ''
  @Trace positionX: number = 0
  @Trace positionY: number = 0
  @Trace img: ResourceStr = ''
}


@ObservedV2
export class CanvasTextItem {
  @Trace currentColor: ResourceColor = '#FFFFFF'
  @Trace fontSize: number = 16
  @Trace opacity: number = 100
  @Trace isBold: boolean = false
  @Trace isItalics: boolean = false
  @Trace isUnderline: boolean = false
  @Trace font: ResourceStr = '';
  @Trace text: string = ''
  @Trace dx: number = 25
  @Trace dy: number = 25

  constructor(textItem?: ICanvasText) {
    if (textItem) {
      this.currentColor = textItem.currentColor
      this.fontSize = textItem.fontSize
      this.opacity = textItem.opacity
      this.isBold = textItem.isBold
      this.isItalics = textItem.isItalics
      this.isUnderline = textItem.isUnderline
      this.font = textItem.font
      this.text = textItem.text
      this.dx = textItem.dx
      this.dy = textItem.dy
    }
  }

  clone(): CanvasTextItem {
    return new CanvasTextItem()
  }
}