import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
import { WebPageParams, AppRouter } from 'common';
import { BaseTitle } from '../components/BaseTitle';

@Builder
export function webPageBuilder() {
  WebPage()
}

@ComponentV2
export struct WebPage {
  @Local htmlTitle: ResourceStr = '';
  @Local urlParamTitle: ResourceStr = '';
  @Local linkUrl: ResourceStr = '';

  build() {
    NavDestination() {
      BaseTitle({
        title: this.urlParamTitle || this.htmlTitle,
        showBackBtn: true,
        onBack: () => {
          AppRouter.pop()
        }
      })
      ASWeb({
        linkUrl: this.linkUrl
      })
    }
    .hideTitleBar(true)
    .height('100%')
    .onReady(cxt => {
      const params = cxt.pathInfo.param as WebPageParams
      if (params?.linkUrl) {
        this.linkUrl = params.linkUrl
      }
      if (params?.title) {
        this.urlParamTitle = params.title
      }
    })
  }
}

@Component
export struct ASWeb {
  @State webController: AtomicServiceWebController = new AtomicServiceWebController();
  linkUrl: ResourceStr = '';
  build() {
    AtomicServiceWeb({
      src: this.linkUrl,
      controller: this.webController,
      mixedMode: MixedMode.All
    })
      // .onTitleReceive((event) => {
      //   this.htmlTitle = event?.title || '';
      // })
      .layoutWeight(1)
      .width('100%')
  }
}