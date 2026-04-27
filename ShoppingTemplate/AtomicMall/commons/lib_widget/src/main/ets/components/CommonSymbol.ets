@ComponentV2
export struct CommonSymbol{
  @Param @Require
  src:Resource
  @Param
  color:ResourceColor = $r('sys.color.font_primary')
  @Param
  fontSize:Length = 24

  build() {
    Row(){
      SymbolGlyph(this.src)
        .fontSize(this.fontSize)
        .fontColor([this.color])
    }
    .width(40)
    .height(40)
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .stateStyles({
      normal: { .backgroundColor($r('sys.color.comp_background_tertiary'))
      },
      pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
      },
    })
  }
}