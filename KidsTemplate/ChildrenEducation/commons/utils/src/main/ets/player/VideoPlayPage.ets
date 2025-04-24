import { Title } from '../uicomponents/Title';
import { GlobalContext } from '../utils/GlobalContext';
import { ArrayList } from '@kit.ArkTS';
import { History, VideoCardDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { PlayConstants } from './common/constants/PlayConstants';
import { CustomContentDialog, display, promptAction, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { TimeControl } from './common/util/TimeControl';
import { LogUtil } from '../utils/LogUtil';
import { DateFormatUtil } from '../utils/DateFormatUtil';
import { CommonConstants } from '../constants/CommonConstants';
import { historyRecord } from './PlayControl';

@ComponentV2
export struct VideoPlayPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local title: string = '';
  @Local videoUrl: string = '';
  @Local index: number = 0;
  @Local totalTime: number = 0;
  @Local currentTime: number = 0;
  controller: VideoController = new VideoController();
  @Local status: number = PlayConstants.STATUS_START;
  @Local isLandscape: boolean = false; // 是否横屏状态
  private videoDetailInfo = GlobalContext.getContext().getObject(CommonConstants.GLOBAL_VIDEO_LIST) as VideoDetail;
  private jumpReturnPlayState: number = PlayConstants.STATUS_PAUSE;
  private windowClass = (getContext(this) as common.UIAbilityContext).windowStage.getMainWindowSync();
  @Local aspect: number = 9 / 16; // default video height/width ratio value
  @Local xComponentWidth: number = px2vp(display.getDefaultDisplaySync().width);
  @Local xComponentHeight: number = px2vp(display.getDefaultDisplaySync().width * this.aspect);
  @Local isShowVip: boolean = false;
  private videoInfo: VideoCardDetail = {
    id: '',
    cardId: '',
    title: '',
    imageUrl: '',
    videoNumber: 0,
    iconUrl: '',
    videoUrl: '',
    isVip: false,
  };

  aboutToAppear(): void {
    this.windowClass.on('windowSizeChange', (size) => {
      let viewWidth = px2vp(size.width);
      let viewHeight = px2vp(size.height);
      if (viewWidth > viewHeight) {
        this.xComponentWidth = viewHeight / this.aspect;
        this.xComponentHeight = viewHeight;
        this.isLandscape = true;
        this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false);
      } else {
        this.xComponentHeight = viewWidth * this.aspect;
        this.xComponentWidth = viewWidth;
        this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true);
        this.isLandscape = false;
      }
    });
  }

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      LogUtil.info('setWindowOrientation: ' + orientation + ' Succeeded.');
    }).catch((err: BusinessError) => {
      LogUtil.info('setWindowOrientation: ' + orientation + ' Failed. Cause: ' + JSON.stringify(err));
    });
  }

  aboutToDisappear(): void {
    this.isLandscape = false;
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            Video({
              src: this.videoUrl,
              controller: this.controller,
            })
              .aspectRatio(PlayConstants.ASPECT_RATIO)
              .height(this.isLandscape ? '250' : CommonConstants.FULL_PERCENT)
              .width(this.isLandscape ? CommonConstants.FULL_PERCENT : CommonConstants.FULL_PERCENT)
              .autoPlay(true)
              .controls(false)
              .onPrepared((e) => {
                this.currentTime = 0;
                this.totalTime = e.duration;
                this.xComponentHeight = px2vp(display.getDefaultDisplaySync().width * this.aspect);
                this.xComponentWidth = px2vp(display.getDefaultDisplaySync().width);
                console.info('onPrepared is ' + e.duration);
              })
              .onStart(() => {
                if (this.isShowVip === true) {
                  this.switchPlayOrPause();
                }
              })
              .onUpdate((e) => {
                this.currentTime = e.time;
                console.info('onUpdate is ' + e.time);
              })
              .onFinish(() => {
                this.playNextVideo();
              })
              .width(this.xComponentWidth)
              .height(this.xComponentHeight);
          };

          this.playControl();
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(this.isLandscape ? CommonConstants.FULL_PERCENT :
          this.xComponentHeight + (AppStorage.get<number>('statusBarHeight') ?? 0))
        .backgroundColor(Color.Black)
        .padding({ top: this.isLandscape ? 0 : (AppStorage.get<number>('statusBarHeight') || 0) });

        Row() {
          Text(this.title)
            .fontSize(16);
        }
        .padding({
          left: '4%',
        })
        .height(35)
        .width(CommonConstants.FULL_PERCENT);

        Row() {
        }
        .height(15)
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor('#F1F3F5');

        VideoCardDetailShow({
          controller: this.controller,
          globalVideoList: this.videoDetailInfo.videoCardDetail,
        });
      };
    }
    .onReady((cxt: NavDestinationContext) => {
      let videoCardDetail = cxt.pathInfo.param as VideoCardDetail;
      this.title = videoCardDetail.title;
      this.videoUrl = videoCardDetail.videoUrl;
      this.index = videoCardDetail.videoNumber - 1;
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
    .onShown(() => {
      if (TimeControl.timeControl()) {
        this.appPathStack.pop();
        return;
      }
      // 判断是否已经开通VIP，如果已开通，去除开通会员页面，开始播放
      let vipInfo = GlobalContext.getContext().getObject(CommonConstants.IS_VIP) as boolean;
      if (this.videoInfo.isVip && vipInfo) {
        this.isShowVip = false;
        this.switchPlayOrPause();
      }
      if (this.status === PlayConstants.STATUS_PAUSE && this.jumpReturnPlayState === PlayConstants.STATUS_START) {
        this.switchPlayOrPause();
      }
    })
    .hideTitleBar(this.isLandscape)
    .title(Title(this.title))
    .onBackPressed(() => {
      this.status = PlayConstants.STATUS_PAUSE;
      this.controller.pause();
      this.controller.stop();
      historyRecord(this.videoDetailInfo, this.index);
      this.appPathStack.pop();
      return true;
    });
  }

  @Builder
  landScapeTitle() {
    Row() {
      Image($r('app.media.video_screen_direction_switching_ic_back1'))
        .width(24)
        .height(24)
        .margin({ right: 10 })
        .onClick(() => {
          this.setOrientation(window.Orientation.USER_ROTATION_PORTRAIT);
          this.isLandscape = !this.isLandscape;
        });
      Text(this.title)
        .textAlign(TextAlign.Start)
        .fontFamily('HarmonyHeiTi-Medium')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(18)
        .fontColor(Color.White);
    }
    .padding({
      left: '3%',
      top: '2%',
    })
    .zIndex(10)
    .width(CommonConstants.FULL_PERCENT)
    .visibility(this.isLandscape ? Visibility.Visible : Visibility.Hidden);
  }

  playNextVideo() {
    if (TimeControl.timeControl()) {
      this.appPathStack.pop();
      return;
    }

    let globalVideoList = this.videoDetailInfo.videoCardDetail;

    let curIndex = this.index + PlayConstants.CONTROL_NEXT;
    if (curIndex === globalVideoList.length) {
      this.switchPlayOrPause();
      promptAction.showToast({
        message: PlayConstants.LAST_NUMBER,
        alignment: Alignment.Center,
      });
      return;
    }

    this.videoInfo = globalVideoList[curIndex];
    this.index = curIndex;
    this.title = this.videoInfo.title;
    this.videoUrl = this.videoInfo.videoUrl;
    let isVip = this.videoInfo.isVip;
    let vipInfo = GlobalContext.getContext().getObject(CommonConstants.IS_VIP) as boolean;

    if (isVip && !vipInfo) {
      if (this.isLandscape) {
        this.setOrientation(window.Orientation.USER_ROTATION_PORTRAIT);
        this.isLandscape = !this.isLandscape;
      }
      this.isShowVip = true;
    }
    this.controller.reset();
  }

  @Builder
  showVip() {
    Column() {
      Text('该视频内容为VIP会员专享，查看请先开通会员')
        .fontColor(Color.White)
        .padding({
          top: this.isLandscape ? 150 : 74,
          bottom: 30,
        });
      Button('开通会员')
        .width(this.isLandscape ? 100 : 80)
        .aspectRatio(2.57)
        .fontColor(Color.Black)
        .backgroundColor('#F8E6CF')
        .borderRadius(14)
        .onClick(() => {
          let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIP_PAGE_VIEW, this.videoInfo);
          this.appPathStack.pushDestination(pathInfo, true);
          return;
        });
    }
    .width(this.xComponentWidth)
    .height(this.xComponentHeight)
    .backgroundColor(Color.Black)
    .zIndex(1)
    .visibility(this.isShowVip ? Visibility.Visible : Visibility.Hidden);
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
  playControl() {
    RelativeContainer() {
      this.landScapeTitle();
      this.showVip();
      Row() {
        Image(this.status === PlayConstants.STATUS_START ?
        $r('app.media.ic_play') : $r('app.media.ic_pause'))
          .fillColor(Color.Black)
          .width($r('app.float.26vp'))
          .onClick(() => {
            this.switchPlayOrPause();
          });

        Text(DateFormatUtil.secondToTime(this.currentTime))
          .fontSize($r('app.float.14fp'))
          .fontColor(Color.White)
          .margin({ left: PlayConstants.PROGRESS_MARGIN_LEFT });

        Slider({
          value: this.currentTime,
          min: 0,
          max: this.totalTime,
          step: 1,
          style: SliderStyle.OutSet,
        })
          .blockColor(Color.White)
          .trackColor('#888888')
          .selectedColor(Color.White)
          .trackThickness(1)
          .layoutWeight(1)
          .margin({ left: '2.2%' })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.currentTime = value;
            this.controller.setCurrentTime(value, SeekMode.PreviousKeyframe);
          });

        Text(DateFormatUtil.secondToTime(this.totalTime))
          .fontSize($r('app.float.14fp'))
          .fontColor(Color.White)
          .margin({ left: PlayConstants.PROGRESS_MARGIN_LEFT });

        if (this.isLandscape) {
          Image($r('app.media.ic_video_menu_detail'))
            .width($r('app.float.24vp'))
            .margin({ left: PlayConstants.PROGRESS_MARGIN_LEFT })
            .onClick(() => {
              this.setOrientation(window.Orientation.USER_ROTATION_PORTRAIT);
              this.isLandscape = !this.isLandscape;
            });
        } else {
          Image($r('app.media.ic_video_menu_landscape_fullscreen'))
            .width($r('app.float.24vp'))
            .margin({ left: PlayConstants.PROGRESS_MARGIN_LEFT })
            .onClick(() => {
              this.setOrientation(window.Orientation.USER_ROTATION_LANDSCAPE);
              this.isLandscape = !this.isLandscape;
            });
        }
      }
      .padding({
        left: '2%',
        right: '4%',
      })
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
      });
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .zIndex(10);
  }
}

@ComponentV2
struct VideoCardDetailShow {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Param @Once @Require globalVideoList: Array<VideoCardDetail>;
  @Param @Once @Require controller: VideoController;

  build() {
    Column() {
      Row() {
        Text('选集')
          .fontWeight(FontWeight.Bold)
          .fontSize(24);
      }
      .margin({
        top: 20,
        left: 10,
      })
      .alignSelf(ItemAlign.Start);

      List({ space: '16vp' }) {
        ForEach(this.globalVideoList, (item: VideoCardDetail) => {
          ListItem() {
            VideoCardDetailItem({
              title: item.title,
              imageUrl: item.imageUrl,
              isVip: item.isVip,
            });
          }
          .padding({
            left: '4%',
            right: '4%',
          })
          .onClick(() => {
            let vipInfo = GlobalContext.getContext().getObject(CommonConstants.IS_VIP) as boolean;
            if (item.isVip && !vipInfo) {
              let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIP_PAGE_VIEW, item);
              this.appPathStack.pushDestination(pathInfo, true);
            } else {
              this.controller.pause();
              this.controller.stop();
              let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIDEO_PLAY_PAGE, item);
              this.appPathStack.replacePath(pathInfo, true);
            }
          });
        });
      }
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .lanes(2)
      .alignListItem(ListItemAlign.Center)
      .padding({
        top: 20,
      });
    }
    .padding({
      left: '3%',
      right: '3%',
    });
  }
}

@ComponentV2
struct VideoCardDetailItem {
  @Param @Require title: string;
  @Param @Require imageUrl: string;
  @Param @Require isVip: boolean;

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.imageUrl)
          .aspectRatio(1.78)
          .borderRadius(10);
        Image(this.isVip ? $r('app.media.icon_vip_top_start') : $r('app.media.icon_free_top_start'))
          .width('20%');
      };

      Text(this.title)
        .fontWeight(FontWeight.Medium)
        .fontSize(16);
    }
    .alignItems(HorizontalAlign.Start);
  }
}