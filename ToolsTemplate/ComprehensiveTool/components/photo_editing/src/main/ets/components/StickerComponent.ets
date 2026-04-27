import { StickerModel } from '../model/BeautificationParam';

@ComponentV2
export struct StickerComponent {
  @Param @Require item: StickerModel;
  @Param @Require onDelete?: (id: string) => void;
  @Local offsetX: number = 0;
  @Local offsetY: number = 0;
  @Local borderShow: boolean = false;
  private timerId: number = 0;

  aboutToAppear(): void {
    this.clearTimer();
    this.borderShow = true;
    this.timerId = setTimeout(() => {
      this.borderShow = false;
    }, 100);
  }

  build() {
    Column() {
      Image(this.item.img)
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain);
      Image($r('app.media.xmark'))
        .backgroundColor('#F1F3F5')
        .width(20)
        .height(20)
        .borderRadius(10)
        .position({ top: -10, right: -10 })
        .opacity(0.5)
        .visibility(this.borderShow ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete(this.item.id);
          }
        });
    }
    .width(100)
    .height(100)
    .translate({ x: this.offsetX, y: this.offsetY, z: 0 })
    .border({
      width: this.borderShow ? 1 : 0,
      color: this.borderShow ? Color.Gray : Color.Transparent,
      style: BorderStyle.Solid,
    })
    .onClick(() => {
      this.clearTimer();
      this.borderShow = !this.borderShow;
      this.timerId = setTimeout(() => {
        this.borderShow = false;
      }, 1000);
    })
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent | undefined) => {
          if (event) {
            this.offsetX = this.item.positionX + event.offsetX;
            this.offsetY = this.item.positionY + event.offsetY;
          }
        })
        .onActionEnd(() => {
          this.item.positionX = this.offsetX;
          this.item.positionY = this.offsetY;
        }),
    );
  }

  // 清理定时器
  private clearTimer() {
    if (this.timerId) {
      clearTimeout(this.timerId);
      this.timerId = 0;
    }
  }
}