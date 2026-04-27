@ObservedV2
export class Sticker {
  @Trace public id: string = '';
  @Trace public uri: string = '';
  @Trace public offsetX: number = 0;
  @Trace public offsetY: number = 0;
  @Trace public scale: number = 0;
  @Trace public rotation: number = 0;
  @Trace public isSelected: boolean = true;
  @Trace public width: number = 0;
  @Trace public height: number = 0;
  @Trace public screenWidth: number = 0;
  @Trace public screenHeight: number = 0;
  @Trace public isVisible: boolean = true;

  constructor(id: string = '', uri: string = '', offsetX: number = 0, offsetY: number = 0, scale: number = 0,
    rotation: number = 0,
    isSelected: boolean = true, width: number = 0, height: number = 0, screenWidth: number = 0,
    screenHeight: number = 0) {
    if (id) {
      this.id = id;
    }
    if (uri) {
      this.uri = uri;
    }
    if (offsetX) {
      this.offsetX = offsetX;
    }
    if (offsetY) {
      this.offsetY = offsetY;
    }
    if (scale) {
      this.scale = scale;
    }
    if (rotation) {
      this.rotation = rotation;
    }
    if (isSelected) {
      this.isSelected = isSelected;
    }
    if (width) {
      this.width = width;
    }
    if (height) {
      this.height = height;
    }
    if (screenWidth) {
      this.screenWidth = screenWidth;
    }
    if (screenHeight) {
      this.screenHeight = screenHeight;
    }
  }
}

export class StickersByTag {
  tag: string = '';
  stickers: Sticker[] = [];
}