import { CommonConstants } from './Constants'

export class CustomScrollModifier implements AttributeModifier<ScrollAttribute> {
  applyNormalAttribute(instance: ScrollAttribute): void {
    instance
      .width(CommonConstants.FULL_PERCENT)
      .align(Alignment.Start)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
  }
}

export class CustomTouchModifier implements AttributeModifier<CommonAttribute> {
  applyNormalAttribute(instance: CommonAttribute): void {
    instance.backgroundColor(Color.Transparent)
  }

  applyPressedAttribute(instance: CommonAttribute): void {
    instance.backgroundColor($r('sys.color.interactive_pressed'))
  }
}