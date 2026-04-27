import { ComponentContent, LevelMode, window } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';
import { UtilLog } from '@hw-agconnect/util-log';
import sdk from 'libveditor.so';
import { Sticker } from '../model/Sticker';
import { StickerManage } from '../components/StickerManage';
import { TextInputCanvas } from '../components/TextInputCavas';
import { VideoEditVM } from '../viewmodel/VideoEditVM';
import { VideoAsset } from '../model/Index';
import { PromptActionUtil } from '../util/PromptActionUtil';
import { VideoManageVM } from '../viewmodel/VideoManageVM';
import { OperationComponent } from '../components/OperationComponent';
import { VideoControlComponent } from '../components/VideoControlComponent';

@Builder
export function VideoEditBuilder() {
  VideoEdit();
}

@Builder
function videoShare(previewUri: string) {
  Column() {
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.video_back')).size({ width: 40, height: 40 }).onClick(() => {
          PromptActionUtil.closeDialog(shareContentNode);
          VideoManageVM.instance.pathStack.pop(VideoEditVM.instance.draft);
        });
      }.width('100%').justifyContent(FlexAlign.Start);

      Column({ space: 32 }) {
        Image(previewUri).size({ width: 200, height: 260 }).objectFit(ImageFit.Fill);
        Row({ space: 8 }) {
          Image($r('app.media.ic_share')).size({ width: 24, height: 24 });
          Text('点击分享').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_on_primary'));
        }
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        });
      }.width('100%').alignItems(HorizontalAlign.Center).onClick(() => {
        VideoEditVM.instance.share(getUIContext);
      });
    };

    Column({ space: 4 }) {
      Image($r('app.media.ic_house')).size({ width: 24, height: 24 });
      Text('返回首页').fontSize(14).fontColor($r('sys.color.font_primary'));
    }.width('100%').alignItems(HorizontalAlign.Center).onClick(() => {
      PromptActionUtil.closeDialog(shareContentNode);
      VideoManageVM.instance.pathStack.pop(VideoEditVM.instance.draft);
    });
  }
  .padding(16)
  .size({ height: '100%', width: '100%' })
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  .backgroundColor($r('sys.color.background_secondary'))
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.SpaceBetween);
}

@Builder
function stopExport() {
  Column({ space: 16 }) {
    Text('确认停止导出吗？')
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .opacity(0.9);
    Row({ space: 24 }) {
      Button('停止导出')
        .layoutWeight(1)
        .fontColor($r('sys.color.warning'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          PromptActionUtil.closeDialog(stopContentNode);
          VideoEditVM.instance.showExportingBindCover = false;
        });
      Button('继续导出')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .layoutWeight(1)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          PromptActionUtil.closeDialog(stopContentNode);
        });
    };
  }
  .padding(24)
  .borderRadius(32)
  .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
  .width('90%');
}

let getUIContext: UIContext;
let shareContentNode: ComponentContent<Object>;
let stopContentNode: ComponentContent<Object>;

@ComponentV2
struct VideoEdit {
  @Local cloneText: string = '';
  vm: VideoEditVM = VideoEditVM.instance;
  manageVM: VideoManageVM = VideoManageVM.instance;
  private windowClass =
    (this.getUIContext().getHostContext()! as common.UIAbilityContext).windowStage.getMainWindowSync();

  setOrientation(orientation: Orientation) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      UtilLog.info(0xFF00, `VideoClip`, 'setWindowOrientation: ' + orientation + ' Succeeded.');
    }).catch((err: BusinessError) => {
      UtilLog.info(0xFF00, `VideoClip`,
        'setWindowOrientation: ' + orientation + ' Failed. Cause: ' + JSON.stringify(err));
    });
  }

  aboutToAppear(): void {
    this.vm.setUiContext(this.getUIContext());
    this.setOrientation(window.Orientation.PORTRAIT);
    this.vm.totalOutputVideoFilePath =
      `${this.getUIContext().getHostContext()!.filesDir}/merge_${new Date().getTime()}.mp4`;
    getUIContext = this.getUIContext();
    shareContentNode =
      new ComponentContent(getUIContext, wrapBuilder<[string]>(videoShare), this.vm.draft.previewUri!);
    stopContentNode =
      new ComponentContent(getUIContext, wrapBuilder<[]>(stopExport));
  }

  // 组件销毁时清理资源
  aboutToDisappear() {
    this.setOrientation(window.Orientation.UNSPECIFIED);
    this.clearClipMaterial();
  }

  clearClipMaterial() {
    try {
      fs.closeSync(this.manageVM.file);
      this.vm.clearPixelMap();
      this.vm.stickers = [];
    } catch (err) {
      UtilLog.info(0xFF00, 'VideoClip', `close file error: ${JSON.stringify(err)}`);
    }
  }

  showNodeContent(node: ComponentContent<Object>, mode: LevelMode) {
    PromptActionUtil.setContext(getUIContext);
    PromptActionUtil.setContentNode(node);
    PromptActionUtil.setOptions({
      levelMode: mode,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'VideoClip', JSON.stringify(dismissDialogAction.reason));
      },
    });
    PromptActionUtil.openDialog();
  }

  completeCallback(): CallableFunction {
    clearInterval(this.vm.exportInterval);
    return () => {
      this.vm.saveFile(this.getUIContext()).then(() => {
        this.vm.showExportingBindCover = false;
        shareContentNode.update(this.vm.draft.previewUri);
        this.showNodeContent(shareContentNode, LevelMode.EMBEDDED);
        this.vm.getVideoSizeByUri(this.vm.draft.mediaUri, this.getUIContext().getHostContext()!);
        if (!this.manageVM.isMember) {
          this.manageVM.usedCount.count += 1;
        }
      });

      if (this.vm.wordFilePaths.length > 0) {
        this.vm.wordFilePaths.forEach(file => {
          try {
            fs.unlink(file);
            UtilLog.info(0xFF00, 'VideoClip', `delete success!`);
          } catch (err) {
            UtilLog.error(0xFF00, 'VideoClip', `delete fail!`);
          }
        });
      }
    };
  }

  handleSaveButtonClick: SaveButtonCallback =
    async (event: ClickEvent, result: SaveButtonOnClickResult, error?: BusinessError) => {
      if (result === SaveButtonOnClickResult.SUCCESS) {
        try {
          this.vm.showExportingBindCover = true;
          this.vm.exportProgress = 0;
          sdk.Export(this.vm.totalOutputVideoFilePath,
            (progress: number) => {
              this.vm.exportProgress = progress;
            }, this.completeCallback(),
          );
        } catch (error) {
          UtilLog.error(0xFF00, 'VideoClip', `errCode: ${error.code}, errMessage: ${error.message}`);
        }
      } else if (result === SaveButtonOnClickResult.TEMPORARY_AUTHORIZATION_FAILED) {
        UtilLog.error(0xFF00, 'VideoClip', 'errCode: ' + error?.code);
      }
    };

  build() {
    NavDestination() {
      Stack() {
        Column() {
          this.ExportControl();

          this.XComponentLayer();

          VideoControlComponent();

          OperationComponent();
        }.height('100%').justifyContent(FlexAlign.SpaceBetween);

        TextInputCanvas({
          textInfo: this.vm.textInfo,
          isFinish: this.vm.isFinish,
          setImageURI: (filepath: string, wordUri: string) => {
            this.vm.wordUri = wordUri;
            this.vm.isWordFile = true;
            this.vm.wordFilePaths.push(filepath);
          },
        }).offset({ y: -150 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
        this.vm.params.screenWidth = newValue.width;
        this.vm.params.screenHeight = newValue.height;
        // 重新绘制xComponent组件
        this.vm.load(this.getUIContext());
      });
    }.hideTitleBar(true).onReady((ctx) => {
      this.vm.params = ctx.pathInfo.param as VideoAsset;
      this.vm.duration = this.vm.params.screenWidth as number * 0.7;
    });
  }

  @Builder
  ExportControl() {
    Row() {
      Image($r('app.media.video_back')).size({ width: 40, height: 40 }).onClick(() => {
        this.manageVM.pathStack.pop();
      });

      SaveButton({ text: SaveDescription.EXPORT_TO_GALLERY })
        .enabled(!this.vm.durationError)
        .onClick((this.handleSaveButtonClick));
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 16 })
    .padding({ left: 16, right: 16 })
    .bindContentCover($$this.vm.showExportingBindCover, this.FullExportBuilder(), {
      onWillDismiss: (() => {
        if (this.vm.exportProgress) {
          this.getUIContext().getPromptAction().showToast({ message: '视频导出过程中请勿退出', duration: 1000 });
        } else {
          // 进度为0，允许退出
          this.showNodeContent(stopContentNode, LevelMode.OVERLAY);
        }
      }),
    });
  }

  @Builder
  FullExportBuilder() {
    Column() {
      Text('正在努力导出...')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 160, bottom: 12 })
        .fontColor($r('sys.color.font_primary'));
      Text('请保持屏幕点亮，不要锁屏或者退出')
        .margin({ bottom: 30 })
        .fontColor($r('sys.color.font_secondary'));

      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: Math.min(this.vm.exportProgress, 100),
          total: 100,
          type: ProgressType.Ring,
        }).size({ width: 180, height: 180 }).style({ strokeWidth: 10 });

        Text(`${this.vm.exportProgress}%`)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
      };
    }.size({ height: '100%', width: '100%' }).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary')).alignItems(HorizontalAlign.Center);
  }

  @Builder
  XComponentLayer() {
    Column() {
      Stack() {
        ForEach(this.vm.stickers, (sticker: Sticker) => {
          StickerManage({ sticker });
        }, (sticker: Sticker) => sticker.id);

        Stack({ alignContent: Alignment.Center }) {
          XComponent({
            id: '',
            type: XComponentType.SURFACE,
            libraryname: 'veditor',
            controller: this.vm.xComponentController,
          })
            .onLoad(() => {
              this.vm.load(this.getUIContext());
            });
        }
        .zIndex(1);
      };
    }.width('100%').height('65%');
  }
}