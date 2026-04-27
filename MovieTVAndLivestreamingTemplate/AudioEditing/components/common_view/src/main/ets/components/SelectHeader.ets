import { phoneRouterControl } from 'oh_router';

@ComponentV2
export struct SelectHeader {
  @Param title: string = ''
  @Param searchOnclick:()=>void = ()=>{

  }
  @Param hideSearch?: boolean = false

  build() {
    Row() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.icon_on_primary')])
            .fontSize(24)
        }
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => {
          phoneRouterControl.popPage()
        })

        Text(this.title).fontSize(20).fontColor(Color.White).margin({ left: 8 })
      }.layoutWeight(1)

      if (!this.hideSearch) {
        Row() {
          Image($r('app.media.ic_public_search')).width(19).height(19)
            .onClick(()=>{
              this.searchOnclick()
            })
        }.width(40)
        .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      }
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 8 })
    .backgroundColor('#0A0D1E')
  }
}