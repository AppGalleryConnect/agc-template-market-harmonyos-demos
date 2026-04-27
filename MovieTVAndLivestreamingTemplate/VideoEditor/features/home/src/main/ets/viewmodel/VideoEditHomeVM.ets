import { AppStorageV2, display, PersistenceV2 } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { DisplayModel, BreakpointModel, BreakpointNameEnum, UserInfo, } from 'common';
import { phoneRouterControl } from 'oh_router';
import { VideoSizeData } from 'video_edit/src/main/ets/model/VideoSizeData';
import { getVideoData, judgeVideoLegality } from 'video_edit/src/main/ets/utils/CommonUtils';
import { MyDataSource } from '../model/HomePageModel';

@ObservedV2
export class VideoEditHomeVM {
  @Trace displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  gradientColor: LinearGradient =
    { direction: GradientDirection.Bottom, colors: [['#FF999999', 0.0], ['#FF666666', 1.0]] }
  swiperData: MyDataSource = new MyDataSource([]);

  init() {
    // 根据屏幕宽度断点选择轮播图资源：
    let swiperRes: Resource = this.getSwiperImg();
    let list: Resource[] = [];
    for (let i = 1; i <= 4; i++) {
      list.push(swiperRes);
    }
    this.swiperData = new MyDataSource(list);
  }

  getSwiperImg() {
    // 根据屏幕宽度断点选择轮播图资源：
    const bp = this.breakPointModel.currentBreakpoint;
    let displayInfo = display.getDefaultDisplaySync();
    let width = px2vp(displayInfo.width)
    let swiperRes: Resource = $r('app.media.straight_swiper_img');
    if (bp === BreakpointNameEnum.SM && width < 440) {
      swiperRes = $r('app.media.straight_swiper_img');
    } else if (bp === BreakpointNameEnum.SM && width >= 440) {
      swiperRes = $r('app.media.wide_swiper_img');
    } else {
      swiperRes = $r('app.media.fold_able_swiper_img');
    }
    return swiperRes;
  }

  openVideoAlbum(mContext: UIContext, selectedVideoUri: string) {
    let photoSelectOptions: photoAccessHelper.PhotoSelectOptions =
      new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    photoSelectOptions.maxSelectNumber = 1;
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions)
      .then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        selectedVideoUri = photoSelectResult.photoUris[0]
        if (selectedVideoUri !== '' && selectedVideoUri &&
          photoSelectResult.photoUris.length > 0) {
          let videoSize: VideoSizeData = await getVideoData(selectedVideoUri)
          if(judgeVideoLegality(videoSize,0)){
            let str = JSON.stringify({ url: selectedVideoUri, isVip: this.userInfo.isVIP })
            phoneRouterControl.getRouter().pushPath({
              name: 'VideoEditDetailPage',
              param: str
            });
          }else {
            mContext.getPromptAction().showToast({message: '暂不支持4K或时长超过5分钟的视频'})
          }
        }
      })
  }
}