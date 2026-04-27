import { BarVM, TValueType } from 'video_common';
import { SubtitlesSingleRow } from '../components/SubtitlesSingleRow';
import { VideoEditNavigationBar } from '../components/VideoEditNavigationBar';
import { SubtitlesSingleModel } from '../model/SubtitlesSingleModel';
import { CreateSubtitlesVM } from '../viewmodel/CreateSubtitlesVM';

/**
 * @usage: 字幕创建页面，用于新建和管理视频字幕列表
 * @layout: 单列布局，顶部导航栏+新建字幕按钮+字幕列表
 * @isGen: true
 * @fileType: page
 * @zhName: 创建字幕页面
 * @domain: 视频
 * @subPage: EditSubtitlesPage
 * @component: SubtitlesSingleRow, VideoEditNavigationBar
 */
@Builder
export function CreateSubtitlesPageBuilder(_name: string, param: TValueType) {
  CreateSubtitlesPage({
    subParams: param
  });
}

@ComponentV2
export struct CreateSubtitlesPage {
  vm: CreateSubtitlesVM = new CreateSubtitlesVM();
  @Param subParams: TValueType = null

  aboutToAppear(): void {
    this.vm.initParam(this.subParams);
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      VideoEditNavigationBar({
        onClickEvent: () => {
          this.vm.backPage()
        }
      })
      Blank().height(8)

      Text('字幕')
        .width('100%')
        .height(56)
        .fontColor(Color.White)
        .fontSize(20)
        .textAlign(TextAlign.Start)
        .padding({ left: 16 })

      Row() {
        Column() {
          Image($r('app.media.ic_public_add_norm_filled'))
            .width(32)
            .aspectRatio(1)

          Text('新建字幕')
            .height(39)
            .fontColor(Color.White)
            .fontSize(16)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
        .backgroundColor(0x33ffffff)
        .borderRadius($r('sys.float.corner_radius_level4'))
        .onClick(() => this.vm.createSubtitles())
      }
      .width('100%')
      .height(130)
      .padding({ left: 16, right: 16 })

      Blank().height(16)

      Column() {
        List({ scroller: this.vm.scroller, space: 16 }) {
          Repeat<SubtitlesSingleModel>(this.vm.subtitlesList)
            .each((ri: RepeatItem<SubtitlesSingleModel>) => {
              ListItem() {
                SubtitlesSingleRow({
                  subtitlesModel: ri.item,
                  onDeleteClick: () => {
                    this.vm.deleteSubtitles(ri.index);
                  },
                  onEditClick: () => {
                    this.vm.editSubtitles(ri.index);
                  }
                });
              }
            })
            .key((item: SubtitlesSingleModel, index: number): string => item.keyId + '_' + index)
            .virtualScroll({
              totalCount: this.vm.subtitlesList.length
            })
            .templateId((_chatVM: SubtitlesSingleModel): string => {
              return '';
            })
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width('100%')
      .visibility(this.vm.subtitlesList.length > 0 ? Visibility.Visible : Visibility.Hidden)
      .layoutWeight(1)
      .backgroundColor('#FF192533')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: BarVM.instance.aiBarH
      })
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#FF000000', 0.0], ['#FF19283F', 1]]
    })
  }

  build() {
    NavDestination() {
      this.render();
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .onBackPressed(() => {
      this.vm.backPage()
      return true
    })
    .onReady(async (ctx: NavDestinationContext) => {
      this.vm.stack = ctx.pathStack;
    })
  }
}
