import { ReadStateCode, TextReader, TextReaderIcon } from '@kit.SpeechKit';
import { Catalog } from 'parse';
import { ReaderController } from '../controller/ReaderController';

@Component
export struct ReaderSpeechCard {
  @Prop readController: ReaderController | undefined = undefined;
  @State readInfoList: TextReader.ReadInfo[] = [];
  @State curId: string = '';
  @State selectedReadInfo: TextReader.ReadInfo = this.readInfoList[this.curId];
  @State readState: ReadStateCode = ReadStateCode.WAITING;
  @State isSpeechInit: boolean = false;

  async aboutToAppear() {
    if (!this.isSpeechInit) {
      await this.speechInit();
      this.initReaderInfo();
      this.isSpeechInit = true;
    }
  }

  async speechInit() {
    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true,
      businessBrandInfo: {
        panelName: getContext().resourceManager.getStringByNameSync('app_name'),
        panelIcon: $r('app.media.startIcon')
      }
    }
    try {
      await TextReader.init(getContext(this), readerParam);
      this.isSpeechInit = true;
    } catch (err) {
      console.error(`TextReader failed to init. Code: ${err.code}, message: ${err.message}`);
    }
  }

  initReaderInfo() {
    const cc = this.readController?.getCatalog();
    const curPageNum = this.readController?.getCurPageNum() as number;
    let preIndex = 0;
    if (cc) {
      for (let i = 0; i < cc.totalCount(); i++) {
        const c: Catalog = cc.getData(i);
        const content = this.readController?.getContent(c);
        const author = this.readController?.getBook().author;
        if (curPageNum <= c.index && curPageNum > preIndex) {
          this.curId = c.id;
        }

        if (content && author) {
          const readInfo: TextReader.ReadInfo = this.buildReadInfo(c.id, c.title, author, content);
          this.readInfoList.push(readInfo);
        }

        preIndex = c.index;
      }
      this.selectedReadInfo = this.readInfoList[this.curId];
    }
  }

  buildReadInfo(id: string, title: string, author: string, content: string): TextReader.ReadInfo {
    let readInfo: TextReader.ReadInfo = {
      id: `${id}`,
      title: {
        text: `${title}`,
        isClickable: false
      },
      author: {
        text: `${author}`,
        isClickable: false
      },
      bodyInfo: `${content}`
    };

    return readInfo;
  }

  // 设置操作监听
  setActionListener() {
    TextReader.on('stateChange', (state: TextReader.ReadState) => {
      this.onStateChanged(state);
    });
    TextReader.on('requestMore', () => this.onStateChanged);
  }

  onStateChanged = (state: TextReader.ReadState) => {
    if (this.selectedReadInfo?.id === state.id) {
      this.readState = state.state;
    } else {
      this.readState = ReadStateCode.WAITING;
    }
  }

  build() {
    Column() {
      if (this.isSpeechInit) {
        Column() {
          Row() {
            Stack() {
              TextReaderIcon({ readState: this.readState })
                .width(40)
                .height(40)
                .onClick(async () => {
                  try {
                    this.setActionListener();
                    await TextReader.start(this.readInfoList, this.curId);
                  } catch (err) {
                    console.error(`TextReader failed to start. Code: ${err.code}, message: ${err.message}`);
                  }
                })
                .borderRadius(100)
                .backgroundColor(Color.White)
            }
          }
        }
        .margin({ top: 500, left: 20 })
      }
    }.height('100%')
    .width(40)
    .alignItems(HorizontalAlign.Start)
  }
}