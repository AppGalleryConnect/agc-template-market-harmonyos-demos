import { display } from '@kit.ArkUI'
import { PopupBaseController, ShareOptions } from '../model/Model'
import { SecondPosterShare } from './SecondPosterShareBuilder'
import { image } from '@kit.ImageKit'

const popupDuration = 200
const hideDuration = 220


@ComponentV2
export struct PosterSharePopContent {
  @Require @Param qrCodeInfo: ShareOptions
  @Local transX: string | number = ''
  @Local transY: string | number = ''
  @Local screenWidth: number = 0
  @Local screenHeight: number = 0
  @Event popClose:(isClose:boolean) => void = () => {}
  /**
   * 截图
   */
  @Param @Require pixmap: image.PixelMap
  /**
   * 底部偏移
   */
  @Param offsetY: number = 0
  /**
   * 封面
   */
  @Param coverUrl: string = ''
  /**
   * 自定义内容
   */
  @BuilderParam contentBuilder: CustomBuilder
  @Param baseController: PopupBaseController = new PopupBaseController()
  @Event close: () => void = () => {}

  aboutToAppear(): void {
    this.baseController.hide = (): void => this.init()
    this.init()
  }

  init() {
    try {
      display.getAllDisplays((err, data) => {
        this.screenWidth = px2vp(data[0].width)
        this.screenHeight = px2vp(data[0].height)
      })
    } catch (e) {
    }

    this.transY = '100%'
  }

  trans() {
    this.transY = 0
  }

  build() {
    Column() {
      Image(this.pixmap)
        .width(270)
        .height(this.coverUrl ? 370 : 270)
        .margin({ top: '30%' })
      Blank()
      Row() {
        Column() {
          SecondPosterShare({
            pixmap:this.pixmap,
            qrCodeInfo:this.qrCodeInfo,
            coverUrl:this.coverUrl,
            onCancel: () => {
              this.close()
            },
            popClose:(isClose:boolean) => {
              this.popClose(isClose)
            }
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
  @Require @Param qrCodeInfo: ShareOptions
  /**
   * 截图
   */
  @Param @Require pixmap: image.PixelMap
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
  @Event onOpen: () => void = () => {}
  /**
   * 弹框关闭回调
   */
  @Event onClose: () => void = () => {}
  @Event $sharePopShow: (visible: boolean) => void = () => {}
  @Event popClose:(isClose:boolean) => void = () => {}
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
      coverUrl:this.qrCodeInfo.coverUrl,
      qrCodeInfo:this.qrCodeInfo,
      pixmap:this.pixmap,
      contentBuilder: this.contentBuilder,
      baseController: this.baseController,
      close: (): void => this.close(),
      popClose:(isClose:boolean) => {
        this.popClose(isClose)
      }
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
    this.onClose()
  }

  build() {
  }
}