import { fileUri } from '@kit.CoreFileKit'
import { frameListData } from 'video_common'

@ComponentV2
export struct MultiImage {
  @Param @Require imageData: frameListData
  @Param @Require imageWidth: number
  @Param @Require imageHeight: number
  @Param @Require flag: boolean
  @Event onClickEvent?: () => void

  build() {
    Column() {
      if (this.imageData?.mPixelMap !== undefined) {
        Image(this.imageData.mPixelMap)
          .borderRadius(this.flag ? '8' : '0')
      } else {
        Image(fileUri.getUriFromPath(this.imageData?.url ?? ''))
          .borderRadius(this.flag ? '8' : '0')
      }
    }.width(this.imageWidth)
    .height(this.imageHeight)
    .borderRadius(this.flag ? '8' : '0')
    .onClick(() => {
      this.onClickEvent?.()
    })
  }
}