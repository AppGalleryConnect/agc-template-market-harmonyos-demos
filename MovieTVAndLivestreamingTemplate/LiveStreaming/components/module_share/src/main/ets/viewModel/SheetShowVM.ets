import { image } from '@kit.ImageKit'

@ObservedV2
export class SheetShowVM {
  private static _instance: SheetShowVM
  @Trace firstShareShow: boolean = false
  @Trace sharePopShow: boolean = false
  @Trace posterImage: image.PixelMap | undefined = undefined
  @Trace qrCodeInfo: ESObject = {}
  @Trace coverUrl: string = ''
  @Trace title: string = ''
  @Trace articleFrom: ResourceStr = ''
  @Trace createTime: ResourceStr = ''

  public static get instance() {
    if (!SheetShowVM._instance) {
      SheetShowVM._instance = new SheetShowVM()
    }
    return SheetShowVM._instance
  }

  public setFirstShareShow(value: boolean) {
    this.firstShareShow = value
  }

  public setSharePpShow(value: boolean) {
    this.sharePopShow = value
  }

  public setPosterImage(pixmap: image.PixelMap) {
    this.posterImage = pixmap
  }

  public setPosterInfo(qrCodeInfo: ESObject, coverUrl: string, articleFrom: string, createTime: string, title: string) {
    this.qrCodeInfo = qrCodeInfo
    this.coverUrl = coverUrl
    this.articleFrom = articleFrom
    this.createTime = createTime
    this.title = title
  }
}