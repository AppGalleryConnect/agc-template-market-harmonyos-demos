import { FileVo } from '../model/FileVo';
import { ContentBlock } from '../components/ContentBlock';
import { FileCountMessage } from '../model/BinaryProtocol';
import { FileReceiverPageVM } from '../viewmodel/FileReceiverPageVM';
import { FileType, TransferState, TransferType } from '../common/Constant';
import { TransferSuccess } from '../components/TransferSuccess';
import { TransferError } from '../components/TransferError';
import { getInstance } from '../common/CommonRoute';
import { TcpServer } from '../service/TcpServer';

@ComponentV2
struct FileReceiverPage {
  vm: FileReceiverPageVM = FileReceiverPageVM.instance

  aboutToAppear(): void {
    this.vm.clear()
    TcpServer.fileTransCallback = {
      onBefore: (fileCount: FileCountMessage) => {
        this.vm.handleTransmittedData(fileCount)
      },
      onStart: (fileType) => {
        switch (fileType) {
          case FileType.CONTACT:
            this.vm.contact.state = TransferState.MIDDLE
            this.vm.contact.count = this.vm.contact.size
            break
          case FileType.IMAGE:
            this.vm.image.state = TransferState.MIDDLE
            this.vm.image.count += 1
            break
          case FileType.VIDEO:
            this.vm.video.state = TransferState.MIDDLE
            this.vm.video.count += 1
            break
        }
      },
      onProgress: (fileVo: FileVo, progress: number) => {
        switch (fileVo.type) {
          case FileType.CONTACT:
            this.vm.contact.recvSize = 100
            this.vm.contact.count = this.vm.contact.size
            this.vm.contact.state = TransferState.AFTER
            break
          case FileType.IMAGE:
            this.vm.image.recvSize += progress
            if (this.vm.image.recvSize === this.vm.image.fileSize) {
              this.vm.image.state = TransferState.AFTER
            }
            break
          case FileType.VIDEO:
            this.vm.video.recvSize += progress
            if (this.vm.video.recvSize === this.vm.video.fileSize) {
              this.vm.video.state = TransferState.AFTER
            }
        }
      },
      onComplete: async (fileVo: FileVo, fileData?: ArrayBuffer) => {
        this.vm.checkIsTransferAll()
      },
    }
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          if (this.vm.contact.isSelected && this.vm.contact.size !== 0) {
            ContentBlock({
              type: TransferType.Receive,
              title: '联系人',
              mainFile: this.vm.contact,
              img: $r('app.media.clone_contact'),
            })
          }

          if (this.vm.image.isSelected && this.vm.image.size !== 0) {
            ContentBlock({
              type: TransferType.Receive,
              title: '图片',
              mainFile: this.vm.image,
              img: $r('app.media.clone_image'),
            })
          }

          if (this.vm.video.isSelected && this.vm.video.size !== 0) {
            ContentBlock({
              type: TransferType.Receive,
              title: '视频',
              mainFile: this.vm.video,
              img: $r('app.media.clone_video'),
            })
          }

          if (this.vm.state === TransferState.AFTER) {
            TransferSuccess()
          }

          if (this.vm.state === TransferState.ERROR) {
            TransferError()
          }
        }
        .height(`calc(100% - 56vp)`)

        if (this.vm.state === TransferState.AFTER || this.vm.state === TransferState.ERROR) {
          Button('完成')
            .width('100%')
            .onClick(() => {
              getInstance().pop()
            })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('接收的资料')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function FileReceiverPageBuilder() {
  FileReceiverPage();
}