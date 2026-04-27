import { UploadStatus, UploadedFileInfo } from '../types/DocumentTranslateTypes';
import { DocumentTranslateViewModel } from '../viewmodel/DocumentTranslateViewModel';
import { promptAction } from '@kit.ArkUI';

/**
 * 文档文件列表项组件
 */
@ComponentV2
export struct DocumentTranslateFileItem {
  @Param file: UploadedFileInfo = new UploadedFileInfo();
  @Param viewModel: DocumentTranslateViewModel = new DocumentTranslateViewModel();
  // 用于平滑动画的本地状态
  @Local displayProgress: number = 0;
  @Local displayUploadedBytes: number = 0;
  @Local currentStatus: UploadStatus = UploadStatus.UPLOADING;
  private animationTimer: number = -1;

  aboutToAppear(): void {
    this.currentStatus = this.file.status;
    this.displayUploadedBytes = this.file.uploadedBytes;
    // 如果是上传中状态，启动平滑动画
    if (this.file.status === UploadStatus.UPLOADING) {
      this.startSmoothAnimation();
    }
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  // 启动平滑进度动画
  private startSmoothAnimation(): void {
    this.stopAnimation();
    const totalDuration = 3000; // 3秒完成
    const frameInterval = 50; // 50ms更新一帧
    const totalFrames = totalDuration / frameInterval;
    const progressPerFrame = 100 / totalFrames;
    const bytesPerFrame = this.file.sizeInBytes / totalFrames;

    this.animationTimer = setInterval(() => {
      if (this.currentStatus === UploadStatus.PAUSED) {
        return;
      }
      if (this.displayProgress < 100) {
        this.displayProgress = Math.min(this.displayProgress + progressPerFrame, 100);
        this.displayUploadedBytes = Math.min(this.displayUploadedBytes + bytesPerFrame, this.file.sizeInBytes);
      }
      if (this.displayProgress >= 100) {
        this.stopAnimation();
        this.currentStatus = UploadStatus.COMPLETED;
        this.file.status = UploadStatus.COMPLETED;
        this.file.progress = 100;
        this.file.uploadedBytes = this.file.sizeInBytes;
        this.displayUploadedBytes = this.file.sizeInBytes;
        promptAction.showToast({ message: '上传完成' });
      }
    }, frameInterval);
  }

  private stopAnimation(): void {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  build() {
    Column() {
      Row() {
        // 文件图标
        this.buildFileIcon()

        Column() {
          // 文件名
          Text(this.file.name)
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 进度条
          if (this.currentStatus === UploadStatus.UPLOADING || this.currentStatus === UploadStatus.PAUSED) {
            Progress({ value: this.displayProgress, total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(24)
              .color(this.currentStatus === UploadStatus.PAUSED ?
              $r('sys.color.comp_background_secondary') : $r('sys.color.comp_background_emphasize'))
              .backgroundColor($r('sys.color.comp_background_secondary'))
              .margin({ top: 10 })
          }

          // 根据状态显示不同信息
          if (this.currentStatus === UploadStatus.COMPLETED) {
            Text(this.file.size)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 6 })
          } else if (this.currentStatus === UploadStatus.UPLOADING || this.currentStatus === UploadStatus.PAUSED) {
            Text(`${this.viewModel.formatBytes(Math.floor(this.displayUploadedBytes))}/${this.file.size}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 6 })
          } else if (this.currentStatus === UploadStatus.FAILED) {
            Row() {
              Text('上传失败')
                .fontSize(12)
                .fontColor('#FF4D4F')
            }
            .margin({ top: 6 })
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)

        // 暂停/继续图标按钮
        if (this.currentStatus === UploadStatus.UPLOADING) {
          Image($r('app.media.ic_public_pause'))
            .width(24)
            .height(24)
            .margin({ left: 12 })
            .onClick(() => {
              this.stopAnimation();
              this.currentStatus = UploadStatus.PAUSED;
              this.file.status = UploadStatus.PAUSED;
            })
        } else if (this.currentStatus === UploadStatus.PAUSED) {
          Image($r('app.media.ic_public_play'))
            .width(24)
            .height(24)
            .margin({ left: 12 })
            .onClick(() => {
              this.currentStatus = UploadStatus.UPLOADING;
              this.file.status = UploadStatus.UPLOADING;
              this.startSmoothAnimation();
            })
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  buildFileIcon() {
    if (this.file.name.endsWith('.doc')) {
      Image($r('app.media.ic_doc'))
        .width(32)
        .height(32)
    } else if (this.file.name.endsWith('.docx')) {
      Image($r('app.media.ic_docx'))
        .width(32)
        .height(32)
    } else if (this.file.name.endsWith('.pdf')) {
      Image($r('app.media.ic_pdf'))
        .width(32)
        .height(32)
    }
  }
}
