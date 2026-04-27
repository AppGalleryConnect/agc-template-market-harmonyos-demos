import { AppStorageV2, PersistenceV2, window } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import { BreakpointModel, RouterMap, UserInfo, WindowPopManager } from 'common';
import { exportVideo, WorkViewModel } from 'video_common';
import { WorkListPageVM } from '../viewmodel/WorkListPageVM';
import { WorkDetailPageBuilder } from '../view/WorkDetailPage';
import { MoreSheetContentBuilderView } from './MoreSheetContentBuilder';

/**
 * @usage: 用于展示视频缩略图卡片，包含缩略图、时长标签、标题和更多操作按钮。
 * 支持点击跳转详情页或编辑页，支持弹出更多操作和元数据模态框。
 * 关键参数：videoWork作品视图模型，isShowMore更多操作弹窗状态，isShowDetail元数据弹窗状态。
 * 包含if逻辑：根据videoWork.status判断跳转到详情页还是编辑页。
 * @layout: 纵向排列。顶部为Stack布局的缩略图和时长标签（左下角对齐），
 * 底部为标题和更多按钮的横向排列（两端对齐）。
 * @constraints:
 * @zhName: 视频缩略图卡片
 * @fileType: component
 * @isGen: true
 * @subPage: WorkDetailPage,VideoEditDetailPage
 */
@ComponentV2
export struct VideoThumbnail {
  vm: WorkListPageVM = WorkListPageVM.instance;
  @Local isShowMore: boolean = false;
  @Local isShowDetail: boolean = false;
  @Param videoWork: WorkViewModel = new WorkViewModel()
  @Event deleteWork: () => void = () => {
  };
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local openDetail: string = 'openDetail'
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local subWindow?: window.Window;

  // 点击视频缩略图
  private onThumbnailClick() {
    if (this.videoWork.status === 'finish') {
      // 视频作品-跳转到作品详情页
      phoneRouterControl.jumpPage({
        pageName: RouterMap.WORK_DETAIL_PAGE,
        builder: wrapBuilder(WorkDetailPageBuilder),
        param: this.videoWork.id
      })
    } else {
      // 草稿-跳转视频编辑页面
      let obj: exportVideo = JSON.parse(this.videoWork.routerParams);
      obj.isVip = this.userInfo.isVIP
      phoneRouterControl.getRouter().pushPath({ name: 'VideoEditDetailPage', param: JSON.stringify(obj) });
    }
  }

  @Monitor('breakPointModel.currentBreakpoint')
  thumbnailCheckBreakpoint() {
    try {
      if (this.subWindow?.isWindowShowing()) {
        WindowPopManager.destroyWindow(this.openDetail).then(() => {
          this.showThumbnailWindow();
        });
      }
    } catch (err) {
    }
  }

  async showThumbnailWindow() {
    this.subWindow = await WindowPopManager.showWindow({
      name: this.openDetail,
      builder: wrapBuilder(MoreSheetContentBuilderView),
      showMask: true, // 显示蒙层
      autoCancel: false,
      attachParam: this.videoWork,
      onBackPress: () => {
        // 拦截返回键
      },
      align: this.breakPointModel.getWindowAlignment()
    })
  }

  // 模态框回调
  sheetCallback(type: string) {
    // 打开第二个查看元数据模态框
    if (type === 'openDetail') {
      this.isShowDetail = true;
    } else if (type === 'delete') {
      // 删除选中的数据后关闭第一个模态框
      this.deleteWork();
      this.isShowMore = false
    }
  }

  build() {
    Column() {
      // 视频缩略图
      Stack() {
        Image(this.videoWork.thumbnail)
          .width('100%')
          .aspectRatio(1)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            this.onThumbnailClick();
          })
        // 时长标签
        Text(this.videoWork.duration)
          .fontSize(10)
          .fontColor(Color.White)
          .padding({
            right: 6,
            top: 2,
            bottom: 2
          })
          .textShadow({ radius: 2, color: '#80000000' })
          .borderRadius(4)
          .margin({ left: 8, bottom: 6 })
      }
      .borderRadius(12)
      .align(Alignment.BottomStart)

      Row() {
        Text(this.videoWork.title)
          .fontColor('#CC000000')
          .fontSize(12)
        Image($r('app.media.work_more_icon'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Cover)

      }
      .width('100%')
      .padding({ top: 8 })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.showThumbnailWindow();
      })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}
