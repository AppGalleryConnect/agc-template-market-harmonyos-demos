import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';

@Component
export struct AgreementPage {
  @State
  private label: string = '';
  @State
  private url: string = '';
  @State
  private controller: AtomicServiceWebController = new AtomicServiceWebController();

  public build(): void {
    NavDestination() {
      Column() {
        AtomicServiceWeb({
          src: this.url,
          controller: this.controller,
        })
          .width('100%')
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor(Color.White)
    }
    .title(this.label)
    .onReady((ctx: NavDestinationContext) => {
      if (ctx.pathInfo.param) {
        const param: Record<string, string> = ctx.pathInfo.param as Record<string, string>;
        this.label = param.label ?? '';
        this.url = param.url ?? '';
      }
    })
  }
}

@Builder
export function buildAgreementPage(): void {
  AgreementPage()
}
