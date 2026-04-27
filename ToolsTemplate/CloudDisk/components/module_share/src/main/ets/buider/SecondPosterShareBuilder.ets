import { ShareKinds, ShareOptions } from '../model/Model'
import { secondShareList } from '../constants/Constants'
import { PosterShare } from '../utils/SystemShare'
import { WxShareViewModel } from '../viewModel/WxShareViewModel'
import { QqShareViewModel } from '../viewModel/QqShareViewModel'

@ComponentV2
export struct SecondPosterShare {
  @Local shareList: ShareKinds[] = secondShareList
  @Param posterShare: PosterShare = new PosterShare()
  @Param qrCodeInfo: ShareOptions = new ShareOptions()
  @Require @Param coverUrl:string
  @Require @Param pixmap:PixelMap
  @Event onCancel:() => void = () => {}
  @Event popClose:(isClose:boolean) => void = () => {}
  @Local qqShareViewModel: QqShareViewModel = QqShareViewModel.instance
  @Local wxShareViewModel: WxShareViewModel = WxShareViewModel.instance

  aboutToAppear(): void {
    this.posterShare.setContext(getContext(this))
  }

  build() {
    Column() {
      Row({ space: 29 }) {
        ForEach(this.shareList, (value: ShareKinds) => {
          Column({ space: 8 }) {
            Image($r(value.icon)).width(48).height(48)
            Text(value.name)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
          }
          .onClick(() => {
            switch (value.id) {
              case 'save':
                this.posterShare.saveImage(this.pixmap,(isClose:boolean) => {
                  this.popClose(isClose)
                })
                break;
              case 'wechat':
                this.wxShareViewModel.newsPosterShare('WXSceneSession',this.pixmap)
                break;
              case 'wechat_feed':
                this.wxShareViewModel.newsPosterShare('WXSceneTimeline',this.pixmap)
                break;
              case 'qq':
                this.qqShareViewModel.share(this.qrCodeInfo)
                break;
            }
            this.onCancel()
          })
        }, (item: ShareKinds, idx: number) => JSON.stringify(item) + idx)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Button('取消')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .width('100%')
        .fontColor($r('sys.color.font_primary'))
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          this.onCancel()
        })
    }
    .padding({
      left: 26,
      right: 26,
      top: 32,
      bottom: 32,
    })
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}