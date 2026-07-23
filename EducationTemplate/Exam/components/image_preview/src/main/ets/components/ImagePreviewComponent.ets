import { display } from '@kit.ArkUI';
import ComponentUtils from '@ohos.arkui.UIContext';
import { PromptActionTool } from '../utils/PromptActionTool';
import { PreviewConstants } from '../constants/Constants';
import { ImagePreviewOptions } from '../models/ImagePreviewOptions'
import { SwiperItemRender } from './SwiperItemRender';
import { PreviewComponentInfo, SourceImageModel } from '../models/PreviewModel';

/**
 * 某些场景下，在状态管理V2中使用animateTo动画，会产生异常效果
 * 这里用ComponentV1暂时先替代，从API version 22开始，可以使用applySync接口实现预期的显示效果。
 * */

@Component
export struct ImagePreviewComponent {
  @ObjectLink @Watch('valueChanged') options: ImagePreviewOptions
  @State currentPage: number = 0
  @State alpha: number = 0
  @State currentOffsetX: number = 0
  @State currentOffsetY: number = 0
  @State scaleRadio: number = 1
  @State animating: boolean = false
  @State thumbWidth?: Length = 0
  @State thumbHeight?: Length = 0
  @State thumbX?: Length = 0
  @State thumbY?: Length = 0
  @State isDisabledSwiper: boolean = false
  @State longTakeEffectMap: Map<number, PreviewComponentInfo> = new Map()
  private componentUtils: ComponentUtils.ComponentUtils = this.getUIContext().getComponentUtils()
  private isScrolling: boolean = false
  private timeOutTag: number = 0
  private controller = new SwiperController()
  private uiContext: UIContext = this.getUIContext()
  private previewComponentInfo?: PreviewComponentInfo
  private firstLoad: boolean = false
  @BuilderParam topBuilder?: () => void
  @BuilderParam bottomBuilder?: () => void

  aboutToAppear() {
    this.currentPage = this.options.startIndex
  }

  valueChanged() {
    if (this.options.needDismiss) {
      this.closeAnimation(this.options.dismissAnimation)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width(PreviewConstants.FULL_SIZE)
        .height(PreviewConstants.FULL_SIZE)
        .backgroundColor(this.options.backgroundColor)
        .opacity(this.alpha)

      Swiper() {
        ForEach(this.options.dataList, (item: SourceImageModel, index: number) => {
          Stack({ alignContent: Alignment.Center }) {
            Image(item.imageUrl)
              .width(PreviewConstants.FULL_SIZE)
              .height(PreviewConstants.FULL_SIZE)
              .objectFit(ImageFit.Cover)
              .borderRadius(12)
              .clip(true)
          }
        }, (item: SourceImageModel, index: number) => `${item.imageUrl}+${index}`)
      }
      .index(this.currentPage)
      .margin({
        left: this.thumbX,
        top: this.thumbY,
      })
      .width(this.thumbWidth)
      .height(this.thumbHeight)
      .indicator(false)
      .loop(false)
      .cachedCount(0)
      .visibility(this.animating && this.options.longTake ? Visibility.Visible : Visibility.Hidden)

      Stack({ alignContent: Alignment.Top }) {
        Swiper(this.controller) {
          Repeat(this.options.dataList).each(repeat => {
            Column() {
              SwiperItemRender({
                params: this.options,
                imageSrc: repeat.item,
                index: repeat.index,
                longTakeEffectMap: this.longTakeEffectMap,
                startIndex: this.currentPage,
                onDisabledSwiper: (value: boolean) => {
                  this.isDisabledSwiper = value
                },
                onLoadingStatus: (val, index) => {
                  if (val === 1 && this.currentPage === index && !this.firstLoad) {
                    this.getPreviewUIInfo(repeat.index)
                    if (!this.firstLoad) {
                      this.firstLoad = true
                      this.startAnimation()
                    }
                  }
                },
              })
                .offset({
                  x: this.currentOffsetX,
                  y: this.currentOffsetY,
                })
                .id(`preview+${this.options.snapshotId(repeat.item.imageUrl, repeat.index)}`)
                .scale({ x: this.scaleRadio, y: this.scaleRadio })
                .visibility(!this.animating && this.firstLoad ? Visibility.Visible : Visibility.Hidden)
            }
            .width(PreviewConstants.FULL_SIZE)
            .justifyContent(FlexAlign.Center)
          })
            .virtualScroll({
              onTotalCount: () => {
                return this.options.dataList.length
              },
            })
        }
        .indicator(this.options.indicator)
        .index(this.currentPage)
        .width(PreviewConstants.FULL_SIZE)
        .height(PreviewConstants.FULL_SIZE)
        .loop(this.options.loop)
        .clip(true)
        .disableSwipe(this.isDisabledSwiper as boolean)
        .onAnimationStart(() => {
          this.isScrolling = true
        })
        .onAnimationEnd(() => {
          clearTimeout(this.timeOutTag)
          this.timeOutTag = setTimeout(() => {
            this.isScrolling = false
          }, 50)
        })
        .onChange((index) => {
          this.currentPage = index
          this.options.onPageChangedListener(this.options.dataList[index], index)
        })

        Row() {
          Blank()
          Text(`${this.currentPage + 1}/${this.options.dataList.length}`)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(14)
            .visibility(this.options.showPageText && this.options.dataList.length >= 1 ? Visibility.Visible :
              Visibility.None)
            .margin({ top: 40, right: 40 })
        }
        .width(PreviewConstants.FULL_SIZE)
        .hitTestBehavior(HitTestMode.Transparent)
        .visibility(!this.animating && this.firstLoad ? Visibility.Visible : Visibility.Hidden)

        // 顶部自定义组件插槽
        if (this.topBuilder) {
          Column() {
            this.topBuilder()
          }
          .position({ left: 0, top: 0 })
          .visibility(!this.animating && this.firstLoad ? Visibility.Visible : Visibility.Hidden)
        }
        // 底部自定义组件插槽
        if (this.bottomBuilder) {
          Column() {
            this.bottomBuilder()
          }
          .position({ left: 0, bottom: 0 })
          .visibility(!this.animating && this.firstLoad ? Visibility.Visible : Visibility.Hidden)
        }
      }

    }
    .width(PreviewConstants.FULL_SIZE)
    .height(PreviewConstants.FULL_SIZE)
    .onClick(() => {
      if (!this.isScrolling) {
        this.closeAnimation()
      }
    })
  }

  getPreviewUIInfo(index: number) {
    /**
     * 获取图片大小、位置相关信息
     * 通过图片实际带下，当前偏移量实现一镜到底逻辑
     * */
    let result = this.longTakeEffectMap.get(index)
    this.previewComponentInfo = result
  }

  getInitUIInfo() {
    let id = this.options.snapshotId(this.options.dataList[this.currentPage].imageUrl, this.currentPage)
    let result = this.componentUtils.getRectangleById(id)
    if (result.size.width > 0 && result.size.height > 0) {
      this.thumbX = this.uiContext.px2vp(result.screenOffset?.x)
      this.thumbY = this.uiContext.px2vp(result.screenOffset?.y)
      this.thumbWidth = this.uiContext.px2vp(result.size?.width)
      this.thumbHeight = this.uiContext.px2vp(result.size?.height)
    } else {
      this.thumbX = this.uiContext.px2vp(display.getDefaultDisplaySync().width) / 2 - 10
      this.thumbY = this.uiContext.px2vp(display.getDefaultDisplaySync().height) / 2 - 10
      this.thumbWidth = 10
      this.thumbHeight = 10
    }
  }

  startAnimation() {
    if (this.animating) {
      return
    }
    this.animating = true
    this.getInitUIInfo()
    this.getUIContext().animateTo({
      duration: this.options.duration, onFinish: () => {
        this.animating = false
        this.options.onPageChangedListener(this.options.dataList[this.currentPage], this.currentPage)
      },
    }, () => {
      this.alpha = 1
      this.thumbX = this.uiContext.px2vp(this.previewComponentInfo?.contentOffsetX)
      this.thumbY = this.uiContext.px2vp(this.previewComponentInfo?.contentOffsetY)
      this.thumbWidth = this.previewComponentInfo?.width
      this.thumbHeight = this.previewComponentInfo?.height
    })
  }

  closeAnimation(animated: boolean = true) {
    if (this.animating) {
      return
    }
    this.getPreviewUIInfo(this.currentPage)
    this.animating = true
    this.thumbX = this.uiContext.px2vp(this.previewComponentInfo?.contentOffsetX) + this.currentOffsetX
    this.thumbY = this.uiContext.px2vp(this.previewComponentInfo?.contentOffsetY) + this.currentOffsetY
    this.thumbWidth = this.previewComponentInfo?.width ?? 0 * this.scaleRadio
    this.thumbHeight = this.previewComponentInfo?.height ?? 0 * this.scaleRadio
    this.uiContext.animateTo({
      duration: animated ? this.options.duration : 0, onFinish: () => {
        this.animating = false
        this.options.onBackListener()
        PromptActionTool.closeCustomDialog(this.getUIContext(), this.options.dialogId)
      },
    }, () => {
      this.getInitUIInfo()
      this.alpha = 0
    })
  }
}