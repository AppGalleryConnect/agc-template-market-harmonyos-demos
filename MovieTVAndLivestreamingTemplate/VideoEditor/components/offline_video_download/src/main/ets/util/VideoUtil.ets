export class MyRowModifier implements AttributeModifier<RowAttribute> {
  isTop: boolean = false

  applyNormalAttribute(instance: RowAttribute): void {
    if (this.isTop) {
      instance.position({ x: 0, y: 0 })
    } else {
      instance.offset({ x: 0, y: 0 })
    }
  }
}