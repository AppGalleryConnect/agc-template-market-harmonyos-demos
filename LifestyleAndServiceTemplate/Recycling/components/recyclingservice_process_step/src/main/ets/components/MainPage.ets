@Component
export struct MainPage {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .onClick(() => {
            this.message = 'Welcome!!!';
          })
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.page_text_font_size'))
      }
      .width('100%')
    }
    .height('100%')
  }
}
