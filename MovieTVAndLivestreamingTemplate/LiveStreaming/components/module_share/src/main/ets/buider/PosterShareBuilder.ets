import { display } from '@kit.ArkUI'
import { PopupBaseController } from '../model/Model'
import { SheetShowVM } from '../viewModel/SheetShowVM'
import { SecondPosterShare } from './SecondPosterShareBuilder'
import { common } from '@kit.AbilityKit'

const popupDuration = 200
const hideDuration = 220


@ComponentV2
export struct PosterSharePopContent {
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  @Local transX: string | number = ''
  @Local transY: string | number = ''
  @Local screenWidth: number = 0
  @Local screenHeight: number = 0
  private context = this.getUIContext()
  /**
   * 底部偏移
   */
  @Param offsetY: number = 0
  /**
   * 自定义内容
   */
  @BuilderParam contentBuilder: CustomBuilder
  @Param baseController: PopupBaseController = new PopupBaseController()
  @Event close: () => void = () => {
  }

  aboutToAppear(): void {
    this.baseController.hide = (): void => this.init()
    this.init()
  }

  init() {
    try {
      display.getAllDisplays((err, data) => {
        this.screenWidth = this.context.px2vp(data[0].width)
        this.screenHeight = this.context.px2vp(data[0].height)
      })
      this.transY = '100%'
    } catch (e) {
    }
  }

  trans() {
    this.transY = 0
  }

  build() {
    Column() {
      Image(this.shareShowVM.posterImage)
        .width(270)
        .height(this.shareShowVM.coverUrl ? 370 : 270)
        .margin({ top: '30%' })
      Blank()
      Row() {
        Column() {
          SecondPosterShare({
            onCancel: () => {
              this.close()
            },
          })
        }
        .width('100%')
        .height('26%')
        .backgroundColor($r('sys.color.background_primary'))
        .alignItems(HorizontalAlign.Start)
        .borderRadius(24)
        .translate({
          y: this.transY,
        })
        .animation({ duration: popupDuration, curve: Curve.EaseInOut })
        .onAppear(() => {
          setTimeout(() => {
            this.trans()
          }, 100)
        })

      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .offset({ x: 0, y: 0 })
    .clip(true)
  }
}

@ComponentV2
export struct PosterSharePop {
  /**
   * 弹框展示状态
   */
  @Param @Require sharePopShow: boolean
  /**
   * 底部偏移
   */
  @Param offsetY: number = 0
  /**
   * 蒙层颜色
   */
  @Param maskColor: ResourceColor = '0x33000000'
  /**
   * 自定义内容
   */
  @BuilderParam contentBuilder: CustomBuilder
  /**
   * 弹框打开回调
   */
  @Event onOpen: () => void = () => {
  }
  /**
   * 弹框关闭回调
   */
  @Event onClose: () => void = () => {
  }
  @Event $sharePopShow: (visible: boolean) => void = () => {
  }
  private baseController: PopupBaseController = new PopupBaseController()
  private promptAction = this.getUIContext().getPromptAction()
  private dialogId: number = 0

  @Monitor('sharePopShow')
  visibleChange() {
    if (this.sharePopShow) {
      this.open()
    } else {
      this.baseController.hide()
      setTimeout(() => {
        this.promptAction.closeCustomDialog(this.dialogId)
      }, hideDuration)
    }
  }

  @Builder
  defaultContentBuilder() {
    PosterSharePopContent({
      offsetY: this.offsetY,
      contentBuilder: this.contentBuilder,
      baseController: this.baseController,
      close: (): void => this.close(),
    })
  }

  async open() {
    this.dialogId = await this.promptAction.openCustomDialog({
      builder: () => {
        this.defaultContentBuilder()
      },
      width: '100%',
      height: '100%',
      backgroundBlurStyle: BlurStyle.NONE,
      cornerRadius: 0,
      alignment: DialogAlignment.Bottom,
      maskColor: this.maskColor,
      offset: { dx: 0, dy: 35 },
      onDidAppear: () => {
        this.onOpen()
      },
      onDidDisappear: () => {
        this.onClose()
      },
    })
  }

  // 关闭弹框
  close() {
    this.$sharePopShow(false)
  }

  build() {
  }
}