import { ReadStateCode, TextReader } from '@kit.SpeechKit';
import { UIContext } from '@kit.ArkUI';
import { PlayInfo } from 'module_base';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = 'TEXT_READER';

@ObservedV2
export class TextReaderUtil {
  private static _instance: TextReaderUtil;
  readInfo: TextReader.ReadInfo = {
    id: '',
    title: {
      text: '',
      isClickable: true,
    },
  };
  private context?: Context;
  @Trace readState: ReadStateCode = ReadStateCode.WAITING;

  public static get instance() {
    if (!TextReaderUtil._instance) {
      TextReaderUtil._instance = new TextReaderUtil();
    }
    return TextReaderUtil._instance;
  }

  async init(playInfo: PlayInfo, uiContext: UIContext) {
    this.readInfo = {
      id: playInfo.playId,
      title: {
        text: playInfo.title,
        isClickable: true,
      },
      imageUrl: playInfo.imageUrl,
      bodyInfo: playInfo.introduction,
    };

    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true,
      businessBrandInfo: {
        panelName: playInfo.panelName,
        panelIcon: playInfo.panelIcon,
      },
      reportProgressPeriod: 1,
    };

    this.context = uiContext.getHostContext();
    if (this.context) {
      try {
        await TextReader.init(this.context, readerParam);
        await this.start();
      } catch (err) {
        UtilLog.error(0x0001, TAG, 'init error: %{public}s', JSON.stringify(err));
        if (err.code === 1010600011) {
          TextReader.stop().then(async () => {
            TextReader.release();
            if (this.context) {
              await TextReader.init(this.context, readerParam);
              await this.start();
            }
          });
        }
      }
    }
  }

  async start() {
    if (this.readState === ReadStateCode.PLAYING) {
      TextReader.showPanel();
      return;
    }
    try {
      this.setActionListener();
      this.setEventListener();
      await TextReader.start([this.readInfo], this.readInfo?.id);
    } catch (err) {
      UtilLog.error(0x0001, TAG, 'init message: %{public}s', JSON.stringify(err));
    }
  }

  setActionListener() {
    try {
      TextReader.on('clickNotification', (id: string) => {
        UtilLog.info(0x0001, TAG, `onClickNotification ${id}`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onClickNotification error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('showPanel', () => {
        UtilLog.info(0x0001, TAG, `onShowPanel`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onShowPanel error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('hidePanel', () => {
        UtilLog.info(0x0001, TAG, `onHidePanel`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onHidePanel error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('stop', () => {
        UtilLog.info(0x0001, TAG, `onStop`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onStop error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('release', () => {
        UtilLog.info(0x0001, TAG, `onRelease`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onRelease error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('stateChange', (state: TextReader.ReadState) => {
        UtilLog.info(0x1, TAG, `ReadState: %{public}s`, JSON.stringify(state));
        this.onStateChanged(state);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onStateChange error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('readProgress', (readProgress: TextReader.ReadProgress) => {
        UtilLog.info(0x0001, TAG, `Succeeded in setting readProgressListener: ${JSON.stringify(readProgress)}`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onReadProgress error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('requestMore', () => this.onStateChanged);
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onRequestMore error:${JSON.stringify(e)}`);
    }
  }

  onStateChanged = (state: TextReader.ReadState) => {
    UtilLog.info(0x1, TAG, `selectedReadInfo.id: %{public}s`, this.readInfo?.id);
    UtilLog.warn(0x1, TAG, `match, changeState to %{public}s`, JSON.stringify(state));
    this.readState = state.state;
  };

  setEventListener() {
    try {
      TextReader.on('eventNotification', (event: TextReader.NotificationEvent) => {
        UtilLog.info(0x0001, TAG, `Notification event: ${JSON.stringify(event)}`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onEventNotification error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('eventPanel', (event: TextReader.PanelEvent) => {
        UtilLog.info(0x0001, TAG, `Panel event: ${JSON.stringify(event)}`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onEventPanel error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('eventReadList', (event: Array<TextReader.ListEventState>) => {
        UtilLog.info(0x0001, TAG, `ReadList event: ${JSON.stringify(event)}`);
        TextReader.loadMore([], true);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onEventReadList error:${JSON.stringify(e)}`);
    }

    try {
      TextReader.on('readProgress', (readProgress: TextReader.ReadProgress) => {
        UtilLog.info(0x0001, TAG, `Succeeded in setting readProgressListener: ${JSON.stringify(readProgress)}`);
      });
    } catch (e) {
      UtilLog.error(0x0001, TAG, `onReadProgress error:${JSON.stringify(e)}`);
    }
  }
}