import { ToggleItem } from './Index.type'

/**
 * @usage: 用于滑动切换选择场景。提供带滑动动画的多选项切换功能，支持自定义背景色和选项列表。
 * 关键数据结构：ToggleItem（切换项模型，包含id标识和name名称）、switchHeight（切换条高度）、
 * defaultBg（默认背景色）、selectedBg（选中背景色）、toggleList（切换项列表数组）、
 * currentIndex（默认选中项索引）、chooseIndex（当前选中索引）、rWidth（选中项宽度）、
 * translateX（滑块X轴偏移量）、positionMap（位置映射Map，key为索引，value为Area区域信息）、
 * onChooseChange（切换事件回调函数，参数为选中索引）。
 * 包含if逻辑：通过@Monitor监听currentIndex变化并更新chooseIndex和滑块位置，
 * 通过positionMap判断是否已记录位置信息来计算translateX和宽度。
 * @layout: 垂直Column布局。内部为Stack堆叠布局（左对齐），底层为Flex横向布局（SpaceBetween对齐），
 * 使用ForEach遍历toggleList渲染选项Row（每项flexGrow为1均分宽度、居中对齐、监听onAreaChange记录位置信息），
 * 顶层为滑动指示器Row（白色背景、圆角18vp、宽度根据选中项动态计算、通过translate实现滑动动画）。
 * 整体高度36vp、圆角18vp、内边距3vp、背景色为defaultBg。点击选项触发300ms缓出动画切换。
 * @constraints: toggleList切换项列表不能为空，currentIndex必须为有效索引（0到toggleList.length-1），
 * positionMap在onAreaChange事件中记录每个选项的位置信息不可修改，
 * 滑动动画使用animateTo（持续时间300ms、曲线Curve.EaseOut）固定，
 * @Monitor装饰器监听currentIndex变化并同步更新chooseIndex和滑块位置
 * @isGen: true
 * @fileType: component
 * @zhName: 基础滑动切换组件
 */

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