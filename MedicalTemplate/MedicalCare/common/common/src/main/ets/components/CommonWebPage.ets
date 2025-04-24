import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
import { LogUtil } from '../utils/LogUtil';
import { RouterUtil } from '../utils/RouterUtil';

export interface CommonWebPageParam {
  src: ResourceStr,
  title: string
}

@Builder
export function CommonWebPageBuilder() {
  CommonWebPage()
}

/**
 * 显示网页
 */
@Component
export struct CommonWebPage {
  @State src: string = ''
  @State controller: AtomicServiceWebController = new AtomicServiceWebController();
  @State webPageParam: CommonWebPageParam | undefined = undefined

  build() {
    NavDestination() {
      AtomicServiceWeb({
        src: this.webPageParam?.src,
        controller: this.controller,
      })
        .width('100%')
        .height('100%')
    }
    .title(this.webPageParam?.title || '')
    .onReady((context) => {
      this.webPageParam = RouterUtil.getLatestParam() as CommonWebPageParam
      LogUtil.info(`CommonWebPage onReady: ${JSON.stringify(this.webPageParam)}`)
    })
  }
}