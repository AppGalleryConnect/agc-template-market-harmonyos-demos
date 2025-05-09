import { TabListItem } from '../constants/Constants'

@Component
export struct TabBarView{
  @Prop data:TabListItem
  @Prop currentIndex:number
  @Prop index:number
  onClickTab: (index: number) => void = ()=> {}

  build() {
    Column() {
      Row() {
        Text(this.data.label)
          .fontColor(this.currentIndex === this.index ?
          $r('app.color.tab_font_color_selected') :
          $r('app.color.tab_font_color'))
          .fontSize(14)
      }
      .backgroundColor(this.currentIndex === this.index ?
      $r('app.color.tab_background_color_selected') :
      $r('app.color.tab_background_color'))
      .height(36)
      .borderRadius(21)
      .width(96)
      .justifyContent(FlexAlign.Center)
    }
    .onClick(() => {
      this.onClickTab(this.index)
    })
  }
}