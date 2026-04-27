export class TextStyleModifier implements AttributeModifier<TextAttribute> {
  isEllipsis: boolean

  constructor(isEllipsis: boolean) {
    this.isEllipsis = isEllipsis
  }

  applyNormalAttribute(instance: TextAttribute): void {
    if (this.isEllipsis) {
      instance.maxLines(1)
      instance.textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }
}