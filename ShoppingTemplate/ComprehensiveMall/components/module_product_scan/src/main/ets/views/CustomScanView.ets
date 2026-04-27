import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode } from '@kit.ScanKit';
import { CommonSymbol, Logger, SafeJson } from 'module_ui_base';
import { TabIndexMap } from '../commons/Constants';
import { CustomScanOptions } from '../commons/Types';
import { CameraUtil } from '../utils/CameraUtil';
import { CustomScanVM } from '../viewmodels/CustomScanVM';

const TAG: string = '[CustomScan]';

@Builder
export function buildCustomScanView() {
  CustomScanView()
}

@ComponentV2
export struct CustomScanView {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  userGrant: boolean = false
  @Local
  release: boolean = false
  @Local
  currentIndex: number = TabIndexMap.SCAN
  @Local
  curWindow?: window.Window
  @Local
  options?: CustomScanOptions
  vm: CustomScanVM = new CustomScanVM(this.getUIContext())

  @Monitor('userGrant', 'options')
  async init() {
    if (this.userGrant) {
      this.vm.init(this.options)
    }
  }

  @Monitor('currentIndex', 'release')
  async releaseScan() {
    // 页面消失或隐藏时，停止并释放相机流
    if (this.release) {
      if (this.currentIndex === TabIndexMap.SCAN) {
        await this.vm.releaseScan()
      } else {
        await CameraUtil.releaseCamera()
      }
    } else {
      if (this.currentIndex === TabIndexMap.SCAN) {
        this.vm.initScan()
      } else {
        this.vm.initCamera()
      }
    }
  }

  build() {
    NavDestination() {
      Stack() {
        if (this.userGrant) {
          XComponent({
            id: 'customCamera',
            type: XComponentType.SURFACE,
            controller: this.vm.mXComponentController,
          })
            .onLoad(async () => {
              this.vm.loadXComponentData()
            })
            .width(this.vm.cameraWidth)
            .height(this.vm.cameraHeight)
        }

        this.buildOverlay()

        // 单码、多码扫描后，显示码图蓝点位置。点击toast码图信息
        if (this.vm.scanResult.length > 1) {
          Stack() {
            ForEach(this.vm.scanResult, (item: scanBarcode.ScanResult) => {
              if (item.scanCodeRect) {
                SymbolGlyph($r('sys.symbol.smallcircle_filled_circle'))
                  .fontSize(24)
                  .fontWeight(FontWeight.Bolder)
                  .fontColor([$r('app.color.theme_color')])
                  .width(40)
                  .height(40)
                  .markAnchor({ x: 20, y: 20 })
                  .position({
                    x: (item.scanCodeRect.left + item?.scanCodeRect?.right) / 2,
                    y: (item.scanCodeRect.top + item?.scanCodeRect?.bottom) / 2,
                  })
                  .onClick(() => {
                    this.vm.handleScanResult(item.originalValue)
                  })
              }
            }, (item: scanBarcode.ScanResult) => '' + item?.scanCodeRect?.left + item?.scanCodeRect?.right + 'px')
          }
          .width($r('app.string.size_percent_full'))
          .height($r('app.string.size_percent_full'))
          .backgroundColor($r('app.color.font_color_level3'))
        }
      }
      .width('100%')
      .height('100%')
      .onClick((event: ClickEvent) => {
        this.vm.handleMultiScanStart(event)
      }).gesture(PinchGesture({ fingers: 2 })
        .onActionUpdate((event: GestureEvent) => {
          if (event) {
            this.vm.scaleValue = event.scale;
          }
        })
        .onActionEnd(() => {
          this.vm.handleMultiScanResult()
        }))
    }
    .hideTitleBar(true)
    .onReady((context) => {
      this.stack = context.pathStack
      this.options = context.pathInfo.param as CustomScanOptions
    })
    .onShown(async () => {
      window.getLastWindow(this.getUIContext().getHostContext())
        .then((win) => {
          this.curWindow = win;
          this.curWindow.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
            Logger.info(TAG, 'set full screen failed. error: ' + SafeJson.jsonStringify(err))
          })
        })
        .catch((err: BusinessError) => {
          Logger.info(TAG, 'get last window failed. error: ' + SafeJson.jsonStringify(err))
        })
      this.release = false;
      await this.requestCameraPermission();
      if (!this.userGrant) {
        Logger.info(TAG, 'no camera permission')
        return
      }
    })
    .onHidden(() => {
      this.release = true
      if (this.curWindow) {
        this.curWindow.setWindowLayoutFullScreen(false).catch((err: BusinessError) => {
          Logger.info(TAG, 'set full screen failed. error: ' + SafeJson.jsonStringify(err))
        })
      }
    })
  }

  @Builder
  buildOverlay() {
    Column() {
      if (this.stack?.size?.() > 0) {
        CommonSymbol({
          src: $r('sys.symbol.chevron_left'),
          color: Color.White,
        })
          .onClick(() => {
            if (this.currentIndex === TabIndexMap.CAMERA && this.vm.cameraResult) {
              this.vm.initCamera()
            } else if (this.currentIndex === TabIndexMap.SCAN && this.vm.scanResult.length) {
              this.vm.initScan()
            } else {
              this.stack.pop()
            }
          })
          .margin({ top: $r('app.float.space_xl') })
      }

      Blank()

      Text(this.currentIndex === 0 ? '扫描二维码或条形码' : '对准商品，拍照识别')
        .fontColor($r('app.color.font_color_level1_invert'))
        .width($r('app.string.size_percent_full'))
        .textAlign(TextAlign.Center)

      Row({ space: 24 }) {
        Column() {
          this.buildSymbolButton($r('sys.symbol.flashlight_off'), '闪光灯')
        }
        .visibility((this.userGrant && this.currentIndex === TabIndexMap.SCAN) ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.vm.handleFlashLightChange()
        })

        Image($r('app.media.ic_camera_btn'))
          .onClick(async () => await CameraUtil.takePicture())
          .height(68)
          .width(68)
          .visibility(this.currentIndex === 1 ? Visibility.Visible : Visibility.Hidden)

        Column() {
          this.buildSymbolButton($r('sys.symbol.picture_2'), '相册')
        }
        .visibility(this.options?.enableAlbum ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.vm.getPicFromAlbum(this.currentIndex)
        })
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceAround)
      .margin({
        bottom: $r('app.float.space_xl'),
        top: $r('app.float.space_xl'),
      })

      Tabs() {
        TabContent() {
        }
        .tabBar(new SubTabBarStyle('扫码')
          .labelStyle({ unselectedColor: $r('app.color.font_color_level2_invert'), selectedColor: Color.White }))

        TabContent() {
        }
        .tabBar(new SubTabBarStyle('识图')
          .labelStyle({ unselectedColor: $r('app.color.font_color_level2_invert'), selectedColor: Color.White }))
      }
      .barPosition(BarPosition.End)
      .onChange(async (index: number) => {
        this.currentIndex = index
      })
      .height(60)

    }
    .width($r('app.string.size_percent_full'))
    .height($r('app.string.size_percent_full'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .padding($r('app.float.space_l'))
  }

  @Builder
  buildSymbolButton(src: Resource, label: string) {
    Row() {
      SymbolGlyph(src)
        .fontSize(32)
        .fontColor([$r('app.color.font_color_level1_invert')])
    }
    .backgroundColor($r('app.color.background_color_button_grey'))
    .height(48)
    .width(48)
    .borderRadius(24)
    .margin({ bottom: $r('app.float.space_xs') })
    .justifyContent(FlexAlign.Center)

    Text(label)
      .fontColor($r('app.color.font_color_level1_invert'))
      .fontSize($r('app.float.font_size_12'))
  }

  async requestCameraPermission() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
      if (grantStatus.authResults[0] === 0) {
        this.userGrant = true;
      } else {
        this.stack.pop()
      }
    } catch (err) {
      Logger.error(TAG, 'request permission failed. error:' + JSON.stringify(err))
    }
  }
}