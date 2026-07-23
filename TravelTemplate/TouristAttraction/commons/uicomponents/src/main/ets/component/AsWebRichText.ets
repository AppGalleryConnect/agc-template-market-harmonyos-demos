import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';

// 封装AsWebRichText
@ComponentV2
export struct AsWebRichText {
  @Param url: string = '';
  @Param richTextStr: string = '';
  @Local controllerWeb: AtomicServiceWebController = new AtomicServiceWebController();

  getUrl(): string {
    if (this.richTextStr) {
      return `${this.url}?richText=${this.richTextStr}`;
    }
    return this.url;
  }

  build() {
    AtomicServiceWeb({ controller: this.controllerWeb, src: this.getUrl() })
      .width('100%')
  }
}
