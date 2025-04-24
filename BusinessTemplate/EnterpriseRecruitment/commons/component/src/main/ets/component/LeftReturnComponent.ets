@ComponentV2
export struct LeftReturnComponent {
  build() {
    Stack() {
      Button({ type: ButtonType.Circle })
        .backgroundImage($r('app.media.ic_public_arrow_left_filled'))
        .backgroundColor($r('app.color.left_return_gray'))
        .width(35)
        .height(35)

      Image($r('app.media.ic_public_arrow_left_filled'))
        .height(30)
        .width(30)
    }
    .margin({ right: 10 })
  }
}