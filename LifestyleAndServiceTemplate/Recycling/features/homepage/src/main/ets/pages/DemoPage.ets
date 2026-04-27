import { phoneRouterControl } from 'oh_router'

@Builder
export function DemoPageBuilder() {
  DemoPage()
}

@ComponentV2
export struct DemoPage {
  build() {
    NavDestination() {
      Column() {
        Text('Test Page')
          .onClick(() => {
            phoneRouterControl.popPage()
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Color.Yellow)
    }
  }
}