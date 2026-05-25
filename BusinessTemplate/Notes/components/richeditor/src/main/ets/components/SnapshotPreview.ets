/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { promptAction, window } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';



import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { PopupUtils } from '../utils/PopupUtils';

const TAG: string = '[SnapshotPreview]';

interface SnapshotViewportInsets {
  insetTopVp: number;
  insetBottomVp: number;
}

/**
 * Long screenshot preview pop-up component
 */
@ComponentV2
export struct SnapshotPreview {
  @Local snapPopupWidth: number = 100;
  @Local snapPopupHeight: number = 200;
  // The position of the preview window after taking a screenshot
  @Param snapPopupPosition: Position | undefined = undefined;
  @Event changeSnapPopupPosition:(snapPopupPosition:Position | undefined) => void;
  // Whether to display the screenshot preview pop-up window
  @Param isShowPreview: boolean = false;
  @Event changeIsShowPreview:(showPreview: boolean) => void;
  // Whether to display the screenshot preview pop-up window in large mode
  @Param isLargePreview: boolean = false;
  @Event changeIsLargePreview:(largePreview: boolean) => void;
  // The image generated after taking a screenshot
  @Param mergedImage: PixelMap | undefined = undefined;
  @Event changeMergedImage:(mergedImage:PixelMap | undefined) => void;
  @Param @Require context: Context ;
  // Saves the position information before sliding
  private xPositionBefore: number = 0;
  // Pan to the left gesture
  private panOption: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left,
    distance: 5
  });

  @Local screenWidth: number = AppStorage.get('screenWidth') || 0;
  @Local screenHeight: number = AppStorage.get('screenHeight') || 0;

  aboutToAppear(): void {
    this.refreshScreenFromWindow();
  }

  private refreshScreenFromWindow(): SnapshotViewportInsets {
    let insetTopVp = 0;
    let insetBottomVp = 0;
    try {
      const host = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const win = host?.windowStage?.getMainWindowSync();
      if (win) {
        const rect = win.getWindowProperties().windowRect;
        this.screenWidth = this.getUIContext().px2vp(rect.width);
        this.screenHeight = this.getUIContext().px2vp(rect.height);
        const sys = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        insetTopVp = this.getUIContext().px2vp(sys.topRect.height);
        insetBottomVp = this.getUIContext().px2vp(sys.bottomRect.height);
      }
    } catch (_e) {
    }
    const w = AppStorage.get<number>('screenWidth');
    const h = AppStorage.get<number>('screenHeight');
    if (typeof w === 'number' && w > 0) {
      this.screenWidth = w;
    }
    if (typeof h === 'number' && h > 0) {
      this.screenHeight = h;
    }
    const result: SnapshotViewportInsets = { insetTopVp: insetTopVp, insetBottomVp: insetBottomVp };
    return result;
  }

  private calcLargePreviewPosition(): Position {
    const viewportInsets: SnapshotViewportInsets = this.refreshScreenFromWindow();
    this.snapPopupHeight = 580;
    this.snapPopupWidth = this.screenWidth - 32;
    return PopupUtils.calcPopupCenterInSafeArea(
      this.screenWidth,
      this.screenHeight,
      this.snapPopupWidth,
      this.snapPopupHeight,
      viewportInsets.insetTopVp,
      viewportInsets.insetBottomVp,
    );
  }

  @Monitor('screenWidth')
  onDisplayWidthChange(_displayWidth: number): void {
    if (this.isLargePreview) {
      const snapPopupPosition = this.calcLargePreviewPosition();
      this.changeSnapPopupPosition(snapPopupPosition);
    }
  }

  /**
   * Close the screenshot pop-up window and restore the status.
   */
  closeSnapPopup(): void {
    // Close the modal window
    this.changeIsShowPreview(false)
    // Clear long screenshots of the merge
    this.changeMergedImage(undefined);
    // Restore window size
    this.snapPopupWidth = 100;
    this.snapPopupHeight = 200;
    //  The window position is reset centered
    const snapPopupPosition =
      PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, this.snapPopupWidth, this.snapPopupHeight);
    this.changeSnapPopupPosition(snapPopupPosition)
    // Revert to small window mode
    this.changeIsLargePreview(false)
  }

  /**
   * Save the picture to the album
   * @param {SaveButtonOnClickResult} result - The security control returns the result
   */
  // [Start save_snapshot]
  async saveSnapshot(result: SaveButtonOnClickResult): Promise<void> {
    if (result === SaveButtonOnClickResult.SUCCESS) {
      try {
        const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
        const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
        // Open the file with a URI to write content continuously
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
          hilog.error(0x0000, TAG, `packToData failed: ${error.code} ${error.message}`);
        });
      } catch (e) {
        const err = e as BusinessError;
        hilog.error(0x0000, TAG, `saveSnapshot failed: ${err.code} ${err.message}`);
        try {
          this.getUIContext().getPromptAction().showToast({
            message: '保存失败',
            duration: 1800,
          });
        } catch (_t) {
        }
      }
    }
    this.closeSnapPopup();
  }
  // [End save_snapshot]

  setShareData(fileName: string) {
    // 构造ShareData，需配置一条有效数据信息
    let filePath = this.context.filesDir + `/${fileName}`; // 仅为示例 请替换正确的文件路径
    // 获取精准的utd类型
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.png', utd.UniformDataType.IMAGE);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: '图片标题', // 不传title字段时,显示图片文件名
      description: '图片描述', // 不传description字段时,显示图片大小
      // thumbnail: new Uint8Array() // 优先使用传递的缩略图预览  不传则默认使用原图做预览图
    });

    // 进行分享面板显示
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    controller.show(this.context as common.UIAbilityContext, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      hilog.info(0x0000, TAG, 'ShareController show success.');
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, `ShareController show error. code: ${error.code}, message: ${error.message}`);
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
          // The left slide pop-up window closes, but allows a small part to be swiped to the right to create an
          // elastic effect and improve the operating feel
          if (event.offsetX < 30 && this.snapPopupPosition) {
            this.snapPopupPosition.x = this.xPositionBefore + event.offsetX;
          }
        })
        .onActionEnd((event) => {
          // Swipe left will trigger a pop-up window when it exceeds a certain threshold, improving user experience
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
            const snapPopupPosition =
              PopupUtils.calcPopupBottomLeft(this.screenHeight, this.snapPopupHeight);
            this.changeSnapPopupPosition(snapPopupPosition);
          }
        })
    )
    .onGestureJudgeBegin((gestureInfo: GestureInfo) => {
      // Mask the panning event when previewing the image
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
      // Click to enlarge the preview窗口：在安全内容区内水平垂直居中
      if (!this.isLargePreview) {
        this.getUIContext().animateTo({
          duration: 500,
          curve: Curve.Ease,
          onFinish: () => {
            this.changeIsLargePreview(true);
          }
        }, () => {
          const snapPopupPosition = this.calcLargePreviewPosition();
          this.changeSnapPopupPosition(snapPopupPosition);
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
      // [Start Save_button]
      SaveButton({
        icon: SaveIconStyle.FULL_FILLED,
        text: SaveDescription.DOWNLOAD_AND_SHARE,
        buttonType: ButtonType.Capsule
      })
      // [StartExclude Save_button]
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.font_emphasize'))
        .iconColor($r('sys.color.font_emphasize'))
        .width('calc(50% - 24vp)')
        .height(40)
        .fontSize(16)
        // [EndExclude Save_button]
        .onClick((event, result) => {
          this.saveSnapshot(result);
        })
      // [End Save_button]
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
      // The preview pane is displayed after the build
      if (this.mergedImage) {
        this.previewWindow();
      } else {
        // A pop-up window in the screenshot prompts
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
  }
}