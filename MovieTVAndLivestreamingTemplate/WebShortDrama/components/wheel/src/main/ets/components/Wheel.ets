import { getCoin } from '../utils/getCoin'
import CommonConstants from '../constants/CommonConstants'
import StyleConstants from '../constants/StyleConstants'
import PrizeDialog from '../customdialog/PrizeDialog'
import DrawModel from '../viewmodel/DrawModel'
import PrizeData from '../model/PrizeData'
import { TYCard } from '../common/TYCard'

@ComponentV2
export struct Wheel {
  // 画布尺寸
  private canvasWidth: number = 262
  private canvasHeight: number = 268
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @Local drawModel: DrawModel = new DrawModel()
  @Local rotateDegree: number = 0
  @Provider('enableFlag') enableFlag: boolean = true
  @Provider('prizeData') prizeData: PrizeData = new PrizeData()
  @Consumer('curTabIndex') currentIndex: number = 2
  @Local drawsNumber: number = 1
  @Local isAnimateFinish: boolean = false
  @Param textCOIN: string[] = ['18看点', '38看点', '68看点', '18看点', '188看点', '888看点']
  @Param title: string = '福利转盘'
  @Param subTitle: string = '最高可得8888看点'
  @Event onWheelSuccess: (balance: number) => void
  @Param isLogin: boolean = true
  @Event loginFunc: () => void = () => {
  }
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PrizeDialog(),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  })

  @Monitor('isAnimateFinish')
  onEnableFlagChange() {
    if (this.isAnimateFinish) {
      this.enableFlag = true
    }
  }

  build() {
    TYCard({
      liftTitle: this.title,
      rightTitle: this.subTitle,
      bottomPadding: 20,
    }) {
      Stack({ alignContent: Alignment.Center }) {
        Canvas(this.canvasContext)
          .width(StyleConstants.FULL_PERCENT)
          .height(StyleConstants.FULL_PERCENT)
          .onReady(() => {
            this.drawModel.draw(this.canvasContext, this.canvasWidth, this.canvasHeight, this.textCOIN)
          })
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            angle: this.rotateDegree,
            centerX: this.canvasWidth / CommonConstants.TWO,
            centerY: this.canvasHeight / CommonConstants.TWO
          })

        Image($r('app.media.award_ic_center'))
          .width(StyleConstants.CENTER_IMAGE_WIDTH)
          .enabled(this.enableFlag)
          .onClick(() => {
            if (this.isLogin) {
              this.handleImageClick()
            } else {
              this.loginFunc()
            }
          })
      }
      .width(this.canvasWidth)
      .height(this.canvasHeight)
      .margin({ top: 17 })
    }
  }

  /**
   * 处理图片点击事件
   */
  handleImageClick() {
    if (this.drawsNumber > 0) {
      this.startAnimator()
      this.drawsNumber -= 1
    } else {
      this.increaseDrawsNumber()
    }
  }

  /**
   * 增加抽奖次数
   */
  increaseDrawsNumber() {
    // promptAction.showToast({ message: '看广告增加抽奖次数' })
    this.drawsNumber += 1
  }

  /**
   * 开始旋转
   */
  startAnimator() {
    this.enableFlag = false
    let randomAngle = this.generateRandomAngle()
    this.updatePrizeData(randomAngle)
    this.animateRotation(randomAngle)

  }

  /**
   * 生成随机角度
   */
  generateRandomAngle(): number {
    return Math.round(Math.random() * CommonConstants.CIRCLE)
  }

  /**
   * 更新奖品数据
   */
  updatePrizeData(randomAngle: number) {
    this.prizeData = this.drawModel.showPrizeData(randomAngle)
    if (this.prizeData.message) {
      this.updateBalance()
    }
  }

  /**
   * 更新余额
   */
  updateBalance() {
    const coinValue = getCoin(this.prizeData.message!)
    if (coinValue !== null && coinValue !== undefined) {
      this.onWheelSuccess(coinValue)
    }
  }

  /**
   * 执行旋转动画
   */
  animateRotation(randomAngle: number) {
    this.isAnimateFinish = false
    this.getUIContext().animateTo({
      duration: CommonConstants.DURATION,
      curve: Curve.Ease,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        this.rotateDegree = CommonConstants.ANGLE - randomAngle
        if (this.currentIndex === 2) {
          this.dialogController.open()
        }
        this.isAnimateFinish = true
      }
    }, () => {
      this.rotateDegree = CommonConstants.CIRCLE * CommonConstants.FIVE +
        CommonConstants.ANGLE - randomAngle
    })
  }
}