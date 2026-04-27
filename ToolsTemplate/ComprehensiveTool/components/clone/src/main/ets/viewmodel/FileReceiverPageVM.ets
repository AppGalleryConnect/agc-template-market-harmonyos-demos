import { MainFile, TransferState } from '../common/Constant';
import { FileCountMessage } from '../model/BinaryProtocol';

@ObservedV2
export class FileReceiverPageVM {
  private static _instance: FileReceiverPageVM
  @Trace contact: MainFile = new MainFile()
  @Trace image: MainFile = new MainFile()
  @Trace video: MainFile = new MainFile()
  @Trace state: TransferState = TransferState.BEFORE

  public static get instance() {
    if (!FileReceiverPageVM._instance) {
      FileReceiverPageVM._instance = new FileReceiverPageVM();
    }
    return FileReceiverPageVM._instance;
  }

  clear() {
    this.contact = new MainFile()
    this.image = new MainFile()
    this.video = new MainFile()
    this.state = TransferState.BEFORE
  }

  handleTransmittedData(fileCount: FileCountMessage) {
    this.contact.isSelected = fileCount.contact.isSelected
    this.contact.size = fileCount.contact.size
    this.contact.fileSize = fileCount.contact.fileSize
    this.contact.list = fileCount.contact.list
    this.image.isSelected = fileCount.image.isSelected
    this.image.size = fileCount.image.size
    this.image.fileSize = fileCount.image.fileSize
    this.image.list = fileCount.image.list
    this.video.isSelected = fileCount.video.isSelected
    this.video.size = fileCount.video.size
    this.video.fileSize = fileCount.video.fileSize
    this.video.list = fileCount.video.list
    if (!this.image.isSelected) {
      this.image.fileSize = 0
      this.image.recvSize = 0
    }
    if (!this.video.isSelected) {
      this.video.fileSize = 0
      this.video.recvSize = 0
    }
  }

  checkIsTransferAll() {
    if (this.image.recvSize === this.image.fileSize && this.video.recvSize === this.video.fileSize) {
      this.state = TransferState.AFTER
    }
  }
}
