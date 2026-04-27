import { ReadStateCode, TextReader, TextReaderIcon } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BarAlignment, DisplayTab, IconParams } from '../Common/Model';

@Component
export struct ReadIcon {
  @Prop currentId: string
  @Prop readerParam: TextReader.ReaderParam = {
    isVoiceBrandVisible: false,
    businessBrandInfo: { panelName: '小艺朗读' },
    isFastForward: false,
    isMinibarNeeded: true,
    minibarParams: { defaultAlignment: BarAlignment.LEFT, bottom: 50 },
    displayTab: DisplayTab.COVER_AND_CONTENT
  }
  @Prop iconParams: IconParams = {
    iconWidth: 32,
    iconHeight: 32,
    iconBackgroundColor: $r('sys.color.background_primary'),
    iconBorderRadius: 8
  }
  // 用于显示当前页的按钮状态
  @State isInit: boolean = false;
  @State readState: ReadStateCode = ReadStateCode.WAITING;
  @State selectedReadInfo: TextReader.ReadInfo | undefined = undefined
  readInfoList: TextReader.ReadInfo[] = []
  onSetArticle: (id: string) => void = () => {
  }
  onClickArticle: (id: string) => void = () => {
  }
  onClickAuthor: (id: string) => void = () => {
  }
  onClickNotification: (id: string) => void = () => {
  }
  onShowPanel: () => void = () => {
  }
  onHidePanel: () => void = () => {
  }
  onStop: () => void = () => {
  }
  onRelease: () => void = () => {
  }
  onEventNotification: (ne: TextReader.NotificationEvent) => void = () => {
  }
  onEventPanel: (pe: TextReader.PanelEvent) => void = () => {
  }
  onEventReadList: (list: Array<TextReader.ListEventState>) => void = () => {
  }

  async init() {
    try {
      let context: Context | undefined = this.getUIContext().getHostContext()
      if (context) {
        if (canIUse('SystemCapability.AI.Component.TextReader')) {
          await TextReader.init(context, this.readerParam).then(() => {
          }).catch((_e: BusinessError) => {
          });
          this.isInit = true;
          this.setActionListener();
        }
      }
    } catch (err) {
    }
  }

  async aboutToAppear() {
    this.selectedReadInfo = this.readInfoList.find(item => item.id === this.currentId)
    this.init();
  }

  aboutToDisappear() {
    this.removeActionListener();
  }

  onStateChanged = (state: TextReader.ReadState) => {
    if (this.selectedReadInfo?.id === state.id) {
      this.readState = state.state;
    } else {
      this.readState = ReadStateCode.WAITING;
    }
  }

  // 设置操作监听
  setActionListener() {
    try {
      TextReader.on('stateChange', (state: TextReader.ReadState) => {
        this.onStateChanged(state)
      });
      TextReader.on('setArticle', (id: string) => {
        this.onSetArticle(id);
      });
      TextReader.on('clickArticle', (id: string) => {
        this.onClickArticle(id);
      });
      TextReader.on('clickAuthor', (id: string) => {
        this.onClickAuthor(id);
      });
      TextReader.on('clickNotification', (id: string) => {
        this.onClickNotification(id);
      });
      TextReader.on('showPanel', () => {
        this.onShowPanel();
      });
      TextReader.on('hidePanel', () => {
        this.onHidePanel();
      });
      TextReader.on('stop', () => {
        this.onStop();
      });
      TextReader.on('release', () => {
        this.onRelease();
      });
      TextReader.on('requestMore', () => {
        TextReader.loadMore([], true);
      });
      TextReader.on('eventNotification', (ne: TextReader.NotificationEvent) => {
        this.onEventNotification(ne);
      });
      TextReader.on('eventPanel', (pe: TextReader.PanelEvent) => {
        this.onEventPanel(pe);
      });
      TextReader.on('eventReadList', (list: Array<TextReader.ListEventState>) => {
        this.onEventReadList(list);
      });
    } catch (err) {
    }
  }

  removeActionListener() {
    try {
      TextReader.off('stateChange');
      TextReader.off('setArticle');
      TextReader.off('clickArticle');
      TextReader.off('clickAuthor');
      TextReader.off('clickNotification');
      TextReader.off('showPanel');
      TextReader.off('hidePanel');
      TextReader.off('stop');
      TextReader.off('release');
      TextReader.off('eventNotification');
      TextReader.off('eventPanel');
      TextReader.off('eventReadList');
    } catch (err) {
    }
  }

  build() {
    Column() {
      TextReaderIcon({ readState: this.readState })
        .width(this.iconParams.iconWidth ?? 32)
        .height(this.iconParams.iconHeight ?? 32)
        .backgroundColor(this.iconParams.iconBackgroundColor ?? $r('sys.color.background_primary'))
        .borderRadius(this.iconParams.iconBorderRadius ?? 8)
        .onClick(async () => {
          try {
            if (this.readInfoList !== undefined) {
              await TextReader.start(this.readInfoList, this.selectedReadInfo?.id);
            }
          } catch (err) {
          }
        })
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .alignItems(HorizontalAlign.End)
  }
}