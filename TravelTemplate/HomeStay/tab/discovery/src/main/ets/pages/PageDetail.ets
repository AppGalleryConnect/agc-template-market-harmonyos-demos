import { TitleBar } from 'component';
import { TravelNote } from 'type';

@Builder
export function PageDetailBuilder() {
  PageDetail();
}

@Component
export struct PageDetail {
  @State data: TravelNote = new TravelNote();
  scroller: Scroller = new Scroller();
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  @Builder
  buildContent() {
    Column({ space: 10 }) {
      Swiper() {
        ForEach(this.data.imageList, (v: string) => {
          Image(v)
            .objectFit(ImageFit.Fill);
        }, (item: string) => item);
      }
      .height(290)
      .autoPlay(false)
      .loop(false)
      .indicator(new DotIndicator()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .color('#F5F6FA')
        .selectedColor($r('sys.color.comp_background_emphasize')))
      .width('100%');

      Text(this.data.title)
        .fontSize(20)
        .fontWeight(500)
        .fontColor('#191919')
        .lineHeight(28)
        .padding({ left: 16, right: 16 });
      Text(this.data.notes)
        .fontSize(14)
        .fontWeight(400)
        .fontColor('#191919')
        .lineHeight(20)
        .padding({ left: 16, right: 16 });

      Text(this.data.createTime.replace('T', ' '))
        .fontSize(10)
        .fontColor('#999999')
        .fontWeight(400)
        .lineHeight(14)
        .padding({ left: 16 });
    }
    .borderColor('#999999')
    .alignItems(HorizontalAlign.Start);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '游记详情', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll(this.scroller) {
          Column() {
            this.buildContent();
          };
        }.layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off);
      }
      .height('100%')
      .width('100%');
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.data = context.pathInfo.param as TravelNote;
    });
  }
}
