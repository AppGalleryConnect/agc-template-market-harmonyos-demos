import { Logger } from '@hw-agconnect/ui-base'
import { BookInfo } from '../model/Book'
import { LazyDataVM } from '../model/LazyDataVM'


@ComponentV2
export struct TUISwiper {
  // 中间图片是否覆盖两边
  @Param isCovered: boolean = false
  // 中心图片宽度
  @Param @Once imgWidth: number = 264
  // 中心图片高度
  @Param @Once imgHeight: number = 190
  // 间隔时间
  @Param interval: number = 5000
  // 是否循环
  @Param isLoop: boolean = true
  // Builder
  // @Require @Param builderList: Src[] = []
  @Require @Param builderList: WrappedBuilder<[BookInfo]>[] = [];
  @Require @Param bookList: LazyDataVM<BookInfo> = new LazyDataVM();
  // 当前索引
  @Local currentIndex: number = 0
  // 当前索引的中间变量
  @Local bakIndex: number = 0
  // 记录每个图片的Y轴缩放情况
  @Local allScaleY: number[] = []
  // 记录每个图片的X轴缩放情况
  @Local allScaleX: number[] = []
  // 透明度渐变
  @Local allOpacity: number[] = []
  // 外层容器宽度,组件撑满容器
  @Local containerWidth: number = 0
  // 前后边距，前一项和后一项漏出的宽度
  @Local marginWidth: number = 0
  // 轮播高度，预留上各8的阴影范围
  @Local swiperHeight: number = 0
  // 平铺和覆盖模式下Y轴缩放比例区间长度
  @Local ratioY: number = 0
  // 覆盖模式下X轴缩放比例区间长度
  @Local ratioX: number = 0
  // 图片项和切换项之间的间隔，间隔模式为24,覆盖模式为32
  @Local imgSpace: number = 24
  // 外层容器相对360vp的比例
  @Local containerRatio: number = 1
  // 图片最大宽度，间隔模式为264，覆盖模式为296
  @Local maxWidth: number = 296
  // 图片最小宽度，间隔模式为136，覆盖模式为164
  @Local minWidth: number = 164
  // 外部容器宽度改变时，重新刷新轮播图
  @Local isShow: boolean = true
  private controller: SwiperController = new SwiperController()
  // 透明度变化区间长度
  private ratioOpacity: number = 0.1
  // 延时执行函数
  private timer: number = 0
  // 初始化图片宽高备份值
  private bakWidth: number = 0
  private bakHeight: number = 0
  // 标志是否为第一次加载导致容器宽度变化
  private changeFlag: number = 0
  // 当前图片被点击
  @Event onImageClick: (index: number) => void = () => {

  }

  // 根据切换模式初始化,宽高限制
  initDataByIsCovered(): void {
    if (this.imgWidth <= 0 || this.imgHeight <= 0) {
      Logger.error('Set the image width and height correctly!')
      return
    }
    this.currentIndex = 0
    // 获取当前容器宽度相对360vp的比率
    this.containerRatio = this.containerWidth / 360
    // 覆盖模式限制宽度
    if (this.isCovered) {
      // 初始化覆盖模式下的样式属性
      this.imgSpace = 32 * this.containerRatio
      this.maxWidth = 296 * this.containerRatio
      this.minWidth = 164 * this.containerRatio
      if (this.imgWidth > this.maxWidth) {
        this.imgHeight = this.imgHeight / (this.imgWidth / this.maxWidth)
        this.imgWidth = this.maxWidth
      }
      if (this.imgWidth < this.minWidth) {
        this.imgHeight = this.imgHeight * (this.minWidth / this.imgWidth)
        this.imgWidth = this.minWidth
      }
      this.marginWidth = this.containerWidth / 3
      // 根据上下间距,确定覆盖模式下Y轴缩放比例
      this.ratioY = 2 * this.imgSpace / this.imgHeight
      // 确定X轴缩放比例
      this.ratioX = (this.imgWidth - this.marginWidth) / this.imgWidth
      // 计算覆盖状态下X轴的缩放比例
      this.allScaleX = new Array(this.builderList.length).fill(1 - this.ratioX)
      this.allScaleX[0] = 1
      // 初始化透明度变化区间
      this.allOpacity = new Array(this.builderList.length).fill(1 - this.ratioOpacity)
      this.allOpacity[0] = 1
    } else {
      this.imgSpace = 24 * this.containerRatio
      this.maxWidth = 264 * this.containerRatio
      this.minWidth = 136 * this.containerRatio
      // 平铺切换模式限制宽度
      if (this.imgWidth > this.maxWidth) {
        this.imgHeight = this.imgHeight / (this.imgWidth / this.maxWidth)
        this.imgWidth = this.maxWidth
      }
      if (this.imgWidth < this.minWidth) {
        this.imgHeight = this.imgHeight * (this.minWidth / this.imgWidth)
        this.imgWidth = this.minWidth
      }
      this.marginWidth = (this.containerWidth - this.imgWidth - this.imgSpace) / 2
      // 根据上下间距,确定缩放比例
      this.ratioY = 2 * this.imgSpace / this.imgHeight
    }
    // 预留上下8的间隔
    this.swiperHeight = this.imgHeight + 16 * this.containerRatio

    // 初始化最开始的缩放比例
    this.allScaleY = new Array(this.builderList.length).fill(1 - this.ratioY)
    this.allScaleY[0] = 1
  }

  aboutToAppear(): void {
    if (this.builderList.length < 3) {
      Logger.error('Please transfer at least three images!')
    } else {
      //备份初始化宽高，防止因窗口变化，宽高变化后，无法恢复
      this.bakWidth = this.imgWidth
      this.bakHeight = this.imgHeight
      this.initDataByIsCovered()
    }
  }

  build() {
    Column() {
      if (this.isShow) {
        Swiper(this.controller) {
          ForEach(this.builderList, (builder: WrappedBuilder<[BookInfo]>, index) => {
            Column() {
              Stack() {
                builder.builder(this.bookList.getData(index))
              }
              .borderRadius(this.currentIndex === index ? 24 : 12)
              // .shadow({ radius: vp2px(4 * this.containerRatio), color: 'rgba(0,0,0,0.2)', fill: true })
              .height(this.imgHeight * this.allScaleY[index])
              .width(this.imgWidth)
              .onClick(() => {
                if (index === this.currentIndex) {
                  this.onImageClick(index)
                } else {
                  this.controller.changeIndex(index, true)
                }
              })
            }
            .justifyContent(FlexAlign.Center)
            .padding({ top: 8 * this.containerRatio, bottom: 8 * this.containerRatio })
            .margin({ left: 12 * this.containerRatio, right: 12 * this.containerRatio })
          }, (item: WrappedBuilder<[BookInfo]>, index) => index.toString())
        }
        .width(this.containerWidth)
        .height(this.swiperHeight)
        .prevMargin(this.marginWidth)
        .nextMargin(this.marginWidth)
        .indicator(false)
        .autoPlay(true)
        .interval(this.interval) // 停留时间
        .loop(this.isLoop)
        .customContentTransition({
          timeout: 1000,
          transition: (proxy: SwiperContentTransitionProxy) => {
            // 计算缩放比例
            let scaleY = 1 - (Math.abs(proxy.position)) * this.ratioY
            this.allScaleY[(proxy.index)%(this.allScaleY.length)] = scaleY
            let scaleX = 1 - (Math.abs(proxy.position)) * this.ratioX
            this.allScaleX[(proxy.index)%(this.allScaleX.length)] = scaleX
            // 计算透明度变化区间
            let opacity = 1 - (Math.abs(proxy.position)) * this.ratioOpacity
            this.allOpacity[(proxy.index)%(this.allOpacity.length)] = opacity
            this.currentIndex = this.bakIndex
          }
        })
        .onAnimationStart((index, targetIndex) => {
          this.bakIndex = targetIndex
          this.currentIndex = this.bakIndex
        })
        .onAppear(() => {
          // 清除定时器
          clearTimeout(this.timer)
        })
      }
    }.size({ width: '100%', height: this.swiperHeight }).onAreaChange((oldValue: Area, newValue: Area) => {
      // 根据外层容器撑满
      if (this.containerWidth !== newValue.width as number) {
        this.containerWidth = newValue.width as number
        // 恢复初始化宽高
        this.imgWidth = this.bakWidth
        this.imgHeight = this.bakHeight
        // 除初始化外，折叠，翻转引起容器宽度化，需重新加载轮播组件
        if (this.changeFlag !== 0) {
          this.isShow = false
          // 强制刷新轮播图组件，避免出现异常
          this.timer = setTimeout(() => {
            this.isShow = true
          }, 100)
        }
        // 标志容器宽度变化的次数
        this.changeFlag++
        this.initDataByIsCovered()
      }
    })
  }
}



