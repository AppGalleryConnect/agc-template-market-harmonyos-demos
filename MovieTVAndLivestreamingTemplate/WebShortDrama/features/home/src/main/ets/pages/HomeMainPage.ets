import { VideoSwiper, PlayController, NetWorkModel, NetworkUtil } from 'video_swiper';
import { DramaDesComponent } from '../components/DramaDes';
import { PlayErrorLayer } from '../components/PlayErrorLayer';
import { DramaListVM } from '../viewmodel/DramaListVM';
import { emitter } from '@kit.BasicServicesKit';
import { Logger } from '@agctemplate/utils';
import { notificationManager } from '@kit.NotificationKit';
import { PushUtils } from '@agctemplate/widgets';
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit';
import { AVPlayerState } from 'video_swiper/src/main/ets/constant/AVPlayerState';

const TAG = 'HomeMainPage'

@ComponentV2
export struct HomeMainPage {
  @Param @Require index: number;
  @Consumer('curTabIndex') curTabIndex: number = 0;
  @Local noFlash: boolean = true
  playController: PlayController = new PlayController()
  @Local vm: DramaListVM = new DramaListVM(this.playController)

  @Monitor('curTabIndex')
  onIndexChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      Logger.debug(TAG, `${path} change from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
      if (path === 'curTabIndex') {
        let curIndex = monitor.value(path)?.now as number
        if (this.index === curIndex) {
          this.playController.play();
        } else {
          this.playController.pause()
          setTimeout(()=>{
            if(this.index !== curIndex){
              this.playController.pause()
            }
          },1000)
        }
      }
    })
  }

  aboutToAppear(): void {
    Logger.info(TAG, 'main aboutToAppear')
    this.getDeleteEmitter()
    this.getDetailInfoFavoriteEmitter()
    this.getSideFavoriteEmitter()
    setTimeout(() => {
      this.noFlash = false;
    }, 1000);
    this.vm.init().then(() => {
      let requestEnableNotificationCallback = (err: BusinessError): void => {
        if (err) {
          console.error(`requestEnableNotification fail: ${JSON.stringify(err)}`);
        } else {
          PushUtils.randomPushMessage(this.vm.data)
          console.info('requestEnableNotification success');
        }
      };
      try {
        notificationManager.requestEnableNotification(this.getUIContext().getHostContext() as common.UIAbilityContext,
          requestEnableNotificationCallback)
      } catch (e) {
      }
      if (AppStorage.get('pushCardEntry')) {
        let dramaData = AppStorage.get('pushCardEntry') as string
        // let routerParams: DramaInfo = {
        //   id: dramaData
        // }
        // jumpDetailPage(routerParams ,0, 0, () => {
        //   WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
        // })
        AppStorage.setOrCreate('isPushCardEntry', '')
      }
    })
    this.playController.autoPlay = false
    this.vm.checkContinueScene();
    this.vm.checkAppLinkingScene();
    AppStorage.setOrCreate('isDetailShow',false)
  }

  getDeleteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 6
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      // this.vm.refresh()
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  getDetailInfoFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.refresh()
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  getSideFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 7
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.refresh()
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  build() {
    if (this.vm.ready) {
      Stack({ alignContent: Alignment.Bottom }) {
        // 视频切换组件
        VideoSwiper({
          playController: this.playController,
          videoPlayDataSource: this.vm.data,
          contentBuilder: wrapBuilder(DramaDesComponent),
          refresh: () => {
            this.vm.refresh()
          },
          loadMore: () => {
            this.vm.init()
          },
          inPage: 'Home'
        })
          .width('100%')
          .height('100%')
      }
      .padding({ top: 56 , bottom: 100 })
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    } else if (!this.noFlash) {
      PlayErrorLayer({ vm: this.vm })
    }
  }
}

@Builder
export function HomeMainPageBuilder(index: number) {
  HomeMainPage({
    index: index
  })
}