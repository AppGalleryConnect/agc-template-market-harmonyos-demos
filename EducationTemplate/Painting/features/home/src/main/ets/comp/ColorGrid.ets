import { Constants } from 'common'

@ComponentV2
export struct ColorGrid {
  @Param colorList: string[] = []
  @Param selectColor: string = '#ffffff'
  @Param gridHeight: number = 312
  @Event colorChange: (color: string) => void = (color: string) => {
  }

  build() {
    Grid() {
      ForEach(this.colorList, (color: string) => {
        GridItem() {
          Stack({ alignContent: Alignment.Center }) {
            Circle()
              .width(24)
              .height(24)
              .fill(color)
              .strokeWidth(0.2)
              .stroke('#4D000000')
            if (this.selectColor === color) {
              Circle()
                .width(12)
                .height(12)
                .fill(color === '#FFFFFF' ? Color.Black : Color.White)
            }
          }
          .width(24)
          .height(24)
        }
        .onClick(() => {
          this.colorChange(color)
        })
      },(color:string) => color)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
    .columnsGap(16)
    .rowsGap(16)
    .width(Constants.FULL_SIZE)
    .height(this.gridHeight)
  }
}