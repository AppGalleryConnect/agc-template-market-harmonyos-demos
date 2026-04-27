import { TextModifier } from '@kit.ArkUI';

@ObservedV2
export class ListItemModel {
  @Trace id?: string = ''
  @Trace mainText: ResourceStr = ''
  @Trace mainTextModifier?: TextModifier
  @Trace icon: string | PixelMap | Resource = ''
  @Trace symbol: boolean = false // 图标是否为symbol
  @Trace iconModifier?: ImageModifier | SymbolGlyphModifier
  @Trace disabled?: boolean = false
  @Trace contentImage: string | PixelMap | Resource = ''
  @Trace contentText: ResourceStr = ''
  // 原事件柄
  handler?: Function = undefined

  public constructor(mainText: ResourceStr, icon?: string | PixelMap | Resource, id?: string) {
    if (mainText) {
      this.mainText = mainText
    }
    if (icon) {
      this.icon = icon
    }
    if (id) {
      this.id = id
    }
  }

  public setMainText(mainText: ResourceStr): ListItemModel {
    this.mainText = mainText;
    return this;
  }

  public setMainTextModifier(m: TextModifier): ListItemModel {
    this.mainTextModifier = m
    return this;
  }

  public setId(id: string): ListItemModel {
    this.id = id;
    return this;
  }

  public setIcon(icon: string | PixelMap | Resource): ListItemModel {
    this.icon = icon;
    return this;
  }

  public setSymbol(symbol: boolean): ListItemModel {
    this.symbol = symbol;
    return this;
  }

  public setIconModifier(m: ImageModifier | SymbolGlyphModifier): ListItemModel {
    this.iconModifier = m
    return this;
  }

  public setDisabled(disabled: boolean): ListItemModel {
    this.disabled = disabled;
    return this;
  }

  public setHandle(handler?: Function): ListItemModel {
    this.handler = handler
    return this;
  }

  public setContentImage(contentImage: string | PixelMap | Resource): ListItemModel {
    this.contentImage = contentImage
    return this;
  }

  public setContentText(contentText: ResourceStr): ListItemModel {
    this.contentText = contentText
    return this;
  }
}