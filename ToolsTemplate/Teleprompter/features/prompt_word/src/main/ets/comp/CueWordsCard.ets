import { CueWordsItem } from '../viewmodel/CueWordsItemModel';

/**
 * @usage: 用于在提词列表中展示单个提词信息的卡片组件。关键数据结构：CueWordsItem（提词数据模型）。包含条件渲染：点击省略号图标时
 * showSheet变为true显示操作面板。提供三个事件回调：editClick编辑事件、startClick开始提词事件、deleteClick删除事件
 * @layout: 卡片整体采用垂直布局(Column),从上到下分为三行：第一行为横向布局(Row), 左侧展示提词标题，右侧展示省略号操作图标，两端对齐
 * 第二行展示提词内容摘要。第三行为横向布局(Row),左侧展示创建时间，右侧展示"开始提词"按钮，两端对齐。操作面板通过bindSheet绑定，
 * 包含编辑、删除、取消三个操作项纵向排列
 * @constraints: editClick、startClick、deleteClick为必需的事件回调
 * @domain: 工具
 * @isGen: true
 * @fileType: component
 * @zhName: 提词卡片组件
 * @component:
 * @image: screenshots/prompt_word/CueWordsCard.jpg
 */

@ComponentV2
export struct CueWordsCard {
  @Param data: CueWordsItem = new CueWordsItem('', '', '', '');
  @Local showSheet: boolean = false
  @Event editClick: (data: CueWordsItem) => void = (data: CueWordsItem) => {
  };
  @Event startClick: (data: CueWordsItem) => void = (data: CueWordsItem) => {
  };
  @Event deleteClick: (data: CueWordsItem) => void = (data: CueWordsItem) => {
  };

  @Builder
  editSheetBuilder() {
    Column() {
      Text('编辑')
        .fontSize(16)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .padding({ top: 20, bottom: 20 })
        .onClick(() => {
          this.showSheet = false
          this.editClick(this.data)
        })
      Row().width('100%').height(1).backgroundColor('#E8EAEF')
      Text('删除')
        .fontSize(16)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .padding({ top: 20, bottom: 20 })
        .margin({ bottom: 24 })
        .onClick(() => {
          this.showSheet = false
          this.deleteClick(this.data)
        })
      Row() {
        Text('取消')
          .layoutWeight(1)
          .padding({ top: 17, bottom: 17 })
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontColor('#0A59F7')
          .border({ width: 1, color: '#0A59F7' })
          .borderRadius(8)
          .onClick(() => {
            this.showSheet = false
          })
      }
      .width('100%')
      .padding({ left: 13, right: 13 })
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({
      bottom: 42,
      left: 16,
      right: 16,
      top: 20
    })
  }

  build() {
    Column() {
      Row({ space: 15 }) {
        Text(this.data?.title)
          .fontSize(18)
          .fontColor('rgba(0, 0, 0, 0.90)')
          .maxLines(1)
          .layoutWeight(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Image($r('app.media.ellipsis_icon'))
          .width(24)
          .height(12)
          .onClick(() => {
            this.showSheet = true
          })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })

      Text(this.data?.content)
        .fontSize(12)
        .lineHeight(18)
        .fontColor('rgba(0, 0, 0, 0.60)')
        .width('100%')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ minHeight: 54 })
        .align(Alignment.TopStart)

      Row() {
        Text(this.data?.time)
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.40)')
        Row({ space: 5 }) {
          Image($r('app.media.play_circle'))
            .width(16)
            .height(16)
          Text('开始提词')
            .fontSize(13)
            .fontColor('#fff')
            .onClick(() => {
              this.startClick(this.data)
            })
        }
        .padding({
          top: 6,
          bottom: 6,
          left: 8,
          right: 8
        })
        .borderRadius(14)
        .backgroundColor('#0A59F7')
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 6 })

    }
    .layoutWeight(1)
    .padding(12)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(8)
    .backgroundColor('#fff')
    .bindSheet($$this.showSheet, this.editSheetBuilder(), {
      height: 250,
      backgroundColor: $r('sys.color.background_secondary'),
      showClose: false,
      maskColor: $r('sys.color.mask_fourth'),
    })
  }
}
