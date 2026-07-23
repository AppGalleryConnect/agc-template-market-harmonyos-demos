import { AppStorageV2 } from '@kit.ArkUI';
import { CustomWindowModel } from '../models/WindowModel';
import { CommonConstants } from '../constants/CommonConstants'

/**
 * 页面滚动容器modifier
 */
export class CustomScrollModifier implements AttributeModifier<ScrollAttribute> {
  applyNormalAttribute(instance: ScrollAttribute): void {
    instance
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
  }
}

/**
 * 页面NavDestination modifier
 */
export class CustomPageModifier implements AttributeModifier<NavDestinationAttribute> {
  private windowModel: CustomWindowModel = AppStorageV2.connect(CustomWindowModel, () => new CustomWindowModel())!;

  applyNormalAttribute(instance: NavDestinationAttribute): void {
    instance
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .hideTitleBar(true)
      .padding({
        left: this.windowModel.pageLeftPadding,
        right: this.windowModel.pageRightPadding,
        top: this.windowModel.windowTopPadding,
        bottom: this.windowModel.pageBottomPadding,
      })
  }
}

/**
 * 有按压反应的元素modifier
 */
export class CustomTouchItem implements AttributeModifier<CommonAttribute> {
  applyNormalAttribute(instance: CommonAttribute): void {
    instance.backgroundColor(Color.Transparent)
  }

  applyPressedAttribute(instance: CommonAttribute): void {
    instance.backgroundColor($r('sys.color.interactive_pressed'))
  }
}