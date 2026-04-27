import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { PlayController, PlaySession, VideoPlayData, VideoSwiper } from '@agctemplate/video_swiper';
import { AppStorageV2 } from '@kit.ArkUI';
import { AiBarHeight, AppStorageKeys, BreakPoint, BreakPointValue, StatusBarHeight } from '@agctemplate/widgets';
import { DetailItemListVM } from '../viewModels/DetailItemListVM';
import { DetailPageComponent } from '../components/DetailPageComponent';
import { PreferConstant } from '@agctemplate/utils';
import { preferences } from '@kit.ArkData';

const TAG = '[DetailPage]'

@Entry
@ComponentV2
export struct DetailPage {
  @Local vm: DetailItemListVM = DetailItemListVM.instance
  playController: PlayController = new PlayController()
  private dataPreferences: preferences.Preferences | null = null
  @Local curIndex: number = 0
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;

  aboutToAppear() {
    this.dataPreferences =
      preferences.getPreferencesSync(this.getUIContext().getHostContext(), { name: PreferConstant.BACKGROUND_PLAY })
    this.playController.allowBackground = this.dataPreferences.getSync('backgroundPlay', false) as boolean
    let temp = RouterModule.getNavParam({ url: RouterMap.DETAIL_PAGE });
    if (temp) {
      this.curIndex = Number(temp) - 1;
    }
    this.vm.init();
  }

  build() {
    NavDestination() {
      if (this.vm.ready) {
        Stack({ alignContent: Alignment.Bottom }) {
          // 视频切换组件
          VideoSwiper({
            playController: this.playController,
            videoPlayDataSource: this.vm.data,
            contentBuilder: wrapBuilder(detailPageComponent),
            currentVideoIndex: this.curIndex
          })
            .width('100%')
            .height('100%')
        }
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
    .onBackPressed((): boolean => {
      return this.playController.backPressListener().onBackPress()
    })
  }
}

export function jumpDetailPage(liveInfo: string, callback?: (popInfo: PopInfo) => void) {
  if (PlayController.onStopPip) {
    PlayController.onStopPip()
  }
  RouterModule.push({ url: RouterMap.DETAIL_PAGE, onPop: callback })
}

@Builder
export function detailPageComponent(videoData: VideoPlayData, playControl: PlayController,
  playerSession: PlaySession) {

  DetailPageComponent({
    videoData: videoData,
    playControl: playControl,
    playerSession: playerSession
  })
}

@Builder
export function DetailPageBuilder() {
  DetailPage();
}