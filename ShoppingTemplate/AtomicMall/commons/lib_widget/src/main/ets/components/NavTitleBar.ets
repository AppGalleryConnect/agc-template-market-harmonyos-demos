import { routerStack } from 'lib_foundation';
import { CommonSymbol } from './CommonSymbol';

@ComponentV2
export struct NavTitleBar {
  @Param
  title: string = ''
  @Param
  titleColor: ResourceColor = $r('app.color.font_color_level1')
  @Param
  arrowColor: ResourceColor = $r('app.color.font_color_level1')
  @Param
  showBackBtn: boolean = false
  @Param
  bgColor: ResourceColor = $r('app.color.background_color_transparent');
  @Event
  onBack: () => void = () => {
    const abilityName = routerStack.getAbilityName(this.getUIContext());
    routerStack.pop(undefined, true, abilityName);
  };
  @Event
  onSearchClick: () => void
  @BuilderParam
  rightPartBuilder: () => void = this.emptyBuilder

  @Computed
  get isSubTitle() {
    const abilityName = routerStack.getAbilityName(this.getUIContext());
    const stack = routerStack.getStack(abilityName);
    return (stack?.size() ?? 0) > 1 || this.showBackBtn;
  }

  build() {
    Column() {
      Row() {
        if (this.isSubTitle || this.showBackBtn) {
          CommonSymbol({
            src: $r('sys.symbol.chevron_left'),
            color: this.arrowColor,
          })
            .margin({ right: $r('app.float.space_l') })
            .onClick(() => {
              this.onBack();
            })
        }
        if (this.title) {
          Text(this.title)
            .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
            .fontColor(this.titleColor)
            .fontWeight(FontWeight.Bold)
        }
      }
      .height($r('app.float.nav_header_height'))
      .width('100%')
      if (this.rightPartBuilder) {
        this.rightPartBuilder()
      }
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .width('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  emptyBuilder() {

  }
}