import { common } from '@kit.AbilityKit';
import { ReadStateCode, TextReader } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
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
  @Local context: Context | undefined = undefined;

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
    this.context = this.getUIContext().getHostContext();
    try {
      for (let x of this.readInfoList) {
        const readInfoSystem: TextReader.ReadInfo = { id: '001', title: { text: '', isClickable: true } };
        await ParamsTransform.readerParamTransform(this.context as common.UIAbilityContext, x, readInfoSystem);
        this.readInfoSystemList.push(readInfoSystem);
      }
    } catch (error) {
      hilog.error(0x0000, 'TextRead', 'TextReaderInfo failed to transform. Error: ', error);
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
          await ParamsTransform.readerParamTransform(this.context as common.UIAbilityContext, x, readInfoSystem)
          readInfoSystemList.push(readInfoSystem)
        }
      } catch (error) {
        hilog.error(0x0000, 'TextRead', 'TextReaderInfo failed to transform. Error: ', error);
      }
      await TextReader.start(readInfoSystemList, articleId).then(() => {
        hilog.info(0x0000, 'TextRead', `TextReader succeeded in starting`);
      }).catch((e: BusinessError) => {
        hilog.error(0x0000, 'TextRead', `TextReader failed to start. Code: ${e.code}, message: ${e.message}`);
      })
    }
    this.controller.textReaderStop = async () => {
      TextReader.stop().then(() => {
        hilog.info(0x0000, 'TextRead', `TextReader succeeded in stopping.`);
      }).catch((e: BusinessError) => {
        hilog.error(0x0000, 'TextRead', `TextReader failed to stop. Code: ${e.code}, message: ${e.message}`);
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
        hilog.info(0x0000, 'TextRead', `TextReader succeeded in resetParam.`);
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to resetParam. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderRelease = async () => {
      TextReader.release().then(() => {
        hilog.info(0x0000, 'TextRead', `TextReader succeeded in releasing.`);
      }).catch((e: BusinessError) => {
        hilog.error(0x0000, 'TextRead', `TextReader failed to release. Code: ${e.code}, message: ${e.message}`);
      })
    }
    this.controller.textReaderPause = () => {
      try {
        TextReader.pause();
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to pause. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderResume = () => {
      try {
        TextReader.resume();
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to resume. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderPlayPrev = () => {
      try {
        TextReader.playPrev();
      } catch (e) {
        hilog.error(0x0000, 'TextRead',
          `TextReader failed to play previous article. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderPlayNext = () => {
      try {
        TextReader.playNext();
      } catch (e) {
        hilog.error(0x0000, 'TextRead',
          `TextReader failed to play next article. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderHidePanel = () => {
      try {
        TextReader.hidePanel();
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to hide panel. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderShowPanel = () => {
      try {
        TextReader.showPanel();
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to show panel. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderHideMinibar = () => {
      try {
        TextReader.hideMinibar();
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to hide minibar. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.textReaderShowMinibar = () => {
      try {
        TextReader.showMinibar();
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to show minibar. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.queryReadState = (id?: string) => {
      try {
        const readState = TextReader.queryReadState(id ?? undefined)
        hilog.info(0x0000, 'TextRead', `Succeeded in querying read state, read state: ${JSON.stringify(readState)}`);
        return readState as ReaderState;
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to queryReadState. Code: ${e.code}, message: ${e.message}`);
        return { id: '', state: ReadStateCode.WAITING }
      }
    }
    this.controller.setArticleContent = (id: string, bodyInfo?: string) => {
      try {
        TextReader.setArticleContent(id, bodyInfo);
      } catch (e) {
        hilog.error(0x0000, 'TextRead',
          `TextReader failed to setArticleContent. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.setArticle = (readInfo: ReaderContent) => {
      const readInfoSystem: TextReader.ReadInfo = { id: '001', title: { text: '', isClickable: true } }
      try {
        ParamsTransform.readerParamTransform(this.context as common.UIAbilityContext, readInfo, readInfoSystem)
        TextReader.setArticle(readInfoSystem);
      } catch (e) {
        hilog.error(0x0000, 'TextRead', `TextReader failed to setArticle. Code: ${e.code}, message: ${e.message}`);
      }
    }
    this.controller.queryReadStateByCategoryId = (categoryId: string) => {
      try {
        const readState = TextReader.queryReadStateByCategoryId(categoryId)
        hilog.info(0x0000, 'TextRead',
          `Succeeded in querying read state by category id, read state: ${JSON.stringify(readState)}`);
        return readState as ReaderState;
      } catch (e) {
        hilog.error(0x0000, 'TextRead',
          `TextReader failed to queryReadStateByCategoryId. Code: ${e.code}, message: ${e.message}`);
        return { id: '', state: ReadStateCode.WAITING }
      }
    }
  }
}


