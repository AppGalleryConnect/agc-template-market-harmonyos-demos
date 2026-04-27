import { HashMap } from '@kit.ArkTS'
import { image } from '@kit.ImageKit'
import { FileBaseInfo } from 'cloud_file_base'
import { FileInfo } from 'common'

export class ShareOptions {
  id: string = ''
  type: string | number = ''
  title: string = ''
  createTime: string = ''
  coverUrl: string | undefined = ''
  isVideo: boolean = false
  articleFrom?: string | undefined = ''
}

export class ShareKinds {
  id: string = ''
  icon: string = ''
  name: string = ''
}

export class ScreenInfo {
  screenWidth: number = 0
  screenHeight: number = 0
}

export class PopupBaseController {
  hide: () => void = () => {
  }
}

export interface NewsQrCode {
  articleId: string
  type: string | number
}


export class QqShareData {
  shareJson: string = ''
  timestamp: number = new Date().getTime()
  nonce: number = 0
  shareJsonSign: string = ''
}

export interface QqShareContent {
  msgStyle: number
  title: string
  url: string
  pictureUrl: string
}

export class QqShareResult {
  resultType: ShareResultType = 0;
  code: number = 0;
  message: string | undefined | null = undefined;
  detail: string | undefined | null = undefined;
  extra: HashMap<string, string> = new HashMap();
}

export enum ShareResultType {
  Success = 1,
  Cancel = 2,
  Error = 3
}

export interface ShareSheetParams {
  onPost: (isOpen: boolean, pixmap: image.PixelMap) => void
  qrCodeInfo: ShareOptions
}

export interface ShareUsefullTimeParam {
  blockUsefullTime: (id: number, value: string | Resource) => void,
  blockUsefullTimeId?: number,
  fileInfo? : FileInfo | FileBaseInfo
}

export interface ShreGetCodeParam {
  blockContent: (value: string) => void
}
