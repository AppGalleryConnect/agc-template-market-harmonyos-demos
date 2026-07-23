import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel, WindowModel } from 'lib_common';
import { LoginSheetUtils } from 'lib_account';
import { TabPageType } from '../types/Index';
import { VideoSwiperPage } from './VideoSwiperPage';

@ComponentV2
export struct FollowPage {
  // tab页面的index
  @Param index: number = 0
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 0;
  @Local isShown: boolean = false;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  build() {
    Column() {
      if (this.userInfoModel.isLogin) {
        VideoSwiperPage({
          index: this.index,
          currentTabIndex: this.currentTabIndex,
          pageType: TabPageType.FOLLOW,
          isShown: this.isShown
        })
      } else {
        this.logoutView()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .backgroundColor('#000')
    .justifyContent(FlexAlign.Center)
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 1.0) {
        this.isShown = true;
      }
      if (!isExpanding && currentRatio <= 0.0) {
        this.isShown = false;
      }
    })
  }

  @Builder
  logoutView() {
    Column({space: 20}) {
      Image($r('app.media.ic_follow_list'))
        .width(60)
        .height(55)

      Text('暂未登录，登录后查看关注内容')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))

      Button('登录', { type: ButtonType.Normal, stateEffect: true })
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .backgroundColor('#505050')
        .width('33%')
        .onClick(() => {
          LoginSheetUtils.jumpLoginPage();
        })
    }
  }
}