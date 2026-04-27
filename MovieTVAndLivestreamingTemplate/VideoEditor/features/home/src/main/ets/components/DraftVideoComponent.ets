import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { DisplayModel, UserInfo } from 'common';
import { phoneRouterControl } from 'oh_router';
import { exportVideo, WorkListViewModel, WorkViewModel } from 'video_common';

@ComponentV2
export struct DraftVideoComponent {
  @Local workList: WorkListViewModel =
    PersistenceV2.connect(WorkListViewModel, 'WorkList', () => new WorkListViewModel())!;
  @Local listWidth: number = 0;
  @Local rowWidth: number = 0;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;

  // 获取草稿数据
  @Computed
  public get draftList(): WorkViewModel[] {
    return this.workList.getUnFinishWorkList();
  }

  // 判断是否展示暂无草稿
  @Computed
  public get isShowEmpty(): boolean {
    return this.rowWidth - this.listWidth > 76 / 2;
  }

  getPaddingH() {
    if (this.displayModel.isExpanded) {
      return 24
    } else {
      return 16
    }
  }


  build() {
    Row() {
      if (this.draftList.length) {
        List() {
          ForEach(this.draftList, (videoWork: WorkViewModel) => {
            ListItem() {
              // 视频缩略图
              Stack() {
                Image(videoWork.thumbnail)
                  .width(76)
                  .height(68)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                  .onClick(() => {
                    // 草稿-跳转视频编辑页面
                    let obj: exportVideo = JSON.parse(videoWork.routerParams);
                    obj.isVip = this.userInfo.isVIP
                    // phoneRouterControl.jumpPage({
                    //   pageName: 'VideoEditDetailPage',
                    //   builder: wrapBuilder(VideoEditDetailPageBuilder),
                    //   param: JSON.stringify(obj)
                    // })
                    phoneRouterControl.getRouter()
                      .pushPath({ name: 'VideoEditDetailPage', param: JSON.stringify(obj) });
                  })
                Text(videoWork.title)
                  .fontSize(10)
                  .fontColor(Color.White)
                  .borderRadius(4)
                  .margin({ left: 5, bottom: 6 })
              }
              .margin({ right: 8 })
              .borderRadius(12)
              .align(Alignment.BottomStart)
            }
          }, (videoWork: WorkViewModel) => videoWork.id)
        }
        .height(68)
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal) // 排列方向
        .alignListItem(ListItemAlign.Center)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .onAreaChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          this.listWidth = newValue.width as number;
        })

      }
      if (this.isShowEmpty) {
        Text('暂无草稿')
          .flexGrow(1)
          .height(68)
          .textAlign(TextAlign.Center)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.4)')
          .border({
            width: 1,
            style: BorderStyle.Dashed,
            color: 'rgba(255,255,255,0.2)',
            radius: 8,
            dashWidth: {
              top: 5,
              left: 5,
              bottom: 5,
              right: 5
            },
            dashGap: {
              top: 5,
              left: 5,
              bottom: 5,
              right: 5
            }
          })
      }
    }
    .width('100%')
    .padding({ top: 12, left: this.getPaddingH(), right: this.getPaddingH() })
    .onAreaChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.rowWidth = newValue.width as number - 32;
    })
  }
}
