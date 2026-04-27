//颜色显示
@ComponentV2
export struct ColorShow {
  @Param color: string = '#fff'
  @Param r: number = 255
  @Param g: number = 255
  @Param b: number = 255
  @Param touchX: number = 0
  @Param touchY: number = 0
  @Param maxWidth: number = 375

  private getPositionX(): number {
    const offsetX = this.touchX< this.maxWidth - 160 ? 80 : 160
    return Math.max(0, this.touchX - offsetX)
  }

  private getPositionY(): number {
    const offsetY = this.touchY < 80 ? 72 : -100
    return Math.max(0, this.touchY + offsetY)
  }

  build() {
    Column() {
      Column()
        .width(24)
        .height(24)
        .backgroundColor(this.color)
        .shadow({
          radius: 12,
          color: '#000000',
          offsetX: 5,
          offsetY: 5
        })
      Row() {
        Text('R:' + this.r + ' G:' + this.g + ' B:' +
        this.b + ' ' + this.color)
          .fontSize($r('sys.float.Body_S'))
          .fontColor(Color.White)
      }
      .padding(8)
      .height(32)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor('#E61A1A1A')
      .margin({ top: 13 })
    }
    .position({
      x: this.getPositionX(),
      y: this.getPositionY()
    })
  }
}