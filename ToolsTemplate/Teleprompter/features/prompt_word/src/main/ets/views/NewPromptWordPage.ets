import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { CommonHeader, RouterMap, TCLogger, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BarVM } from 'common';
import { TitleBar } from '../comp/TitleBar';
import { CueWordsItem, CueWordsList } from '../viewmodel/CueWordsItemModel';
import { PromptListPageBuilder } from './PromptListPage';

@Builder
export function NewPromptWordPageBuilder(params?: TValueType) {
  NewPromptWordPage({
    pageParam: params
  })
}

/**
 * @usage: 新建或编辑提词页面，用于输入提词的标题和正文内容。关键数据结构：CueWordsItem（提词数据模型），
 * 包含条件判断：if(params?.id)判断是编辑还是新建模式，if(!this.cueWords?.title)和if(!this.cueWords?.content)进行表单验证，
 * if(this.cueWords.content?.length)控制清空按钮显示。字数统计：实时计算this.cueWords.content?.length
 * @layout: 页面整体采用垂直布局（Column），顶部是CommonHeader导航栏，依次为：TitleBar"提词标题"，TextInput标题输入框，
 * TitleBar"提词正文"(左侧显示字数统计), TextArea正文输入框(带清空按钮浮层), 底部是按钮区域, 保存和开始提词按钮横向排列。整体左对齐。
 * @constraints: cueWords为核心数据对象不可删除；validateForm方法为必需的表单验证逻辑；
 * @domain: 工具
 * @isGen: true
 * @fileType: page
 * @zhName: 新建编辑提词页
 * @subPage:
 * @component: CommonHeader, TitleBar,  OHPage
 * @image: screenshots/prompt_word/NewPromptWord.png
 */
@ComponentV2
export struct NewPromptWordPage {
  logTag: string = 'NewPromptWordPage';
  @Local cueWordsList: CueWordsList = AppStorageV2.connect(CueWordsList, 'CueWordsList', () => new CueWordsList())!
  @Param pageParam?: TValueType = null
  @Local cueWords: CueWordsItem = new CueWordsItem('', '', '', '')
  @Local titleName: string = '新建提词'
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    aboutToAppear: () => {
      let params = this.pageParam as CueWordsItem
      if (params?.id) {
        this.titleName = '编辑提词'
        this.cueWords = params
      }
      if (params?.content) {
        this.cueWords.content = params?.content
      }
    }
  });

  validateForm() {
    if (!this.cueWords?.title) {
      this.getUIContext().getPromptAction().showToast({ message: '请输入提词标题' })
      return false
    }
    if (!this.cueWords?.content) {
      this.getUIContext().getPromptAction().showToast({ message: '请输入提词正文' })
      return false
    }
    return true
  }

  saveCueWords() {
    if (!this.cueWords?.id) {
      this.cueWords.init()
      this.cueWordsList.add(this.cueWords)
    } else {
      this.cueWords.setTime()
    }
    this.cueWordsList.sort()
  }

  save() {
    if (this.validateForm()) {
      this.saveCueWords()
      this.getUIContext().getPromptAction().showToast({ message: '保存成功！' })
      phoneRouterControl.replacePage({
        pageName: RouterMap.PROMPT_WORD_LIST_PAGE,
        builder: wrapBuilder(PromptListPageBuilder)
      })
    }
  }

  @Builder
  newCueWords() {
    Stack() {
      Column({ space: 11 }) {
        Image($r('app.media.new_cue_plus_icon'))
          .width(40)
          .height(40)
        Text('新建题词')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.9)')
      }
    }
    .width('100%')
    .height(120)
    .borderRadius(8)
    .border({ width: 1, color: '#0A59F7' })
    .backgroundColor('#fff')
    .align(Alignment.Center)
    .margin({ bottom: 20 })
  }

  @Builder
  titleRightBuilder() {
    Row({ space: 4 }) {
      Text('全部')
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.40)')
      Image($r('app.media.gray_right_arrow'))
        .width(6)
        .height(12)
    }
    .onClick(() => {
      TCLogger.info('titleRightBuilder')
    })
  }

  // 标题输入框
  @Builder
  titleInput() {
    TextInput({
      placeholder: '请输入提词板标题',
      text: $$this.cueWords.title
    })
      .padding({
        top: 19,
        bottom: 19,
        left: 12,
        right: 12
      })
      .width('100%')
      .borderRadius(8)
      .backgroundColor('#fff')
      .placeholderColor($r('sys.color.font_secondary'))
      .fontSize(14)
      .fontColor('rgba(0, 0, 0, 0.90)')
      .placeholderFont({ size: $r('sys.float.Body_L') })
      .margin({ bottom: 20 })
  }

  @Builder
  titleLeftBuilder() {
    Text(`共${this.cueWords.content?.length}字`)
      .fontSize(14)
      .fontColor('rgba(0, 0, 0, 0.40)')
  }

  // 正文输入框
  @Builder
  contentInput() {
    Stack() {
      TextArea({
        placeholder: '请输入提词板正文',
        text: $$this.cueWords.content
      })
        .padding({
          top: 12,
          left: 12,
          right: 12,
          bottom: 28
        })
        .width('100%')
        .borderRadius(8)
        .backgroundColor('#fff')
        .placeholderColor($r('sys.color.font_secondary'))
        .fontSize(14)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .height('50%')

      if (this.cueWords.content?.length) {
        Text('清空全部内容')
          .fontColor('rgba(0, 0, 0, 0.40)')
          .fontSize(12)
          .position({ right: 12, bottom: 12 })
          .onClick(() => {
            this.cueWords.content = ''
          })
      }
    }
  }

  // 底部按钮区
  @Builder
  bottomButtons() {
    Row({ space: '5%' }) {
      Text('保存')
        .fontColor('#0A59F7')
        .fontSize(18)
        .padding({
          top: 17,
          bottom: 17
        })
        .width('30%')
        .textAlign(TextAlign.Center)
        .borderRadius(8)
        .border({ width: 1, color: '#0A59F7' })
        .onClick(() => {
          this.save()
        })

      Text('开始题词')
        .fontColor('#fff')
        .fontSize(18)
        .padding({
          top: 17,
          bottom: 17
        })
        .width('65%')
        .textAlign(TextAlign.Center)
        .borderRadius(8)
        .backgroundColor('#0A59F7')
        .onClick(() => {
          if (this.validateForm()) {
            this.saveCueWords()
            let eventData: emitter.EventData = {
              data: { data: JSON.stringify(this.cueWords) }
            }
            try {
              emitter.emit('openStartPromptDialog', eventData)
            } catch (e) {
            }
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: this.titleName,
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
        hasBackButton: true
      })
      TitleBar({
        title: '提词标题'
      })
        .margin({ bottom: 12 })
      this.titleInput()
      TitleBar({
        title: '提词正文',
        leftBuilder: () => {
          this.titleLeftBuilder()
        }
      })
        .margin({ bottom: 12 })
      this.contentInput()
      Blank()
      this.bottomButtons()
    }
    .layoutWeight(1)
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH,
      left: 16,
      right: 16
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageBackgroundColor: '#F1F3F5',
      pageConfig: this.pageConfig,
    })
  }
}

