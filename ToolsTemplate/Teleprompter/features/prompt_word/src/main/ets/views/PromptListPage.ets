import { emitter } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, CommonHeader, RouterMap, TCLogger } from 'common';
import { DisplayModel } from 'teleprompter';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BarVM } from 'common';
import { CueWordsCard } from '../comp/CueWordsCard';
import { CueWordsItem, CueWordsList } from '../viewmodel/CueWordsItemModel';
import { NewPromptWordPageBuilder } from './NewPromptWordPage';
import { EmptyComp } from '../comp/EmptyComp';

@Builder
export function PromptListPageBuilder() {
  PromptListPage()
}

/**
 * @usage: 全部提词列表页面，展示用户所有提词内容并支持批量管理。
 * 关键数据结构：CueWordsList（提词列表），selectList（选中项id数组，类型string[]），showEdit（布尔值，控制编辑模式）。
 * 包含条件渲染：if(this.showEdit)显示底部编辑栏，if(this.cueWordsList.data?.length)判断是否有数据显示列表或空状态，
 * if(this.selectList.includes(item.id))控制选中状态图标显示
 * @layout: 页面整体采用垂直布局（Column），顶部是CommonHeader导航栏（包含标题"全部提词"和右侧"编辑"按钮），
 * 中间是滚动列表区域（Scroll包裹Column），列表项为横向布局（Row），左侧可选择圆形图标，右侧为CueWordsCard卡片。
 * 底部是编辑操作栏（bottomEdit），包含全选和删除按钮，水平居中分布。整体内容左对齐
 * @constraints: selectList数组存储选中项id，不可修改数据类型；allSelect方法用于全选/取消全选逻辑，不可删除；
 * deleteItem和showDeleteAlert为核心删除功能方法
 * @domain: 工具
 * @isGen: true
 * @fileType: page
 * @zhName: 全部提词列表
 * @subPage: NewPromptWordPage
 * @component: CommonHeader, CueWordsCard, EmptyComp
 * @image: screenshots/prompt_word/PromptList.png
 */
@ComponentV2
export struct PromptListPage {
  logTag: string = 'PromptListPage';
  @Local displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!
  @Local cueWordsList: CueWordsList = AppStorageV2.connect(CueWordsList, () => new CueWordsList())!
  @Local breakpoint: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local showEdit: boolean = false
  @Local cueWordItem?: CueWordsItem = new CueWordsItem('', '', '', '');
  @Local selectList: string[] = []
  @Local pageConfig: OHPageConfig = new OHPageConfig();

  allSelect() {
    if (this.selectList.length !== this.cueWordsList.data?.length) {
      this.selectList = this.cueWordsList.data?.map(item => item.id) ?? []
    } else {
      this.selectList = []
    }
  }

  deleteItem() {
    this.cueWordsList.deleteIds(this.selectList)
    this.getUIContext().getPromptAction().showToast({ message: '删除成功' })
    this.showEdit = false
  }

  showDeleteAlert(data: string[]) {
    this.getUIContext().showAlertDialog({
      message: '确定要删除吗？',
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      height: 131,
      width: 284,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          fontColor: 'rgba(0, 0, 0, 0.60)',
          action: () => {
          }
        },
        {
          value: '确认',
          action: () => {
            this.cueWordsList.deleteIds(data)
            this.showEdit = false
          }
        }
      ]
    })
  }

  getGridCol() {
    if (this.breakpoint.currentBreakpoint === BreakpointNameEnum.SM) {
      return '1fr'
    } else {
      return this.displayModel.isFoldAble ? this.displayModel.isFullMode ? '1fr 1fr' : '1fr' : '1fr'
    }
  }

  @Builder
  titleRightBuilder() {
    if (this.cueWordsList.data.length) {
      Text('编辑')
        .fontSize(16)
        .fontColor('#000')
        .onClick(() => {
          this.showEdit = !this.showEdit
          if (!this.showEdit) {
            this.selectList = []
          }
        })
    }
  }

  @Builder
  listItem(item: CueWordsItem) {
    Row({ space: 18 }) {
      if (this.showEdit) {
        Stack() {
          Image($r('app.media.unselect_circle_icon'))
            .width(26)
            .height(26)
            .visibility(this.selectList.includes(item.id) ? Visibility.Hidden : Visibility.Visible)
            .onClick(() => {
              this.selectList.push(item.id)
            })

          Image($r('app.media.select_circle_icon'))
            .width(26)
            .height(26)
            .visibility(this.selectList.includes(item.id) ? Visibility.Visible : Visibility.Hidden)
            .onClick(() => {
              this.selectList = this.selectList.filter(id => id !== item.id)
            })
        }
      }

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
          this.showDeleteAlert([data.id])
        },
        startClick: (data) => {
          this.cueWordItem = data
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
  }

  // 列表内容
  @Builder
  listContent() {
    Grid() {
      ForEach(this.cueWordsList.data, (item: CueWordsItem) => {
        GridItem() {
          this.listItem(item)
        }
      })
    }
    .scrollBar(BarState.Off)
    .columnsTemplate(this.getGridCol())
    .align(Alignment.Top)
    .layoutWeight(1)
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({ bottom: 20, left: 16, right: 16 })
    .columnsGap(36)
    .rowsGap(10)
  }

  // 底部编辑按钮区
  @Builder
  bottomEdit() {
    Row() {
      Column({ space: 6 }) {
        Image($r('app.media.list_all_select_icon'))
          .width(24)
          .height(24)
        Text('全选')
          .fontSize(10)
          .fontColor('rgba(0, 0, 0, 0.90)')
      }
      .layoutWeight(1)
      .onClick(() => {
        this.allSelect()
      })

      Column({ space: 6 }) {
        Image($r('app.media.list_delete_icon'))
          .width(24)
          .height(24)
        Text('删除')
          .fontSize(10)
          .fontColor('rgba(0, 0, 0, 0.90)')
      }
      .layoutWeight(1)
      .onClick(() => {
        if (!this.selectList.length) {
          this.getUIContext().getPromptAction().showToast({ message: '请先选择数据' })
          return
        }
        this.showDeleteAlert(this.selectList)
      })
    }
    .width('100%')
    .padding({
      bottom: BarVM.instance.aiBarH + 3,
      top: 3,
      left: 16,
      right: 16
    })
    .backgroundColor('#fff')
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '全部提词',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
        rightBuilder: () => {
          this.titleRightBuilder()
        },
        hasBackButton: true
      })
        .padding({ left: 16, right: 16 })
      if (this.cueWordsList.data?.length) {
        this.listContent()
      } else {
        EmptyComp()
      }
      if (this.showEdit) {
        this.bottomEdit()
      }
    }
    .layoutWeight(1)
    .padding({
      top: BarVM.instance.staBarH
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

