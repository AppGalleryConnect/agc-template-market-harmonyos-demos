import { RouterMap, RouterModule } from 'commonlib';

@ObservedV2
export class VideoViewVm {
  @Trace changeFontSize: number = 0;
  private static _instance: VideoViewVm;


  public static get instance() {
    if (!VideoViewVm._instance) {
      VideoViewVm._instance = new VideoViewVm();
    }
    return VideoViewVm._instance;
  }

  public initData() {
    const param = RouterModule.getNavParam<number>({ url: RouterMap.VIDEO_DETAIL_PAGE });
    if (param) {
    }
  }

}
