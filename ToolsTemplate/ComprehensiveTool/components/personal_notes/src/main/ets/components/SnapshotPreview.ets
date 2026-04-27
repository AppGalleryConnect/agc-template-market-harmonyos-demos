import { UtilLog } from '@hw-agconnect/util-log';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { PopupUtils } from '../utils/PopupUtils';

@ComponentV2
export struct SnapshotPreview {
  @Local snapPopupWidth: number = 100;
  @Local snapPopupHeight: number = 200;
  @Param snapPopupPosition: Position | undefined = undefined;
  @Event changeSnapPopupPosition:(snapPopupPosition:Position | undefined) => void;
  @Param isShowPreview: boolean = false;
  @Event changeIsShowPreview:(showPreview: boolean) => void;
  @Param isLargePreview: boolean = false;
  @Event changeIsLargePreview:(largePreview: boolean) => void;
  @Param mergedImage: PixelMap | undefined = undefined;
  @Event changeMergedImage:(mergedImage:PixelMap | undefined) => void;
  private context: Context = this.getUIContext().getHostContext()!;
  private xPositionBefore: number = 0;
  private panOption: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left,
    distance: 5
  });

  @Local screenWidth: number = AppStorage.get('screenWidth') || 0;
  @Local screenHeight: number = AppStorage.get('screenHeight') || 0;

  @Monitor('screenWidth')
  onDisplayWidthChange(displayWidth: number): void {
    if (this.isLargePreview) {
      this.snapPopupHeight = 580;
      this.snapPopupWidth = this.screenWidth - 32;
      const snapPopupPosition =
        PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, this.snapPopupWidth, this.snapPopupHeight);
      this.changeSnapPopupPosition(snapPopupPosition)
    }
  }

  closeSnapPopup(): void {
    this.changeIsShowPreview(false)
    this.changeMergedImage(undefined);
    this.snapPopupWidth = 100;
    this.snapPopupHeight = 200;
    const snapPopupPosition =
      PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, this.snapPopupWidth, this.snapPopupHeight);
    this.changeSnapPopupPosition(snapPopupPosition)
    this.changeIsLargePreview(false)
  }

  async saveSnapshot(result: SaveButtonOnClickResult): Promise<void> {
    if (result === SaveButtonOnClickResult.SUCCESS) {
      try {
        const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
        const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
        const file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        const imagePackerApi: image.ImagePacker = image.createImagePacker();
        const packOpts: image.PackingOption = {
          format: 'image/png',
          quality: 100,
        };
        imagePackerApi.packToData(this.mergedImage, packOpts).then(async (data) => {
          fileIo.writeSync(file.fd, data);
          fileIo.closeSync(file.fd);
          this.getUIContext().getPromptAction().showToast({
            message: '已保存至相册',
            duration: 1800
          })
          const imgName = `${Date.now()}.png`;
          const img =
            fileIo.openSync(this.context.filesDir + `/${imgName}`, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          await fileIo.write(img.fd, data)
          // 关闭文档
          await fileIo.close(img.fd)

          this.setShareData(imgName)
        }).catch((error: BusinessError) => {
        });
      } catch (e) {
        UtilLog.error(`saveSnapshot failed with error ${e}`)
      }
    }
    this.closeSnapPopup();
  }

  setShareData(fileName: string) {
    // 构造ShareData，需配置一条有效数据信息
    const contextFaker: Context = this.getUIContext().getHostContext()!;
    let filePath = contextFaker.filesDir + `/${fileName}`;
    // 获取精准的utd类型
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.png', utd.UniformDataType.IMAGE);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: '图片标题', // 不传title字段时,显示图片文件名
      description: '图片描述', // 不传description字段时,显示图片大小
    });

    // 进行分享面板显示
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      console.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
  }

  @Builder
  previewWindow() {
    Column() {
      this.previewSnapshot();
      if (this.isLargePreview) {
        this.buttonBar();
      }
    }
    .backgroundColor(Color.White)
    .width(this.snapPopupWidth)
    .height(this.snapPopupHeight)
    .position(this.snapPopupPosition)
    .borderRadius(this.isLargePreview ? 32 : 0)
    .animation({
      duration: 500,
      curve: Curve.Linear
    })
    .gesture(
      PanGesture(this.panOption)
        .onActionStart(() => {
          this.xPositionBefore = this.snapPopupPosition?.x as number;
        })
        .onActionUpdate((event) => {
          if (event.offsetX < 30 && this.snapPopupPosition) {
            this.snapPopupPosition.x = this.xPositionBefore + event.offsetX;
          }
        })
        .onActionEnd((event) => {
          if (event.offsetX < -30) {
            this.getUIContext().animateTo({
              duration: 500,
              curve: Curve.Ease,
              onFinish: () => {
                this.changeIsShowPreview(false);
              }
            }, () => {
              this.snapPopupPosition && (this.snapPopupPosition.x = -150);
              this.changeSnapPopupPosition( this.snapPopupPosition)
            })
          } else {
            const snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenWidth, this.screenHeight)
            this.changeSnapPopupPosition(snapPopupPosition)
          }
        })
    )
    .onGestureJudgeBegin((gestureInfo: GestureInfo) => {
      if (gestureInfo.type === GestureControl.GestureType.PAN_GESTURE && this.isLargePreview) {
        return GestureJudgeResult.REJECT;
      }
      return GestureJudgeResult.CONTINUE;
    })
  }

  @Builder
  previewSnapshot() {
    Scroll() {
      Column() {
        Image(this.mergedImage)
          .objectFit(ImageFit.Fill)
          .width('100%')
      }
      .borderWidth(5)
      .borderColor('#F1F3F5')
    }
    .borderRadius(this.isLargePreview ? 32 : 0)
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .backgroundColor(Color.White)
    .padding({
      top: this.isLargePreview ? 24 : 0,
      left: this.isLargePreview ? 24 : 0,
      right: this.isLargePreview ? 24 : 0
    })
    .onClick(() => {
      if (!this.isLargePreview) {
        this.getUIContext().animateTo({
          duration: 500,
          curve: Curve.Ease,
          onFinish: () => {
            this.changeIsLargePreview(true);
          }
        }, () => {
          this.snapPopupWidth = this.screenWidth - 32;
          this.snapPopupHeight = 580;
          const snapPopupPosition =
            PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, this.snapPopupWidth,
              this.snapPopupHeight)
          this.changeSnapPopupPosition(snapPopupPosition)
        })
      }
    })
  }

  @Builder
  buttonBar() {
    Row({ space: 16 }) {
      Button('取消')
        .width('calc(50% - 24vp)')
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          this.closeSnapPopup();
        })
      SaveButton({
        icon: SaveIconStyle.FULL_FILLED,
        text: SaveDescription.DOWNLOAD_AND_SHARE,
        buttonType: ButtonType.Capsule
      })
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.font_emphasize'))
        .iconColor($r('sys.color.font_emphasize'))
        .width('calc(50% - 24vp)')
        .height(40)
        .fontSize(16)
        .onClick((event, result) => {
          this.saveSnapshot(result);
        })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({
      top: 8,
      bottom: 24
    })
  }

  build() {
    Column() {
      if (this.mergedImage) {
        this.previewWindow();
      } else {
        Text('正在截图，请稍等...')
          .backgroundColor(Color.White)
          .textAlign(TextAlign.Center)
          .borderRadius(12)
          .padding(12)
          .width(120)
          .height(80)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_mask_thin'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  }
}