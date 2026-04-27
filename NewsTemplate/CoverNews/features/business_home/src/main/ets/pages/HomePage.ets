import { SwiperView } from '../components/SwiperView'
import { HomePageVM } from '../viewmodels/HomePageVM'

@ComponentV2
export struct HomePage {
  private vm: HomePageVM = new HomePageVM();

  aboutToAppear(): void {
    this.vm.queryNewsList();
  }

  build() {
    Column() {
      Stack() {
        SwiperView({
          newsList: this.vm.newsList,
          swiperController: this.vm.swiperController,
          onCurrentIndexChange: (index) => {
            this.vm.currentIndex = index;
          },
        })
        if (this.vm.currentIndex !== 0) {
          this.backToTob()
        }
      }
      .alignContent(Alignment.Bottom)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  backToTob() {
    Row({ space: 4 }) {
      Text('返回顶部')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_secondary'))
      SymbolGlyph($r('sys.symbol.arrow_up'))
        .fontSize(16)
        .fontColor([$r('sys.color.font_on_secondary')])
    }
    .width(86)
    .height(40)
    .margin({
      bottom: this.vm.breakPointModel.isTabVertical ? 40 : 0,
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.vm.swiperController.changeIndex(0);
    })
  }
}
