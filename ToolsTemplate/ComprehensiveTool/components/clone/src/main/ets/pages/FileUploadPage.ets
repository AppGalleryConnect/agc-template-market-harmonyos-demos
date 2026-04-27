import { common } from '@kit.AbilityKit';
import { FileUploadPageVM } from '../viewmodel/FileUploadPageVM';
import { ContentBlock } from '../components/ContentBlock';
import { sendFile } from '../service/FileSendService';
import { TcpClient } from '../service/TcpClient';
import { FileType, TransferState } from '../common/Constant';
import { getInstance } from '../common/CommonRoute';
import { TransferSuccess } from '../components/TransferSuccess';
import { TransferError } from '../components/TransferError';
import { fileSaveService } from '../service/FileSaveService';
import { CloneFile } from '../model/WorkerMessage';

@ComponentV2
export struct FileUploadPage {
  vm: FileUploadPageVM = FileUploadPageVM.instance
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext

  aboutToAppear(): void {
    this.vm.clear()
    this.vm.context = this.context
    fileSaveService.getCloneFile(this.context)
    this.vm.getCloneFiles(this.getUIContext())
    fileSaveService.onCloneFile = (cloneFile: CloneFile) => {
      this.vm.image.list = cloneFile.image.list
      this.vm.image.size = cloneFile.image.size
      this.vm.image.fileSize = cloneFile.image.fileSize
      this.vm.video.list = cloneFile.video.list
      this.vm.video.size = cloneFile.video.size
      this.vm.video.fileSize = cloneFile.video.fileSize
      this.vm.isLoading = false
      this.vm.handleSendFileCount()
    }
    TcpClient.onStart = (type) => {
      if (type === FileType.CONTACT) {
        this.vm.contact.count = this.vm.contact.size
        this.vm.contact.recvSize = 100
        this.vm.contact.state = TransferState.AFTER
      } else if (type === FileType.IMAGE) {
        this.vm.image.count += 1
      } else if (type === FileType.VIDEO) {
        this.vm.video.count += 1
      }
      this.vm.checkIsTransferAll()
    }
    TcpClient.onProgress = (data) => {
      if (data.type === FileType.IMAGE) {
        this.vm.image.recvSize += data.progress
        if (this.vm.image.recvSize === this.vm.image.fileSize) {
          this.vm.image.state = TransferState.AFTER
        }
      } else if (data.type === FileType.VIDEO) {
        this.vm.video.recvSize += data.progress
        if (this.vm.video.recvSize === this.vm.video.fileSize) {
          this.vm.video.state = TransferState.AFTER
        }
      }
      this.vm.checkIsTransferAll()
    }
    TcpClient.onEnd = async () => {
      this.vm.sendCount += 1
      await sendFile(this.vm.selectedFiles[this.vm.sendCount])
    }
  }

  aboutToDisappear(): void {
    this.vm.clear()
    TcpClient.close()
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            Column() {
              if (this.vm.contact.size !== 0) {
                ContentBlock({
                  title: '联系人',
                  mainFile: this.vm.contact,
                  img: $r('app.media.clone_contact'),
                  onChange: (value) => {
                    this.vm.contact.isSelected = value
                    this.vm.handleSendFileCount()
                  },
                })
              }

              if (this.vm.image.size !== 0) {
                ContentBlock({
                  title: '图片',
                  mainFile: this.vm.image,
                  img: $r('app.media.clone_image'),
                  onChange: (value) => {
                    this.vm.image.isSelected = value
                    this.vm.handleSendFileCount()
                  },
                })
              }

              if (this.vm.video.size !== 0) {
                ContentBlock({
                  title: '视频',
                  mainFile: this.vm.video,
                  img: $r('app.media.clone_video'),
                  onChange: (value) => {
                    this.vm.video.isSelected = value
                    this.vm.handleSendFileCount()
                  },
                })
              }

              if (this.vm.totalState === TransferState.AFTER) {
                TransferSuccess()
              }

              if (this.vm.totalState === TransferState.ERROR) {
                TransferError()
              }
            }
            .height(`calc(100% - 56vp)`)

            if (this.vm.totalState === TransferState.BEFORE) {
              Button('开始发送')
                .width('100%')
                .onClick(() => {
                  this.vm.uploadFile()
                })
            } else if (this.vm.totalState === TransferState.AFTER || this.vm.totalState === TransferState.ERROR) {
              Button('完成')
                .width('100%')
                .onClick(() => {
                  getInstance().pop()
                  this.vm.clear()
                })
            }
          }

          if (this.vm.isLoading) {
            Column() {
              LoadingProgress()
                .width(72)
                .height(72)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })

    }
    .title('选择要发送的资料')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function FileUploadPageBuilder() {
  FileUploadPage()
}