import { MainEntryVM, newsInformationInterface } from 'commonlib'
import { LengthMetrics } from '@kit.ArkUI'
import { BaseTitle } from 'componentlib'

@Builder
export function newsDetailPageBuilder(name: string, param: Object) {
  newsDetailPage()
}

@ComponentV2
export struct newsDetailPage {
  lastPageIndex: number = MainEntryVM.instance.navStack.size() - 1
  params: newsInformationInterface =
    MainEntryVM.instance.navStack.getParamByIndex(this.lastPageIndex) as newsInformationInterface
  vm: MainEntryVM = MainEntryVM.instance;

  @Builder
  newsDetailBuilder() {
    Text('新闻公告')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.newsDetailBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Scroll() {
        Column() {
          Text(this.params.title)
            .fontSize(14)
            .fontColor($r('app.color.stationsInformation_default'))
          Text(this.params.time)
            .fontSize(12)
            .fontColor($r('app.color.font_color_gray'))
            .margin({ top: 4 })
          Image(this.params.image)
            .margin({ top: 13 })
            .borderRadius(8)
            .width('100%')
          Text(this.params.content)
            .fontSize(14)
            .fontColor($r('app.color.font_color_gray'))
            .lineSpacing(LengthMetrics.percent(1))
            .margin({ top: 12 })
        }
        .padding({
          top: 12,
          left: 12,
          right: 12,
          bottom: 13
        })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .borderRadius(16)
        .margin({ top: 8 })
        .backgroundColor($r('app.color.background_color_white'))
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .padding({left: 16, right: 16})
    }
    .backgroundColor($r('app.color.stationsInformation_background_color'))
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}