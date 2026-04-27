import { DownloadWithoutWlanEnum, VideoNetworkModel, VideoNetworkSetting } from '../models/VideoNetworkModel';

@ComponentV2
export struct BaseImage {
  @Param url: ResourceStr = '';
  @Param videoNetwork: VideoNetworkModel | undefined = undefined
  @Param videoNetworkSetting: VideoNetworkSetting | undefined = undefined
  @Local imageUrl: ResourceStr = ''

  aboutToAppear() {
    let isDisabled = this.videoNetworkSetting?.downloadWithoutWlan === DownloadWithoutWlanEnum.downloadDisable;
    let isCellular = this.videoNetwork?.isNetworkAvailable && this.videoNetwork?.isCellular;
    // 移动网络下，设置不下载图
    this.imageUrl = isCellular && isDisabled ? $r('app.media.ic_default_bg') : this.url;
  }

  build() {
    Image(this.imageUrl)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .draggable(false)
  }
}