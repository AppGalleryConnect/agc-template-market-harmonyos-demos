import { ItineraryTabItem } from '../model/ItineraryPageModel'

@ComponentV2
export struct TabBarView {
  @Param tabNav: ItineraryTabItem = new ItineraryTabItem('', 0, '')
  @Param index: number = 0
  @Param curIndex: number = 0
  @Event changeTab: () => void = () => {
  }

  build() {
    Column() {
      Text() {
        Span(this.tabNav.label)
        Span(' ')
        Span(this.tabNav.count + '')
      }
      .fontSize(16)
      .fontColor(this.index === this.curIndex ? '#E6000000' : '#66000000')
      .fontWeight(this.index === this.curIndex ? FontWeight.Medium : FontWeight.Regular)

      Column().width(48).height(3).backgroundColor('#466DFA')
        .margin({top: 8})
        .borderRadius(2)
        .visibility(this.index === this.curIndex ? Visibility.Visible : Visibility.Hidden)
    }
    .onClick(() => {
      this.changeTab && this.changeTab()
    })
  }
}