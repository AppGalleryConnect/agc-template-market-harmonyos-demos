import { ToggleItem } from './Index.type'

@ComponentV2
export struct BaseSliderSwitch {
  /**
   * 切换条高度
   */
  @Param switchHeight: ResourceStr | number = 36
  /**
   * 默认背景色
   */
  @Param defaultBg: ResourceStr | Color = $r('sys.color.background_secondary')
  /**
   * 选中背景色
   */
  @Param selectedBg: ResourceStr | Color = $r('sys.color.background_primary')
  /**
   * 右侧图标
   */
  @Param toggleList: ToggleItem[] = []
  /**
   * 默认选中项
   */
  @Param currentIndex: number = 0
  /**
   * 切换事件
   */
  @Event onChooseChange: (index: number) => void = () => {
  }
  @Local chooseIndex: number = 0
  @Local rWidth: number = 0
  @Local rHeight: number = 0
  @Local translateX: number = 0
  @Local positionMap: Map<number, Area> = new Map()

  @Monitor('currentIndex')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      this.chooseIndex = this.currentIndex
      this.getPositionX()
    })
  }

  aboutToAppear(): void {
    this.chooseIndex = this.currentIndex
  }

  getPositionX() {
    if (this.positionMap.has(this.chooseIndex)) {
      this.translateX = Number(this.positionMap.get(this.chooseIndex)?.position?.x ?? 0)
      this.rWidth = Number(this.positionMap.get(this.chooseIndex)?.width)
    }
  }

  getWidth() {
    if (this.positionMap.has(this.chooseIndex)) {
      return this.positionMap.get(this.chooseIndex)?.width
    }
    return this.rWidth
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(18)
          .width(this.getWidth())
          .height('100%')
          .translate({ x: this.translateX })
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.toggleList, (item: ToggleItem, index: number) => {
            Row() {
              Text(item.name)
            }
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .flexGrow(1)
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.positionMap.set(index, newValue)
            })
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.chooseIndex = index
                this.getPositionX()
                this.onChooseChange(this.chooseIndex)
              })
            })
          }, (item: ToggleItem) => item.id)
        }
      }
      .borderRadius(18)
      .height(36)
      .padding(3)
      .backgroundColor(this.defaultBg)
    }
  }
}