import { FileVo } from '../model/FileVo';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { FileBasic, FileType, MainFile, TransferState } from '../common/Constant';
import { common } from '@kit.AbilityKit';
import { contact } from '@kit.ContactsKit';
import { sendFile, sendFileCount } from '../service/FileSendService';
import { TcpClient } from '../service/TcpClient';
import { fileUri } from '@kit.CoreFileKit';

@ObservedV2
export class FileUploadPageVM {
  private static _instance: FileUploadPageVM
  @Trace context: common.UIAbilityContext | null = null
  @Trace selectedFiles: FileVo[] = [] // 已选文件列表
  @Trace contactList: contact.Contact[] = []
  @Trace contact: MainFile = new MainFile()
  @Trace image: MainFile = new MainFile()
  @Trace video: MainFile = new MainFile()
  @Trace totalState: TransferState = TransferState.BEFORE
  @Trace timer: number = 0
  @Trace sendCount: number = 0
  @Trace isLoading: boolean = true

  public static get instance() {
    if (!FileUploadPageVM._instance) {
      FileUploadPageVM._instance = new FileUploadPageVM();
    }
    return FileUploadPageVM._instance;
  }

  clear() {
    this.selectedFiles = []
    this.contactList = []
    this.contact = new MainFile()
    this.image = new MainFile()
    this.video = new MainFile()
    this.totalState = TransferState.BEFORE
    this.sendCount = 0
    clearInterval(this.timer)
  }

  // 获取联系人数据
  async getCloneFiles(uiContext: UIContext) {
    try {
      this.contactList = await contact.queryContacts(uiContext.getHostContext() as common.UIAbilityContext)
      this.contact.size = this.contactList.length
      this.contact.fileSize = 100
    } catch (e) {
      UtilLog.error(`getCloneFiles failed : ${JSON.stringify(e)}`)
    }
  }

  // 将文件数据发送给新机
  handleSendFileCount() {
    sendFileCount({
      contact: this.contact,
      image: this.image,
      video: this.video,
    })
  }

  getAllSize(fileList: FileBasic[]) {
    let size = 0
    fileList.forEach((data) => {
      size = size + data.size
    })
    return size
  }

  getSelectedFile() {
    if (!this.contact.isSelected) {
      this.contact = new MainFile()
    }
    if (this.contactList.length > 0 && this.contact.isSelected) {
      const fileVo: FileVo = {
        uri: '',
        name: '',
        type: FileType.CONTACT,
        size: 0,
        contactList: this.contactList,
      }
      this.selectedFiles.push(fileVo)
      this.contact.state = TransferState.MIDDLE
    }
    if (!this.image.isSelected) {
      this.image = new MainFile()
    }
    if (this.image.size > 0 && this.image.isSelected) {
      for (let index = 0; index < this.image.list.length; index++) {
        const data = this.image.list[index];
        const fileInfo = this.getFileInfo(data.uri, FileType.IMAGE, data.size)
        if (fileInfo) {
          this.selectedFiles.push(fileInfo)
        }
      }
      this.image.state = TransferState.MIDDLE
    }
    if (!this.video.isSelected) {
      this.video = new MainFile()
    }
    if (this.video.size > 0 && this.video.isSelected) {
      for (let index = 0; index < this.video.list.length; index++) {
        const data = this.video.list[index];
        const fileInfo = this.getFileInfo(data.uri, FileType.VIDEO, data.size)
        if (fileInfo) {
          this.selectedFiles.push(fileInfo)
        }
      }
      this.video.state = TransferState.MIDDLE
    }
  }

  getFileInfo(uri: string, type: FileType, size: number): FileVo {
    const path: string = new fileUri.FileUri(uri).path;
    // 从URI中提取文件名
    const fileName = path.substring(path.lastIndexOf('/') + 1) || '未知文件'
    return {
      name: fileName,
      uri: uri,
      size: size, // 模拟文件大小
      type: type,
    }
  }

  // 清理不需要上传的文件
  clearRedundantFile() {
    if (!this.contact.isSelected) {
      this.contact = new MainFile()
      this.contactList = []
    }
    if (!this.image.isSelected) {
      this.image = new MainFile()
    }
    if (!this.video.isSelected) {
      this.video = new MainFile()
    }
  }

  uploadFile() {
    this.getSelectedFile()
    if (this.selectedFiles.length === 0) {
      promptAction.showToast({ message: '请选择文件' })
      return;
    }
    try {
      this.clearRedundantFile()
      this.totalState = TransferState.MIDDLE
      this.checkIsConnected()
      sendFile(this.selectedFiles[this.sendCount])
      this.contact.state = TransferState.AFTER
    } catch (e) {
      console.error('uploadFile', JSON.stringify(e))
    }
  }

  // 判断是否所有数据传输完成
  checkIsTransferAll() {
    if (this.contact.recvSize === this.contact.fileSize && this.image.recvSize === this.image.fileSize &&
      this.video.recvSize === this.video.fileSize) {
      this.totalState = TransferState.AFTER
    }
  }

  // 检测tcp是否断连
  checkIsConnected() {
    this.timer = setInterval(() => {
      if (!TcpClient.isConnected) {
        this.totalState = TransferState.ERROR
        if (this.contact.state !== TransferState.AFTER) {
          this.contact.state = TransferState.ERROR
        }
        if (this.image.state !== TransferState.AFTER) {
          this.image.state = TransferState.ERROR
        }
        if (this.video.state !== TransferState.AFTER) {
          this.video.state = TransferState.ERROR
        }
        console.error('Connected Error')
      }
    }, 500)
  }
}
