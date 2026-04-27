import { emitter } from '@kit.BasicServicesKit';
import { CommonHeader, RouterMap, TCLogger, BarVM } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { CueWordsCard } from '../comp/CueWordsCard';
import { TitleBar } from '../comp/TitleBar';
import { CueWordsItem } from '../viewmodel/CueWordsItemModel';
import { NewPromptWordPageBuilder } from './NewPromptWordPage';
import { PromptListPageBuilder } from './PromptListPage';
import { EmptyComp } from '../comp/EmptyComp';
import { PromptWordVM } from '../viewmodel/PromptWordVM';


/**
 * @usage: 提词器首页，用于展示和管理用户的提词文本列表。关键数据结构为PromptWordVM(提词数据模型)。
 * 页面包含条件渲染(if)判断列表是否为空，为空时展示EmptyComp空状态组件。支持文档导入（txt格式）和拍照OCR识别文字导入功能
 * @layout: 页面整体采用垂直布局（Column），顶部是CommonHeader导航栏，下方依次为：新建提词按钮区域（newCueWords）、
 * TitleBar标题栏（包含"我的提词"标题和右侧"全部"链接），提词列表区域（cueWordItems）或空状态组件（EmptyComp），
 * 右下角悬浮导入图标按钮（importIconBuilder）。列表中每个提词以CueWordsCard卡片形式纵向排列，整体内容左对齐。
 * @constraints:
 * @domain: 工具
 * @isGen: true
 * @fileType: page
 * @zhName: 提词器首页
 * @subPage: NewPromptWordPage, PromptListPage, PromptBoardPage
 * @component: CommonHeader, OHPage, CueWordsCard, TitleBar, EmptyComp
 * @image: screenshots/prompt_word.png
 */

@ComponentV2
export struct PromptWordPage {
  logTag: string = 'PromptWordPage';
  vm: PromptWordVM = new PromptWordVM()
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    aboutToAppear: () => {
      this.vm.getPersistenceCueWords()
    }
  });

  @Builder
  newCueWords() {
    Stack() {
      Column({ space: 11 }) {
        Image($r('app.media.new_cue_plus_icon'))
          .width(40)
          .height(40)
        Text('新建提词')
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
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.NEW_PROMPT_WORD_PAGE,
        builder: wrapBuilder(NewPromptWordPageBuilder)
      })
    })
  }

  @Builder
  titleRightBuilder() {
    Row({ space: 4 }) {
      Text('全部')
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.40)')
      Image($r('app.media.gray_right_arrow'))
        .width(8)
        .height(12)
    }
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PROMPT_WORD_LIST_PAGE,
        builder: wrapBuilder(PromptListPageBuilder)
      })
    })
  }

  @Builder
  cueWordItems() {
    Column({ space: 18 }) {
      ForEach(this.vm.cueWordsList.data?.slice(0, 5), (item: CueWordsItem) => {
        Row() {
          CueWordsCard({
            data: item,
            editClick: (data) => {
              TCLogger.info('editClick' + JSON.stringify(data))
              phoneRouterControl.jumpPage({
                pageName: RouterMap.NEW_PROMPT_WORD_PAGE,
                builder: wrapBuilder(NewPromptWordPageBuilder),
                param: data
              })
            },
            deleteClick: (data) => {
              this.vm.showDeleteAlert(data)
            },
            startClick: (data) => {
              this.vm.cueWordItem = data
              let eventData: emitter.EventData = {
                data: { data: JSON.stringify(data) }
              }
              try {
                emitter.emit('openStartPromptDialog', eventData)
              } catch (e) {
              }
            }
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .margin({ top: 12 })
  }

  @Builder
  importDialog() {
    Row({ space: 34 }) {
      Column({ space: 10 }) {
        Image($r('app.media.import_file_icon'))
          .width(48)
          .height(48)
        Text('文档导入')
          .fontColor('rgba(0, 0, 0, 0.90)')
          .fontSize(14)
      }
      .onClick(() => {
        this.vm.importFileTxt()
      })

      Column({ space: 10 }) {
        Image($r('app.media.import_pic_icon'))
          .width(48)
          .height(48)
        Text('拍照识别文字')
          .fontColor('rgba(0, 0, 0, 0.90)')
          .fontSize(14)
      }
      .onClick(() => {
        this.vm.importByCamera()
      })
    }
    .padding({
      left: 44,
      right: 44,
      top: 20,
      bottom: 20
    })
  }

  @Builder
  importIconBuilder() {
    Image($r('app.media.cue_words_import_icon'))
      .width(52)
      .height(52)
      .position({ bottom: 16, right: 0 })
      .onClick(() => {
        this.getUIContext().getPromptAction().openCustomDialog({
          builder: () => this.importDialog(),
          offset: { dy: -(131 - this.getUIContext().px2vp(BarVM.instance.aiBarHeight.value)), dx: -32 },
          cornerRadius: 16,
          width: 240,
          alignment: DialogAlignment.BottomEnd,
        })
          .then((id) => {
            this.vm.dialogId = id
          })
      })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '提词器',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
        hasBackButton: false
      })
      Scroll() {
        Column() {
          this.newCueWords()
          TitleBar({
            title: '我的提词',
            rightBuilder: () => {
              this.titleRightBuilder()
            }
          })
          if (this.vm.cueWordsList.data?.length) {
            this.cueWordItems()
          } else {
            EmptyComp()
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .padding({ bottom: 20 })
      .align(Alignment.TopStart)

      this.importIconBuilder()
    }
    .layoutWeight(1)
    .padding({
      top: BarVM.instance.staBarH,
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

