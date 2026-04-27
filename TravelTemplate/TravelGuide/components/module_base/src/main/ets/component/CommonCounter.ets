@ComponentV2
export struct CommonCounter {
  @Param weight: number = 0
  @Param unit: string = ''
  @Local currentWeight: number = 0
  @Event onChange: (value: number) => void = () => {
  }

  @Monitor('weight')
  weightChange() {
    this.currentWeight = this.weight
  }

  aboutToAppear(): void {
    this.currentWeight = this.weight
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_minus'))
          .width(24)
          .height(24)
      }
      .width(32)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.currentWeight > 0) {
          this.currentWeight--
          if (this.currentWeight < 0) {
            this.currentWeight = 0
          }
        }
        this.onChange(this.currentWeight)
      })


      Row() {
        Text() {
          Span(this.currentWeight.toString())
            .margin({ right: 2 })
          Span(this.unit)
        }
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8, right: 8 })
      }

      Row() {
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
      }
      .width(32)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.currentWeight++
        this.onChange(this.currentWeight)
      })
    }
  }
}