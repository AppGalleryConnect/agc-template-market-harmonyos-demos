import { CommonHeader, DisplayModel } from 'common';
import { VideoModel } from 'video_common'
import { OfflineVideoDownload } from 'offline_video_download';
import { VideoInfo } from 'offline_video_download/src/main/ets/CommonConstants';
import { OHPage, phoneRouterControl } from 'oh_router';
import { OfflineVideoListPageVM } from '../viewmodel/OfflineVideoListPageVM';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * @usage: 用于展示离线视频列表页面，支持下载中和已下载两个标签页切换，支持编辑模式下的多选删除。
 * 关键参数：vm.currentTab当前标签页索引，vm.isEdit编辑模式状态，vm.selectedVideos已选视频集合。
 * 包含if逻辑：当视频列表有数据时显示列表，否则显示空状态提示；当isEdit为true时显示编辑模式底部操作栏。
 * @layout: 页面整体采用垂直布局（Column）。顶部为CommonHeader和编辑按钮（右对齐），
 * 下方为标签页切换（横向排列，左对齐），中间为视频列表或空状态，底部为编辑模式操作栏（横向排列）。
 * @constraints:
 * @zhName: 离线视频列表页
 * @fileType: page
 * @isGen: true
 * @subPage:
 * @image: screenshot/home/download.jpg
 * @component: CommonHeader,OfflineVideoDownload,OHPage
 */
@ComponentV2
export struct OfflineVideoListPage {
  vm: OfflineVideoListPageVM = new OfflineVideoListPageVM();
  @Local videoState: VideoModel = AppStorageV2.connect<VideoModel>(VideoModel, () => new VideoModel())!;
  @Local displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;

  aboutToAppear(): void {
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      pageBackgroundColor: this.videoState.isPlaying ? '#0D0C11' : $r('sys.color.comp_background_gray')
    })
  }

  getPaddingH() {
    if (this.displayModel.isExpanded) {
      return 24
    } else {
      return 16
    }
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      if (!this.videoState.isPlaying) {
        Stack({ alignContent: Alignment.End }) {
          CommonHeader({
            title: '离线视频',
            onReturnClick: () => {
              phoneRouterControl.popPage();
            },
          }).padding({ left: this.getPaddingH() })
          Text(this.vm.isEdit ? '取消' : '编辑')
            .margin({ right: this.getPaddingH() })
            .fontColor('#80000000')
            .onClick(() => {
              if (this.vm.isEdit) {
                this.vm.exitEditMode();
              } else {
                this.vm.isEdit = true;
              }
            })
        }

        Row() {
          Column() {
            Text('下载中')
              .fontSize(16)
              .fontColor(this.vm.currentTab === 0 ? '#000' : 'rgba(0,0,0,0.6)')
              .fontWeight(this.vm.currentTab === 0 ? FontWeight.Medium : FontWeight.Normal)
          }
          .onClick(() => {
            this.vm.currentTab = 0;
            this.vm.exitEditMode();
          })
          .margin({ right: 24 })

          Column() {
            Text('已下载')
              .fontSize(16)
              .fontColor(this.vm.currentTab === 1 ? '#000' : 'rgba(0,0,0,0.6)')
              .fontWeight(this.vm.currentTab === 1 ? FontWeight.Medium : FontWeight.Normal)
          }
          .onClick(() => {
            this.vm.currentTab = 1;
            this.vm.exitEditMode();
          })
        }
        .padding({
          left: this.getPaddingH(),
          right: this.getPaddingH(),
          top: 22,
          bottom: 22
        })
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }

      // 视频列表或空状态
      if (this.vm.getFilteredVideos().length > 0) {
        List() {
          ForEach(this.vm.getFilteredVideos(), (item: VideoInfo) => {
            ListItem() {
              Row() {
                // 编辑模式下显示复选框
                if (this.vm.isEdit) {
                  Checkbox({ name: item.id })
                    .select(this.vm.isVideoSelected(item.id))
                    .margin({ right: 16, bottom: 16 })
                    .onClick(() => {
                      this.vm.toggleVideoSelection(item.id);
                    })
                    .width(16)
                    .height(16)
                }

                // 视频组件
                OfflineVideoDownload({
                  videoInfo: item,
                  isEditMode: this.vm.isEdit
                })
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
          }, (item: VideoInfo) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: this.getPaddingH(), right: this.getPaddingH() })
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      } else {
        // 空状态提示
        Column() {
          Text(this.vm.currentTab === 0 ? '暂无下载中的视频' : '暂无已下载的视频')
            .fontSize(14)
            .fontColor('rgba(0,0,0,0.4)')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // 编辑模式底部操作栏
      if (this.vm.isEdit) {
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.comp_divider'))
        Row() {
          // 全选按钮
          Text('全选')
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .fontColor('rgba(30, 36, 44, 1)')// this.vm.isAllSelected() ? '#FF0A59F7' : 'rgba(30, 36, 44, 1)')
            .onClick(() => {
              this.vm.toggleSelectAll();
            })
            .layoutWeight(1)

          // 删除按钮
          Text(this.vm.selectedVideos.size > 0 ? `删除(${this.vm.selectedVideos.size})` : '删除')
            .width(60)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
            .fontSize(16)
            .fontColor('#fff')
            .fontColor('rgba(255, 75, 75, 1)')
            .enabled(this.vm.selectedVideos.size > 0)
            .onClick(() => {
              if (this.vm.selectedVideos.size > 0) {
                // 显示确认对话框
                AlertDialog.show({
                  title: '确认删除',
                  message: `确定要删除选中的 ${this.vm.selectedVideos.size} 个视频吗？`,
                  primaryButton: {
                    value: '取消',
                    action: () => {
                    }
                  },
                  secondaryButton: {
                    value: '删除',
                    fontColor: Color.Red,
                    action: () => {
                      this.vm.deleteSelectedVideos();
                    }
                  }
                });
              }
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}


@Builder
export function OfflineVideoListPageBuilder() {
  OfflineVideoListPage()
}
