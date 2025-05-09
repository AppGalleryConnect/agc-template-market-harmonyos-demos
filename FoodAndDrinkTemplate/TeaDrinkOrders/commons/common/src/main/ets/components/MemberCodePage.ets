import { Constants } from '../constants/Common';
import { UserIconModel, UserInfoModel } from '../models/StorageModel';
import { NavHeaderBar } from './NavHeaderBar';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';

@Builder
export function MemberCodePageBuilder() {
  MemberCodePage()
}

@ComponentV2
export struct MemberCodePage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local userIconInfo: UserIconModel = PersistenceV2.connect(UserIconModel, () => new UserIconModel())!;
  @Local qrcodeUrl: string = this.userInfo.userInfo.id + new Date().getTime()

  @Computed
  get avatarUri(): string {
    return `file://${getContext().filesDir}/${this.userIconInfo.userIconPath}`
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.memberCode') })
      Column() {
        Column({ space: 24 }) {
          Row() {
            Image(this.userIconInfo.isSaved ? this.avatarUri : $r('app.media.ic_user_img'))
              .width(40)
              .height(40)
              .borderRadius(50)
            Text($r('app.string.memberAccount')).fontSize(14).fontColor($r('sys.color.white')).margin({ left: 12 })
            Text(this.userInfo.getTel()).fontSize(14).fontColor($r('sys.color.white'))
          }
          .width(Constants.FULL_SIZE)
          .backgroundColor($r('sys.color.black'))
          .padding({ top: 8, bottom: 8 })
          .justifyContent(FlexAlign.Center)

          Column() {
            QRCode(this.qrcodeUrl).width(206).height(206)
          }.padding(17)

          Row() {
            Image($r('app.media.ic_refresh')).width(16).height(16)
            Text($r('app.string.refresh')).fontSize(14).fontColor('#0A59F7').margin({ left: 4 })
          }.justifyContent(FlexAlign.Center).onClick(()=>{
            this.qrcodeUrl = this.userInfo.userInfo.id + new Date().getTime()
          })

          Row() {
          }.width(Constants.FULL_SIZE).height(27).backgroundColor($r('sys.color.black'))
        }
        .width(Constants.FULL_SIZE)
        .borderRadius(16)
        .clip(true)
        .margin({ top: 24 })
        .backgroundColor($r('sys.color.background_primary'))
      }
      .width(Constants.FULL_SIZE)
      .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .backgroundColor('#F1F3F5')
    }.hideTitleBar(true)
  }
}

// 进场过程中会逐帧触发onEnter回调，入参为动效的归一化进度(0% -- 100
@ComponentV2
struct ImageComponent {
  @Param image: ResourceStr = ''
  private preGeometryScale: number = 1
  @Local geometryScale: number = 1
  @Local geometryOffsetX: number = 0
  @Local geometryOffsetY: number = 0
  @Local imageWidth: number = 0
  @Local imageHeight: number = 0
  @Param viewWidth: number = 0
  @Event closeDialog: () => void = () => {
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
      Image(this.image)
        .onComplete((e) => {
          this.imageWidth = (e?.width || 0)
          this.imageHeight = (e?.height || 0)
        })
        .objectFit(ImageFit.Cover)
        .width(this.imageWidth + 'px')
        .height(this.imageHeight + 'px')
        .scale({
          x: this.geometryScale,
          y: this.geometryScale,
        })
        .offset({
          x: this.geometryOffsetX,
          y: this.geometryOffsetY,
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
          }),
      ),
    )
  }
}
