import { ReaderContent, ReaderState, ResetParamType } from '../Common/Model'

export class TextReaderController {
  textReaderStart: (readInfoList: ReaderContent[], articleId?: string) => Promise<void> =
    () => new Promise(() => {
    })
  textReaderStop: () => Promise<void> = () => new Promise(() => {
  })
  textReaderResetParam: (paramName: ResetParamType) => void = () => {
  }
  textReaderRelease: () => Promise<void> = () => new Promise(() => {
  })
  textReaderPause: () => void = () => {
  }
  textReaderResume: () => void = () => {
  }
  textReaderPlayPrev: () => void = () => {
  }
  textReaderPlayNext: () => void = () => {
  }
  textReaderHidePanel: () => void = () => {
  }
  textReaderShowPanel: () => void = () => {
  }
  textReaderHideMinibar: () => void = () => {
  }
  textReaderShowMinibar: () => void = () => {
  }
  queryReadState: (id?: string) => ReaderState = () => {
    return { id: '', state: 1 }
  }
  setArticleContent: (id: string, bodyInfo?: string) => void = () => {
  }
  setArticle: (readInfo: ReaderContent) => void = () => {
  }
  queryReadStateByCategoryId: (categoryId: string) => ReaderState = () => {
    return { id: '', state: 1 }
  }
}