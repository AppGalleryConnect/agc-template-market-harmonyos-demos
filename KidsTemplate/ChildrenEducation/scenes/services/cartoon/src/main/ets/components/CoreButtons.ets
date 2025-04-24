@ComponentV2
export struct CoreButtons {
  build() {
    Column() {
      Row({ space: 16 }) {
        Column({ space: 10 }) {
          Image($r('app.media.drawing_board_1'))
          Text('超级汽车')
            .fontSize(12)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.black'))
            .opacity(0.9)
        }
        .width(65)
        .height(65)

        Column({ space: 10 }) {
          Image($r('app.media.drawing_board_2'))
          Text('国学')
            .fontSize(12)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.black'))
            .opacity(0.9)
        }
        .width(65)
        .height(65)

        Column({ space: 10 }) {
          Image($r('app.media.drawing_board_3'))
          Text('科普百科')
            .fontSize(12)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.black'))
            .opacity(0.9)
        }
        .width(65)
        .height(65)

        Column({ space: 10 }) {
          Image($r('app.media.drawing_board_4'))
          Text('多米')
            .fontSize(12)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.black'))
            .opacity(0.9)
        }
        .width(65)
        .height(65)
      }.padding({ left: 24 })
    }
  }
}