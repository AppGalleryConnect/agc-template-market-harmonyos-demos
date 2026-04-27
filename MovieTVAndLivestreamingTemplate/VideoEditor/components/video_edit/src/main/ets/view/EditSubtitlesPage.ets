import { BarVM, TValueType } from 'video_common';
import { VideoEditNavigationBar } from '../components/VideoEditNavigationBar';
import { EditSubtitlesVM } from '../viewmodel/EditSubtitlesVM';

/**
 * @usage: 字幕编辑页面，用于编辑单条字幕内容和时间范围
 * @layout: 单列布局，顶部导航栏+字幕文本输入框+时间选择器+保存按钮
 * @isGen: true
 * @fileType: page
 * @zhName: 编辑字幕页面
 * @domain: 视频
 * @component: VideoEditNavigationBar
 */
@Builder
export function EditSubtitlesPageBuilder(_name: string, param: TValueType) {
  EditSubtitlesPage({
    pageParams: param
  });
}

@ComponentV2
export struct EditSubtitlesPage {
  vm: EditSubtitlesVM = new EditSubtitlesVM();
  @Param pageParams: TValueType = null

  aboutToAppear(): void {
    this.vm.initParam(this.pageParams);
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

      Row() {
        Column() {
          TextArea({
            text: this.vm.subtitlesModel.content
          })
            .fontSize(14)
            .width('100%')
            .layoutWeight(1)
            .fontColor(Color.White)
            .caretColor($r('sys.color.font_emphasize'))
            .backgroundColor(Color.Transparent)
            .maxLength(30)
            .showCounter(false)
            .id('subtitles_text_area')
            .onChange(value => {
              this.vm.subtitlesModel.content = value
            })

          Text('最多30字')
            .height(30)
            .fontColor(0x66ffffff)
            .fontSize(10)
            .padding({ right: 12 })
        }
        .alignItems(HorizontalAlign.End)
        .justifyContent(FlexAlign.End)
        .width('100%')
        .height('100%')
        .padding({ top: 12 })
        .backgroundColor(0x33ffffff)
        .borderRadius($r('sys.float.corner_radius_level4'))
      }
      .width('100%')
      .height(130)
      .padding({ left: 16, right: 16 })

      Blank().height(8)

      Row() {
        Text(this.vm.subtitlesModel.startTime)
          .width(64)
          .fontColor(this.vm.timeIndex === 1 ? 0x01FCEA : 0x99ffffff)
          .height('100%')
          .fontSize(12)
          .backgroundColor('#192533')
          .borderColor(this.vm.timeIndex === 1 ? '#01FCEA' : Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level2'))
          .borderWidth(1)
          .textAlign(TextAlign.Center)
          .onClick(() => this.vm.selectStartTime(this.getUIContext()))

        Blank().width(16)

        Blank()
          .height('1vp')
          .color(0x99ffffff)
          .width(6)

        Blank().width(16)

        Text(this.vm.subtitlesModel.endTime)
          .width(64)
          .fontColor(this.vm.timeIndex === 2 ? 0x01FCEA : 0x99ffffff)
          .textAlign(TextAlign.Center)
          .height('100%')
          .borderColor(this.vm.timeIndex === 2 ? '#01FCEA' : Color.Transparent)
          .fontSize(12)
          .backgroundColor('#192533')
          .borderRadius($r('sys.float.corner_radius_level2'))
          .borderWidth(1)
          .onClick(() => this.vm.selectEndTime(this.getUIContext()))
      }
      .width('100%')
      .height(28)
      .padding({ left: 16, right: 16 })

      Blank()
        .layoutWeight(1)
        .onClick(() => this.getUIContext().getFocusController().clearFocus())

      Row() {
        Text('保存')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(40)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#FF01A8FE', 0.0], ['#FF01FCEA', 1]]
          })
          .onClick(() => this.vm.saveSubtitles(this.getUIContext()))
      }
      .width('100%')
      .height(40 + BarVM.instance.aiBarH)
      .alignItems(VerticalAlign.Top)
      .padding({
        left: 16,
        right: 16
      })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#FF000000', 0.0], ['#FF19283F', 1]]
    })

    Text(this.screenshotContent)
      .textAlign(TextAlign.Center)
      .width('auto')
      .height('auto')
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .lineHeight(30)
      .fontColor(Color.White)
      .backgroundColor(Color.Transparent)
      .textShadow({
        radius: 6,
        color: Color.Black
      })
      .padding({ left: 6, right: 6 })
      .id('editTextSubTitle')
  }

  build() {
    NavDestination() {
      this.render();
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.vm.backPage()
      return true
    })
    .hideBackButton(true)
    .onReady(async (ctx: NavDestinationContext) => {
      this.vm.stack = ctx.pathStack;
    })
  }

  @Computed
  get screenshotContent() {
    const content = this.vm.subtitlesModel.content;
    if (content.length > 15) {
      return content.slice(0, 15) + '\n' + content.slice(15, content.length)
    } else {
      return content;
    }
  }
}
