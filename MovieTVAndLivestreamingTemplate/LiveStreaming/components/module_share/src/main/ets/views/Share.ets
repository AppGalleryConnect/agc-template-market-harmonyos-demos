import { SheetShowVM } from '../viewModel/SheetShowVM'
import { FirstPosterShareBuilder } from '../buider/FirstPosterShareBuilder'
import { PosterSharePop } from '../buider/PosterShareBuilder'
import { Screenshot } from '../ComponentScreenshot/Screenshot';

@ComponentV2
export struct Share {
  @BuilderParam shareRenderBuilder: () => void;
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  @Param qrCodeInfo: ESObject = {}
  @Param coverUrl: string = ''
  @Param title: string = ''
  @Param articleFrom: string = ''
  @Param createTime: string = ''

  aboutToAppear(): void {
    this.shareShowVM.setPosterInfo(this.qrCodeInfo, this.coverUrl, this.articleFrom, this.createTime, this.title)
  }

  build() {
    Column() {
      if (this.shareRenderBuilder) {
        this.shareRenderBuilder()
      } else {
        Image($r('app.media.share_active')).width(21).height(21)
      }
      PosterSharePop({
        sharePopShow: this.shareShowVM.sharePopShow!!,
        onClose: () => {
          this.shareShowVM.setSharePpShow(false)
        },
      })
      Screenshot().position({ left: -2000, bottom: 0 }).visibility(Visibility.Hidden)
    }
    .onClick(() => {
      this.shareShowVM.setFirstShareShow(true)
    })
    .bindSheet($$this.shareShowVM.firstShareShow, FirstPosterShareBuilder(), {
      title: { title: '分享到' },
      height: SheetSize.FIT_CONTENT,
      backgroundColor: $r('sys.color.background_secondary'),
      showClose: true,
      preferType:SheetType.CENTER
    })
  }
}