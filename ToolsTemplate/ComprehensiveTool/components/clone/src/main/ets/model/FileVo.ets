import { contact } from '@kit.ContactsKit';
import { FileType, MainFile, TransferType } from '../common/Constant'

export interface FileVo {
  uri: string //文件路径
  name: string //文件名
  type: FileType // 文件类型
  size: number // 文件大小
  thumbnail?: string //缩略图
  description?: string //文件描述
  id?: number
  time?: string // 文件时间
  tranType?: TransferType //传输类型
  deviceName?: string //设备名称
  deviceImg?: string //设备头像
  deviceImgData?: string
  contactList?: contact.Contact[]
}

export interface FileCount {
  contact: MainFile,
  image: MainFile,
  video: MainFile,
}

export interface FileDetail {
  size: string,
  count: number,
}

export interface SendType {
  type: FileType,
  size: number,
  count: number,
}