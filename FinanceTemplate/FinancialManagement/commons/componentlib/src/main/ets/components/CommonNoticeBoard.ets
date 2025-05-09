import { FormatUtil, RouterMap } from 'commonlib'
import { INoticeItem } from 'network/src/main/ets/types/responseTypes/NoticeResp'

@ComponentV2
export struct CommonNoticeBoard {
  @Param noticeList: INoticeItem[] = []
  private swiperController: SwiperController = new SwiperController()

  build() {
    Row() {
      Swiper(this.swiperController) {
        ForEach(this.noticeList, (notice: INoticeItem) => {
          Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Image($r('app.media.ic_sound'))
              .width(24)
              .height(24)
            Text(notice.name)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .flexGrow(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ left: 8, right: 8 })
            Image($r('app.media.notice_right'))
              .width(12)
              .height(12)
          }
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.INFORMATION_INFO, notice)
          })
        }, (item: INoticeItem[]) => JSON.stringify(item))
      }
      .vertical(true)
      .indicator(false)
      .cachedCount(2)
      .index(1)
      .autoPlay(true)
      .interval(4000)
      .loop(true)
      .duration(1000)
      .curve(Curve.Linear)
    }
    .width('100%')
    .height(48)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}