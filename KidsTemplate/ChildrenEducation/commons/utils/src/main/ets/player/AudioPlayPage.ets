import { Title } from '../uicomponents/Title';
import { PlayConstants } from './common/constants/PlayConstants';
import { GlobalContext } from '../utils/GlobalContext';
import { ArrayList } from '@kit.ArkTS';
import { History, VideoCardDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CustomContentDialog, promptAction } from '@kit.ArkUI';
import { TimeControl } from './common/util/TimeControl';
import { DateFormatUtil } from '../utils/DateFormatUtil';
import { CommonConstants } from '../constants/CommonConstants';
import { emitter } from '@kit.BasicServicesKit';
import { historyRecord } from './PlayControl';


@ComponentV2
export struct AudioPlayPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local title: string = '';
  @Local imageUrl: string = '';
  @Local index: number = 1;
  @Local totalTime: number = 0;
  @Local currentTime: number = 0;
  @Local audioUrl: string = '';
  @Local status: number = PlayConstants.STATUS_START;
  private audioDetailInfo = GlobalContext.getContext().getObject(CommonConstants.GLOBAL_VIDEO_LIST) as VideoDetail;
  private jumpReturnPlayState: number = PlayConstants.STATUS_PAUSE;
  controller: VideoController = new VideoController();

  private audioInfo : VideoCardDetail = {
    id: '',
    cardId: '',
    title: '',
    imageUrl: '',
    videoNumber: 0,
    iconUrl: '',
    videoUrl: '',
    isVip: false
  };

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Video({
            src: this.audioUrl,
            controller: this.controller,
          })
            .autoPlay(this.status === PlayConstants.STATUS_START)
            .visibility(Visibility.Hidden)
            .backgroundColor(Color.White)
            .onPrepared((e) => {
              this.currentTime = 0;
              this.totalTime = e.duration;
            })
            .onUpdate((e) => {
              this.currentTime = e.time;
              console.info('onUpdate is ' + e.time);
            })
            .onFinish(() => {
              this.playNextAudio();
            })
            .zIndex(0);

          Column() {
            Image(this.imageUrl)
              .width(200)
              .height(200)
              .borderRadius(10)
              .padding({
                bottom: '5%'
              });
            Text(this.title)
              .fontWeight(FontWeight.Regular)
              .padding({
                top : 16
              })

            Column() {
              this.playTimeControl();

              this.playStatusControl();
            }
            .padding({
              top: 200,
            });
          }
          .padding({
            top: 100,
          })
          .zIndex(1);
        };
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT);
    }
    .onReady((cxt: NavDestinationContext) => {
      let audioCardDetail = cxt.pathInfo.param as VideoCardDetail;
      this.title = audioCardDetail.title;
      this.imageUrl = audioCardDetail.imageUrl;
      this.audioUrl = audioCardDetail.videoUrl;
      this.index = audioCardDetail.videoNumber - 1;
    })
    .onShown(() => {
      if (TimeControl.timeControl()) {
        this.appPathStack.pop();
        return;
      }
      if (this.totalTime !== 0 && this.currentTime === this.totalTime) {
        let globalVideoList = this.audioDetailInfo.videoCardDetail;
        let curIndex = this.index + PlayConstants.CONTROL_NEXT;
        this.audioInfo = globalVideoList[curIndex];
        let isVip = this.audioInfo.isVip;
        let vipInfo = GlobalContext.getContext().getObject(CommonConstants.IS_VIP) as boolean;
        if (isVip && !vipInfo) {
          return;
        }

        this.index = curIndex;
        this.title = this.audioInfo.title;
        this.imageUrl = this.audioInfo.imageUrl;
        this.audioUrl = this.audioInfo.videoUrl;

        this.controller.reset();
        this.switchPlayOrPause();
        return;
      }
      if (this.status === PlayConstants.STATUS_PAUSE && this.jumpReturnPlayState === PlayConstants.STATUS_START) {
        this.switchPlayOrPause();
      }
    })
    .onHidden(() => {
      if (this.status === PlayConstants.STATUS_START) {
        this.controller.pause();
        this.status = PlayConstants.STATUS_PAUSE;
        this.jumpReturnPlayState = PlayConstants.STATUS_START;
      } else {
        this.jumpReturnPlayState = PlayConstants.STATUS_PAUSE;
      }
    })
    .title(Title(this.title))
    .onBackPressed(() => {
      this.status = PlayConstants.STATUS_PAUSE;
      this.controller.pause();
      this.controller.stop();
      historyRecord(this.audioDetailInfo, this.index);
      this.appPathStack.pop();
      return true;
    });
  }

  playNextAudio() {
    if (TimeControl.timeControl()) {
      this.appPathStack.pop();
      return;
    }

    let globalVideoList = this.audioDetailInfo.videoCardDetail;
    let curIndex = this.index + PlayConstants.CONTROL_NEXT;
    if (curIndex === globalVideoList.length) {
      if (this.currentTime === this.totalTime) {
        this.switchPlayOrPause();
      }
      promptAction.showToast({
        message: PlayConstants.LAST_NUMBER,
        alignment: Alignment.Center,
      });
      return;
    }

    this.audioInfo = globalVideoList[curIndex];
    let isVip = this.audioInfo.isVip;
    let vipInfo = GlobalContext.getContext().getObject(CommonConstants.IS_VIP) as boolean;

    if (isVip && !vipInfo) {
      this.status = PlayConstants.STATUS_PAUSE;
      this.dialogController.open();
      return;
    }

    this.index = curIndex;
    this.title = this.audioInfo.title;
    this.imageUrl = this.audioInfo.imageUrl;
    this.audioUrl = this.audioInfo.videoUrl;
    this.controller.reset();
  }

  playPreviousAudio() {
    if (TimeControl.timeControl()) {
      this.appPathStack.pop();
      return;
    }
    let globalVideoList = this.audioDetailInfo.videoCardDetail;
    let curIndex = this.index - PlayConstants.CONTROL_NEXT;

    if (curIndex < 0) {
      promptAction.showToast({
        message: PlayConstants.FIRST_NUMBER,
        alignment: Alignment.Center,
      });
      return;
    }

    this.audioInfo = globalVideoList[curIndex];
    this.index = curIndex;
    this.title = this.audioInfo.title;
    this.imageUrl = this.audioInfo.imageUrl;
    this.audioUrl = this.audioInfo.videoUrl;
    this.controller.reset();
  }

  switchPlayOrPause() {
    if (this.status === PlayConstants.STATUS_START) {
      this.controller.pause();
      this.status = PlayConstants.STATUS_PAUSE;
    } else {
      this.controller.start();
      this.status = PlayConstants.STATUS_START;
    }
  }

  @Builder
  playStatusControl() {
    Row({ space: '30' }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width('50')
        .height('50')
        .borderRadius(100)
        .backgroundColor('#fff6f3f3');

        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          .fontColor(this.index === 0 ? [Color.Gray] : [Color.Black])
          .fontSize('30vp');
      }
      .onClick(() => {
        this.playPreviousAudio();
      });

      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width('65')
        .height('65')
        .borderRadius(100)
        .backgroundColor('#FFD15D');

        SymbolGlyph(this.status === PlayConstants.STATUS_START ? $r('sys.symbol.pause') :
        $r('sys.symbol.play_fill'))
          .fontColor([$r('sys.color.white')])
          .fontSize('30vp');
      }
      .onClick(() => {
        this.switchPlayOrPause();
      });

      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width('50')
        .height('50')
        .borderRadius(100)
        .backgroundColor('#fff6f3f3');

        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          .fontColor(this.index === this.audioDetailInfo.videoCardDetail.length-1 ? [Color.Gray] : [Color.Black])
          .fontSize('30vp');
      }
      .onClick(() => {
        this.playNextAudio();
      });
    }
    .padding({
      top: '5%',
    });
  }

  @Builder
  playTimeControl() {
    Row({ space: 5 }) {
      Text(DateFormatUtil.secondToTime(this.currentTime));
      Slider({
        value: this.currentTime,
        min: 0,
        max: this.totalTime,
        step: 1,
        style: SliderStyle.OutSet,
      })
        .trackColor('#fff6f3f3')
        .selectedColor('#FFD15D')
        .trackThickness(PlayConstants.PROGRESS_TRACK_THICKNESS)
        .layoutWeight(1)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.currentTime = value;
          this.controller.setCurrentTime(value, SeekMode.PreviousKeyframe);
        });
      Text(DateFormatUtil.secondToTime(this.totalTime));
    }
    .padding({
      left: '5%',
      right: '5%',
    });
  }

  @Builder
  buildContent(): void {
    Column() {
      Text('下一视频需要开通VIP，即将跳转到VIP页面');
    }
    .width(CommonConstants.FULL_PERCENT);
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '温馨提示',
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          },
        },
        {
          value: '前往开通',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIP_PAGE_VIEW, this.audioInfo);
            this.appPathStack.pushDestination(pathInfo, true);
            return;
          },
        },
      ],
    }),
    autoCancel: false
  });
}