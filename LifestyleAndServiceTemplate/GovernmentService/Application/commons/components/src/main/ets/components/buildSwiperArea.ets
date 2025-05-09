import { getDataFromJSON } from 'h5'
import { NavigationParams, SwiperInfo } from 'common'

@Component
export struct buildSwiperArea {
  private swiperController: SwiperController = new SwiperController()
  @Consume('pageInfos') pageInfos: NavPathStack
  swiperHeight: number | string = 0
  isNeedPadding: boolean = false
  swiperData: SwiperInfo[] = []
  goH5Page = (title: string) => {
    this.pageInfos.pushPathByName('H5', new NavigationParams(title,'news.html'))
  }

  aboutToAppear(): void {
    this.swiperData = getDataFromJSON<SwiperInfo>('HomePage-PokerBanner.json', this);
  }

  @Builder
  buildSwiperArea() {
    Swiper(this.swiperController) {
      ForEach(this.swiperData, (data: SwiperInfo) => {
        Stack({ alignContent: Alignment.TopStart }) {
          Image($r(data.thumbnailsJson?.[0]))
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .width('100%')
            .height(this.swiperHeight)
            .onClick(() => {
              this.goH5Page(data.title)
            })
          if (data.footer) {
            Text(data.footer)
              .fontColor($r('sys.color.font_on_primary'))
              .margin({ top: 10 })
              .textAlign(TextAlign.Center)
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#D1A774')
              .padding({
                left: 12,
                right: 12,
                top: 5,
                bottom: 5
              })
              .borderRadius({
                topRight: 10,
                bottomRight: 10
              })
          }
        }
        .margin({ top: 10 })
      },(data: SwiperInfo) => JSON.stringify(data))
    }
    .loop(true)
    .autoPlay(true)
    .interval(2500)
    .indicator(
      Indicator.dot()
        .selectedColor($r('sys.color.comp_background_emphasize'))
    )
  }

  build() {
    Column() {
      this.buildSwiperArea()
    }
  }
}
