import window from '@ohos.window';
import { CommonUrl, Constants, ImageRouter } from 'common/Index';


@Component
export struct PreviewImagePage {
  @Consume('pageStack') pageStack: NavPathStack
  @State imageSrc: string = ''
  @State screenWidth: number = 0;
  @State op: number = 0

  aboutToAppear() {
    this.getParams()
    window.getLastWindow(getContext(this)).then(currentWindow => {
      let property = currentWindow.getWindowProperties();
      this.screenWidth = property.windowRect.width;
    })
  }

  getParams() {
    let paramsArr: ImageRouter[] = this.pageStack.getParamByName('PreviewImagePage') as ImageRouter[]
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1]
      this.imageSrc = routerParam?.imageSrc ?? ''
    }
  }

  closeDialog() {
    this.pageStack.pop()
  }

  build() {
    NavDestination() {
      Column() {
        ImageComponent({
          image: this.imageSrc,
          viewWidth: this.screenWidth,
          closeDialog: () => {
            this.closeDialog()
          }
        })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(`#66000000`)
    }.hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)

  }
}

// 进场过程中会逐帧触发onEnter回调，入参为动效的归一化进度(0% -- 100
@Component
struct ImageComponent {
  private image: string = ''
  private preGeometryScale: number = 1
  @State geometryScale: number = 1
  @State geometryOffsetX: number = 0
  @State geometryOffsetY: number = 0
  @State imageWidth: number = 0
  @State imageHeight: number = 0
  @Prop viewWidth: number = 0
  private closeDialog = () => {
  }

  reset(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.preGeometryScale = 1
      if (this.geometryScale === 1) {
        reject()
      }
      animateTo({ duration: 200, onFinish: resolve }, () => {
        this.geometryScale = 1
        this.geometryOffsetX = 0
        this.geometryOffsetY = 0
      })
    })
  }

  build() {
    Column() {
      Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.image}`)
        .onComplete((e) => {
          this.imageWidth = (e?.width || 0)
          this.imageHeight = (e?.height || 0)
        })
        .objectFit(ImageFit.Cover)
        .width(this.imageWidth + 'px')
        .height(this.imageHeight + 'px')
        .scale({
          x: this.geometryScale,
          y: this.geometryScale
        })
        .offset({
          x: this.geometryOffsetX,
          y: this.geometryOffsetY
        })
        .focusable(true)
        .objectFit(ImageFit.Cover)
        .autoResize(false)
        .sharedTransition('sharedImage', {
          duration: 200,
          curve: Curve.Linear,
        })
    }
    .clip(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.Center)
    .hitTestBehavior(HitTestMode.Default)
    .parallelGesture( // 在组件上绑定二指触发的捏合手势
      GestureGroup(GestureMode.Exclusive,
        PinchGesture({ fingers: 2 })
          .onActionStart((event: GestureEvent) => {
          })// 当捏合手势触发时，可以通过回调函数获取缩放比例，从而修改组件的缩放比例
          .onActionUpdate((event: GestureEvent) => {
            const s = this.preGeometryScale * event.scale;
            this.geometryScale = Math.max(0.6, Math.min(2, s))
          })
          .onActionEnd(async () => {
            this.preGeometryScale = this.geometryScale
            if (this.preGeometryScale < 1) {
              await this.reset()
            }
          }),
        TapGesture({ count: 1 })
          .onAction((event: GestureEvent) => {
            if (event) {
              this.closeDialog()
            }
          })
      )
    )
  }
}
