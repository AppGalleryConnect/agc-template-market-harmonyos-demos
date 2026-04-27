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
  type: string
  authorId: string
}
