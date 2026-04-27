import { CommonSize } from '../utils/EditTextUtil'
import { EditTextVM } from '../viewmodel/EditTextVM'

@ComponentV2
export struct EditTextSnap {
  @Param @Require editTextVM: EditTextVM
  scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.editTextVM.snapScroller = this.scroller
  }

  build() {
    Row() {
      Scroll(this.scroller) {
        Text(this.editTextVM.textVal || '输入文字...')
          .width('100%')
          .fontColor(this.editTextVM.colorVal)
          .fontSize(16)
          .lineHeight(CommonSize.EDIT_TEXT_LINE_HEIGHT)
          .padding({
            left: 12,
            right: 12,
            top: 0,
            bottom: 0
          })
          .borderRadius(0)
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.editTextVM.setTextAreaHeight(newValue.height as number)
          })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
    }
    .width(this.editTextVM.width)
    .height(this.editTextVM.height)
    .position({ x: 0, y: 0 })
    .id(`EditTextSnapId${this.editTextVM.id}`)
    .zIndex(99)
    .rotate({
      x: 0,
      y: 0,
      z: 1,
      angle: this.editTextVM.angle
    })
  }
}