@ComponentV2
export struct CapsuleTab {
  @Local currentIndex: number = 0
  @Local capsulePosition: number = 0
  private tabItems: string[] = ['银行理财', '复利理财', '定投理财']
  private tabContainerWidth: number = 0
  @Event onChange: (index: number) => void = () => {
  }
  @Param index: number = 0

  @Monitor('index')
  onIndexChange() {
    this.onChangeTab(this.index)
  }

  private calculateCapsuleStyle() {
    this.capsulePosition = this.currentIndex * this.tabContainerWidth
  }

  private onChangeTab(index: number) {
    if (this.currentIndex !== index) {
      this.onChange(index)
      this.getUIContext().animateTo({
        duration: 300,
        curve: Curve.EaseInOut,
      }, () => {
        this.currentIndex = index;
        this.calculateCapsuleStyle();
      });
    }
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
          ForEach(this.tabItems, (item: string, index: number) => {
            Text(item)
              .flexGrow(1)
              .height('100%')
              .textAlign(TextAlign.Center)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .onClick(() => {
                this.onChangeTab(index)
              })
          }, (item: string) => item)
        }
        .width('99%')

        Row() {
          Text(this.tabItems[this.currentIndex])
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
        }
        .width('33%')
        .height(36)
        .borderRadius(20)
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)
        .onAreaChange((oldValue, newValue) => {
          this.tabContainerWidth = Number(newValue.width)
          this.calculateCapsuleStyle()
        })
        .position({ x: this.capsulePosition, y: 2 })
      }
      .position({ left: '0.5%' })
    }
    .width('100%')
    .height(40)
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .borderRadius(20)
  }
}