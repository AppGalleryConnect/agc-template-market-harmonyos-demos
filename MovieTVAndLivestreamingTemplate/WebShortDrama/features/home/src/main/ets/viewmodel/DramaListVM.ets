import { RequestAPI } from '@agctemplate/server';
import { DramaInfo } from '@agctemplate/server';
import { FeedDramaListRes } from '@agctemplate/server';
import { appRouter, BaseResponse, container, Logger } from '@agctemplate/utils';
import { PlayController, VideoPlayDataSource } from 'video_swiper';
import { mapDramaItem } from '../mapper/DramaInfoMapper';
import { AppStorageV2 } from '@kit.ArkUI';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import { AppLinkingRouter, ContinueModel } from '@agctemplate/widgets';
import { AVPlayerState } from 'video_swiper/src/main/ets/constant/AVPlayerState';

const TAG = 'DramaListVM'

@ObservedV2
export class DramaListVM {
  @Trace ready: boolean = false
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  data: VideoPlayDataSource = new VideoPlayDataSource()
  @Trace appLinkRouter: AppLinkingRouter = AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
  playController: PlayController

  constructor(playController: PlayController) {
    this.playController = playController
  }

  @Monitor('continueModel.id')
  onContinueSceneChange() {
    this.checkContinueScene();
  }

  @Monitor('appLinkRouter.id')
  onAppLinkingClick() {
    this.checkAppLinkingScene();
  }

  async init() {
    try {
      let res: BaseResponse<FeedDramaListRes> = await container.resolve(RequestAPI).getFeedDramaList({
        pageSize: 1,
        pageNum: 20
      })
      let dramaListRes: FeedDramaListRes = new FeedDramaListRes(res.getBody());
      dramaListRes.feedDramaList?.map((dramaInfo: DramaInfo) => {
        this.data.pushData(mapDramaItem(dramaInfo));
      })
      this.ready = true
    } catch (e) {
      Logger.error(TAG, 'fetch dramaList failed')
    }
  }

  async refresh() {
    try {
      let res: BaseResponse<FeedDramaListRes> = await container.resolve(RequestAPI).getFeedDramaList({
        pageSize: 1,
        pageNum: 20
      })
      let dramaListRes: FeedDramaListRes = new FeedDramaListRes(res.getBody());
      this.data.replaceData(dramaListRes.feedDramaList?.map((dramaInfo: DramaInfo) => {
        return mapDramaItem(dramaInfo)
      }))
      this.ready = true
    } catch (e) {
      Logger.error(TAG, 'fetch dramaList failed')
    }
  }

  async checkContinueScene() {
    if (this.continueModel.id && this.continueModel.dramaId) {
      appRouter.push({
        builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
        params: {
          currentIndex: this.continueModel.currentIndex,
          playTime: this.continueModel.playTime,
          dramaInfo: new DramaInfo({ id: this.continueModel.dramaId }),
        }
      })
      this.continueModel.id = 0;
    }
  }

  checkAppLinkingScene() {
    if (this.appLinkRouter.id && this.appLinkRouter.dramaId) {
      let timeoutID = setInterval(() => {
        if (this.playController.getAVPlayer()?.state !== AVPlayerState.PAUSED) {
          this.playController!.pause()
        } else {
          clearTimeout(timeoutID)
        }
      }, 60);
      appRouter.back()
      let timeoutID2 = setInterval(() => {
        let isDetailShow = AppStorage.get('isDetailShow')!
        if (!isDetailShow) {
          appRouter.push({
            builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
            params: {
              currentIndex: this.appLinkRouter.dramaIndex,
              playTime: 0,
              dramaInfo: new DramaInfo({ id: this.appLinkRouter.dramaId }),
            }
          })
          clearTimeout(timeoutID2)
        }
      }, 60);
      this.appLinkRouter.id = 0;
    }
  }
}