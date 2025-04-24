import { PublicNoticeItem } from '../types';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct PublicNotice {
  vm: HomePageVM = HomePageVM.instance;
  @Local noticeIndex: number = 0;

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Image($r('app.media.notice'))
        .width('32lpx')
        .margin({
          right: $r('app.string.margin_s'),
        });
      Row() {
        if (this.vm.publicNoticeList.length) {
          Swiper() {
            ForEach(this.vm.publicNoticeList, (item: PublicNoticeItem) => {
              Text(item.title)
                .fontSize($r('app.string.font_size_24'))
                .fontColor($r('app.color.font_color_level2'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }, (item: PublicNoticeItem, index: number) => {
              return index + '__' + JSON.stringify(item);
            });
          }
          .width('100%')
          .vertical(true)
          .autoPlay(true)
          .loop(true)
          .interval(2000)
          .indicator(false)
          .index(this.noticeIndex)
          .onChange((index) => {
            this.noticeIndex = index;
          })
          .onClick(() => {
            this.vm.jumpToPublicNoticePage(this.noticeIndex);
          });
        }
      }
      .flexGrow(1);
    }
    .margin({
      top: $r('app.string.margin_s'),
      bottom: $r('app.string.margin_m'),
    });
  }
}