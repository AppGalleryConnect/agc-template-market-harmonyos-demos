export enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}


export interface FileInfo {
  filePath: string,
  fileName: string
}


// 文字识别类型
export enum RecognitionType {
  //  默认
  DEFAULT_SCAN = 0,
  //  身份证
  ID_CARD = 1,
  //  护照
  PASSPORT = 2,
  //  驾驶证
  DRIVER_LICENSE = 3,
  //  银行卡
  BANK_CARD = 4
}