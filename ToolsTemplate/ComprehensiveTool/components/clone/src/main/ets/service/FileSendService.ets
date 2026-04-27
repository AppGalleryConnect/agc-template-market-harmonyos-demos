import { FileType, TransferState } from '../common/Constant';
import { FileCountMessage, ContactMessage } from '../model/BinaryProtocol';
import { FileCount, FileVo } from '../model/FileVo';
import { TcpClient } from './TcpClient';
import { getLocalIPAddress } from '../utils/FileUtil';

class FileSendService {
  // 发送文件数量
  async sendFileCount(fileCount: FileCount) {
    const ipAddress = await getLocalIPAddress()
    const fileCountMessage: FileCountMessage = {
      ip: ipAddress,
      contact: {
        state: TransferState.BEFORE,
        list: [...fileCount.contact.list],
        count: fileCount.contact.count,
        isSelected: fileCount.contact.isSelected,
        size: fileCount.contact.size,
        fileSize: fileCount.contact.fileSize,
        recvSize: fileCount.contact.recvSize,
      },
      image: {
        state: TransferState.BEFORE,
        list: [...fileCount.image.list],
        count: fileCount.image.count,
        isSelected: fileCount.image.isSelected,
        size: fileCount.image.size,
        fileSize: fileCount.image.fileSize,
        recvSize: fileCount.image.recvSize,
      },
      video: {
        state: TransferState.BEFORE,
        list: [...fileCount.video.list],
        count: fileCount.video.count,
        isSelected: fileCount.video.isSelected,
        size: fileCount.video.size,
        fileSize: fileCount.video.fileSize,
        recvSize: fileCount.video.recvSize,
      },
    }
    TcpClient.sendFileCount(fileCountMessage)
  }

  // 发送文件
  async sendFile(fileVo: FileVo): Promise<void> {
    // 发送的数据为联系人
    if (fileVo.type === FileType.CONTACT && fileVo.contactList) {
      const startMessage: ContactMessage = {
        fileType: fileVo.type,
        list: fileVo.contactList,
      };
      TcpClient.sendContactData(startMessage)
    } else {
      TcpClient.sendFileData(fileVo)
    }
  }
}

const instance = new FileSendService();

export function sendFile(fileVo: FileVo) {
  instance.sendFile(fileVo)
}

export function sendFileCount(fileCount: FileCount) {
  instance.sendFileCount(fileCount)
}