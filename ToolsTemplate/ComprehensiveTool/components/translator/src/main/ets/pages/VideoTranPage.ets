import { allLanguages, RecordStatus } from '../common/Constant';
import { EndRecord } from '../components/EndRecord';
import { ProgressRecord } from '../components/ProgressRecord';
import { StartRecord } from '../components/StartRecord';
import { WsUtil } from '../util/WSUtils';
import { VideoTranPageVM } from '../viewmodel/VideoTranPageVM';

@Preview
@ComponentV2
struct VideoTranPage {
  vm: VideoTranPageVM = VideoTranPageVM.instance

  aboutToAppear(): void {
    WsUtil.webSend()
    WsUtil.onEnd = (text: string, language: string) => {
      this.vm.text = text
      const res = allLanguages.find((data) => {
        return data.code === language
      })
      if (res) {
        this.vm.inputLanguage = res.text
        this.vm.input = res.text
      }
    }
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.recordStatus === RecordStatus.PENDING) {
          StartRecord()
        } else if (this.vm.recordStatus === RecordStatus.PROGRESS) {
          ProgressRecord()
        } else {
          EndRecord()
        }
      }
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('语音翻译')
  }
}

@Builder
export function VideoTranPageBuilder() {
  VideoTranPage();
}