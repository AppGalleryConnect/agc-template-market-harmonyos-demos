import { BreakpointModel } from 'common';

/**
 * @usage: 翻译首页功能卡片组件，展示文档翻译、语音翻译、拍照翻译三个功能入口。根据设备类型（折叠屏/普通屏）显示不同样式的卡片。
 * 主要数据结构包括BreakpointModel（断点模型）、回调函数（onVoiceInputClick、onDocumentClick、onCameraClick）。
 * 包含if逻辑判断折叠屏状态以显示不同样式的卡片。
 * @layout: 根据isFoldScreen状态切换布局：折叠屏使用foldScreenCard（带独立图标），普通屏使用phoneCard（背景图包含图标）。
 * 整体为Row横向布局，三个卡片等分宽度，每个卡片为Stack堆叠布局（背景图+左上角文字+右下角图标）。
 * @constraints: 需要提供对应的背景图片资源和图标资源
 * @domain: 翻译工具
 * @zhName: 翻译首页功能卡片组件
 * @isGen: true
 * @modifiable: 功能卡片区域包含语音翻译、拍照翻译、文档翻译三个功能可供选择，需要根据用户的需求去删除
 * @fileType: component
 * @image: screenshot/translateHomeFunctionCards.png
 */
@ComponentV2
export struct TranslateHomeFunctionCards {
  @Param isFoldScreen: boolean = false; // 是否为折叠屏
  @Param breakpointModel: BreakpointModel = new BreakpointModel();
  @Event onVoiceInputClick: () => void = () => {
  };
  @Event onDocumentClick: () => void = () => {
  };
  @Event onCameraClick: () => void = () => {
  };

  @Builder
  functionCard(title: string, subtitle: string, imageRes: Resource, onClick: () => void) {
    Stack({ alignContent: Alignment.Center }) {
      Image(imageRes)
        .width('100%')
        .height(80)
        .objectFit(ImageFit.Fill)
        .borderRadius(16)

      Column({ space: 8 }) {
        Text(title)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
        Text(subtitle)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor('rgba(255, 255, 255, 0.9)')
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .onClick(onClick)
  }

  build() {
    if (this.isFoldScreen) {
      // 折叠屏
      Row({ space: 12 }) {
        Column() {
          this.functionCard('文档翻译', '学习办公好帮手', $r('app.media.translation_foldables1'), this.onDocumentClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('语音翻译', '实时录音 边说边译', $r('app.media.translation_foldables2'),
            this.onVoiceInputClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('拍照翻译', '轻松翻译更省心', $r('app.media.translation_foldables3'), this.onCameraClick)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding, top: 16 })
    } else {
      // 小屏
      Row({ space: 12 }) {
        Column() {
          this.functionCard('文档翻译', '学习办公好帮手', $r('app.media.translation_1'), this.onDocumentClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('语音翻译', '实时录音 边说边译', $r('app.media.translation_2'), this.onVoiceInputClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('拍照翻译', '轻松翻译更省心', $r('app.media.translation_3'), this.onCameraClick)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding, top: 16 })
    }
  }
}
