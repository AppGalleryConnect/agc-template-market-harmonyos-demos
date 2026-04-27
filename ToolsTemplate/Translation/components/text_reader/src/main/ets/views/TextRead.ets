import { ReadStateCode, TextReader } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TextReaderController } from '../utils/Utils';
import { ReadIcon } from '../Components/ReadIcon';
import {
  BarAlignment,
  DisplayTab,
  IconParams,
  ReaderContent,
  ReaderParams,
  ReaderState,
  ResetParamType
} from '../Common/Model';
import { ParamsTransform } from '../Common/ParamsTransform';

@ComponentV2
export struct TextRead {
  @Param @Require currentId: string
  @Param readInfoList: ReaderContent[] = []
  @Param iconParams: IconParams = {
    iconWidth: 32,
    iconHeight: 32,
    iconBackgroundColor: $r('sys.color.background_primary'),
    iconBorderRadius: 8
  }
  @Param readerParam: ReaderParams = {
    isVoiceBrandVisible: true,
    businessBrandInfo: { panelName: '小艺朗读' },
    isFastForward: false,
    isMinibarNeeded: true,
    minibarParams: { defaultAlignment: BarAlignment.LEFT, bottom: 50 },
    displayTab: DisplayTab.COVER_AND_CONTENT
  }
  @Param controller: TextReaderController = new TextReaderController()
  @Local readInfoSystemList: TextReader.ReadInfo[] = []

  @Event onSetArticle: (id: string) => void = () => {}
  @Event onClickArticle: (id: string) => void = () => {}
  @Event onClickAuthor: (id: string) => void = () => {}
  @Event onClickNotification: (id: string) => void = () => {}
  @Event onShowPanel: () => void = () => {}
  @Event onHidePanel: () => void = () => {}
  @Event onStop: () => void = () => {}
  @Event onRelease: () => void = () => {}
  @Event onEventNotification: (ne: TextReader.NotificationEvent) => void = () => {}
  @Event onEventPanel: (pe: TextReader.PanelEvent) => void = () => {}
  @Event onEventReadList: (list: Array<TextReader.ListEventState>) => void = () => {}


  async aboutToAppear() {
    try {
      for (let x of this.readInfoList) {
        const readInfoSystem: TextReader.ReadInfo = { id: '001', title: { text: '', isClickable: true } }
        await ParamsTransform.readerParamTransform(x, readInfoSystem)
        this.readInfoSystemList.push(readInfoSystem)
      }
    } catch (error) {
    }

    this.initializeController()
  }

  build() {
    Column() {
      ReadIcon({
        readInfoList: this.readInfoSystemList,
        currentId: this.currentId,
        readerParam: this.readerParam as TextReader.ReaderParam,
        iconParams: this.iconParams,
        onSetArticle: this.onSetArticle,
        onClickArticle: this.onClickArticle,
        onClickAuthor: this.onClickAuthor,
        onClickNotification: this.onClickNotification,
        onShowPanel: this.onShowPanel,
        onHidePanel: this.onHidePanel,
        onStop: this.onStop,
        onRelease: this.onRelease,
        onEventNotification: this.onEventNotification,
        onEventPanel: this.onEventPanel,
        onEventReadList: this.onEventReadList,
      })
    }
    .height('100%')
  }

  initializeController() {
    this.controller.textReaderStart = async (readInfoList: ReaderContent[], articleId?: string) => {
      const readInfoSystemList: TextReader.ReadInfo[] = []
      try {
        for (let x of readInfoList) {
          const readInfoSystem: TextReader.ReadInfo = { id: '001', title: { text: '', isClickable: true } }
          await ParamsTransform.readerParamTransform(x, readInfoSystem)
          readInfoSystemList.push(readInfoSystem)
        }
      } catch (error) {
      }
      await TextReader.start(readInfoSystemList, articleId).then(() => {
      }).catch((_e: BusinessError) => {
      })
    }
    this.controller.textReaderStop = async () => {
      TextReader.stop().then(() => {
      }).catch((_e: BusinessError) => {
      })
    }
    this.controller.textReaderResetParam = (paramName: ResetParamType) => {
      try {
        if (paramName === 1) {
          TextReader.resetParam(2)
        } else if (paramName === 2) {
          TextReader.resetParam(1)
        } else {
          TextReader.resetParam(paramName)
        }
      } catch (e) {
      }
    }
    this.controller.textReaderRelease = async () => {
      TextReader.release().then(() => {
      }).catch((_e: BusinessError) => {
      })
    }
    this.controller.textReaderPause = () => {
      try {
        TextReader.pause();
      } catch (e) {
      }
    }
    this.controller.textReaderResume = () => {
      try {
        TextReader.resume();
      } catch (e) {
      }
    }
    this.controller.textReaderPlayPrev = () => {
      try {
        TextReader.playPrev();
      } catch (e) {
      }
    }
    this.controller.textReaderPlayNext = () => {
      try {
        TextReader.playNext();
      } catch (e) {
      }
    }
    this.controller.textReaderHidePanel = () => {
      try {
        TextReader.hidePanel();
      } catch (e) {
      }
    }
    this.controller.textReaderShowPanel = () => {
      try {
        TextReader.showPanel();
      } catch (e) {
      }
    }
    this.controller.textReaderHideMinibar = () => {
      try {
        TextReader.hideMinibar();
      } catch (e) {
      }
    }
    this.controller.textReaderShowMinibar = () => {
      try {
        TextReader.showMinibar();
      } catch (e) {
      }
    }
    this.controller.queryReadState = (id?: string) => {
      try {
        const readState = TextReader.queryReadState(id ?? undefined)
        return readState as ReaderState;
      } catch (e) {
        return { id: '', state: ReadStateCode.WAITING }
      }
    }
    this.controller.setArticleContent = (id: string, bodyInfo?: string) => {
      try {
        TextReader.setArticleContent(id, bodyInfo);
      } catch (e) {
      }
    }
    this.controller.setArticle = (readInfo: ReaderContent) => {
      const readInfoSystem: TextReader.ReadInfo = { id: '001', title: { text: '', isClickable: true } }
      try {
        ParamsTransform.readerParamTransform(readInfo, readInfoSystem)
        TextReader.setArticle(readInfoSystem);
      } catch (e) {
      }
    }
    this.controller.queryReadStateByCategoryId = (categoryId: string) => {
      try {
        const readState = TextReader.queryReadStateByCategoryId(categoryId)
        return readState as ReaderState;
      } catch (e) {
        return { id: '', state: ReadStateCode.WAITING }
      }
    }
  }
}


