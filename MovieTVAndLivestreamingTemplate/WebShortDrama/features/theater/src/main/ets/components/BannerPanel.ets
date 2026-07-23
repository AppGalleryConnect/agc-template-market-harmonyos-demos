import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { DramaInfo } from '@agctemplate/server'
import { appRouter, WindowManager } from '@agctemplate/utils'
import { FontModel, fp2pxUtil } from '@agctemplate/widgets'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { AppStorageV2 } from '@kit.ArkUI'
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition'

@ComponentV2
export struct BannerPanel {
  @Param @Require bannerList: Array<DramaCoverVM>
  @Param @Require inPage: string
  @Local curIndex: number = 0
  @Local scrolling: boolean = false
  @Param breakPoint: string = 'sm'
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Row() {
        if (this.breakPoint === 'sm') {
          Swiper() {
            this.dramaItem()
          }
          .width('100%')
          .height('100%')
          .borderRadius(8)
          .loop(true)
          .autoPlay(true)
          .indicator(false)
          .onAnimationStart((_, targetIndex: number) => {
            if (!this.scrolling) {
              this.curIndex = targetIndex;
            }
          })
          .onGestureSwipe(() => {
            this.scrolling = true
          })
          .onChange((index: number) => {
            this.curIndex = index
            this.scrolling = false
          })
        } else {
          Scroll() {
            Row({ space: 16 }) {
              this.dramaItem()
            }
          }
          .layoutWeight(1)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
      }
      .width('100%')
      .height(138)

      if (this.breakPoint === 'sm') {
        Row() {
          ForEach(this.bannerList, (_: string, index: number) => {
            Column()
              .width(this.curIndex === index ? 15 : 5)
              .height(5)
              .borderRadius(5)
              .margin(5)
              .backgroundColor(this.curIndex === index ?
                $r('sys.color.alert') : $r('sys.color.comp_background_secondary'))
          }, (item: string) => item)
        }
        .height(32)
      }
    }
  }

  @Builder
  dramaItem() {
    ForEach(this.bannerList, (banner: DramaCoverVM) => {
      Row() {
        Stack() {
          Image(banner.imagePath)
            .height(138)
            .width(104)
            .borderRadius(8)
          if (this.inPage === 'new') {
            Image(getMedia('app.media.new'))
              .width(28)
              .height(16)
              .position({ left: 76 })
          } else if (this.inPage === 'vip') {
            Image(getMedia('app.media.vip'))
              .width(28)
              .height(16)
              .position({ left: 76 })
          }
        }

        Column({ space: 8 }) {
          Text(banner.title)
            .fontSize(this.fontModel.getFg(14))
            .width('100%')
            .height(19)
            .fontWeight(500)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 8 }) {
            ForEach(banner.tags, (tag: string) => {
              Text(tag)
                .width(28)
                .height(16)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .fontSize(fp2pxUtil(10))
                .fontWeight(400)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Center)
                .borderRadius(4)
            }, (tag: string) => tag)
          }

          Text(banner.description)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(this.fontModel.getFg(14))
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width(200)
        .margin({
          left: 12,
          right: 12
        })
        .alignItems(HorizontalAlign.Start)
      }
      .id('BannerPanel' + banner.dramaId)
      .alignItems(VerticalAlign.Center)
      .width(340)
      .height(138)
      .borderRadius(8)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .onClick(async () => {
        const longTakeTransitionParam: LongTakeTransitionParam | undefined =
          await LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(),
            'BannerPanel' + banner.dramaId, 8);
        if (longTakeTransitionParam) {
          banner.longTakeTransitionParam = longTakeTransitionParam;
        }
        onDramaClick(banner,
          () => {
            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
          })
      })
    }, (banner: DramaCoverVM, index: number) => banner.dramaId + index)
  }
}


export function onDramaClick(option: DramaCoverVM, callback?: (popInfo: PopInfo) => void) {
  appRouter.push({
    builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
    params: {
      longTakeTransitionParam: option.longTakeTransitionParam,
      pixelMapImg: option.pixelMapImg,
      dramaInfo: new DramaInfo({ id: option.dramaId })
    }, popCallback: callback
  })
}