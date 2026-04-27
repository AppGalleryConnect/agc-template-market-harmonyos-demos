import { AlertDialog } from '@kit.ArkUI';
import { WorkViewModel } from 'video_common';
import { VideoThumbnail } from './VideoThumbnail';
import { WorkListPageVM } from '../viewmodel/WorkListPageVM';

/**
 * @usage: 用于展示视频作品网格列表，支持多列布局和空数据展示。
 * 关键参数：works作品列表数组，isExpandedStatus展开状态，dialogControllerConfirm删除确认弹框控制器。
 * 包含if逻辑：当works列表有数据时显示网格列表，否则显示空数据提示。
 * @layout: 纵向排列。主体为List网格布局，根据展开状态显示3列或6列。
 * 空数据时显示图标和提示文本（居中对齐）。
 * @constraints:
 * @zhName: 视频网格列表
 * @fileType: component
 * @isGen: true
 * @component: VideoThumbnail
 */
@ComponentV2
export struct VideoGrid {
  vm: WorkListPageVM = WorkListPageVM.instance;
  @Param works: WorkViewModel[] = [];
  @Param isExpandedStatus: boolean = false;
  @Local listItemWidth: number = 98;
  // 删除确认弹框
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '提示',
      content: '确定要删除此作品吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.deleteWork()
        }
      },
    }),
  })

  build() {
    Column() {
      if (this.works.length) {
        Scroll() {
          GridRow({gutter: {x: 8}}) {
            ForEach(this.works, (videoWork: WorkViewModel, index: number) => {
              GridCol({
                span: {
                  xs: 4,
                  sm: 4,
                  md: 2,
                  lg: 2
                },
                offset: 0,
                order: 0
              }) {
                VideoThumbnail({
                  videoWork: videoWork,
                  deleteWork: () => {
                    this.vm.deleteId = videoWork.id;
                    // 打开删除确认弹框
                    this.dialogControllerConfirm.open()
                  }
                })
              }
            }, (videoWork: WorkViewModel) => videoWork.id)
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .alignSelf(ItemAlign.Start)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
      } else {
        this.emptyDataBuilder()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  emptyDataBuilder() {
    Column() {
      Image($r('app.media.no_data_icon'))
        .width(60)
        .objectFit(ImageFit.Cover)
      Text('暂无作品')
        .fontColor('#66000000')
        .fontSize(11)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
