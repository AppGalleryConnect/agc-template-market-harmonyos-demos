import { AppStorageKeys, BreakPoint, BreakPointValue } from '@agctemplate/widgets'
import { BannerPanel } from '../components/BannerPanel'
import { RecommendPanel } from '../components/RecommendPanel'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct VIP {
  @Param @Require bannerList: Array<DramaCoverVM>
  @Param @Require recommendList: Array<DramaCoverVM>
  @Param @Require gutter: number
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;

  build() {
    Column(){
      Text('VIP专属推荐')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
      BannerPanel({ bannerList: this.bannerList, inPage: 'vip', breakPoint: this.currentBreakpoint.value })

      Text('优选短剧')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
      RecommendPanel({ recommendList: this.recommendList, gutter: this.gutter, inPage: 'vip' })
    }

  }
}