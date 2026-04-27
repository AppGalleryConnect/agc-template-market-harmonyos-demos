@ComponentV2
export struct ChangeScreen{
  @Event onChangeScreen:Function = ()=>{
  }
  build() {
    Image($r('app.media.change_screen'))
      .width(40)
      .height(40)
      .onClick(() => {
        this.onChangeScreen()
      })
  }
}