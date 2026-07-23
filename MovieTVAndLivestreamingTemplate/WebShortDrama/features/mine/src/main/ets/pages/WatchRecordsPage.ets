import { jumpDetailPage, ParamsModel } from '@agctemplate/detail';
import { getMedia, getString } from '@agctemplate/resources';
import { MyWatchRecordData, MyWatchRecordRes, RequestAPI } from '@agctemplate/server';
import { appRouter, container, WindowManager } from '@agctemplate/utils';
import {
  AppStorageKeys,
  BreakPoint,
  BreakPointType,
  BreakPointValue,
  FontModel,
  fp2pxUtil,
  NavDestinationModifier
} from '@agctemplate/widgets'
import { VideoSeries } from '../component/VideoSeries';
import { AlertDialog, AppStorageV2 } from '@kit.ArkUI'
import {
  getDramaInfo,
  setMyWatchRecord,
  unsetMyWatchRecord
} from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory';

@ComponentV2
export struct WatchRecordsPage {
  @Local myWatchRecordRes: MyWatchRecordRes = new MyWatchRecordRes();
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();
  @Local isDeleting: boolean = false
  @Local selectCount: number = 0
  @Local selectedIds: string[] = []
  @Local deletePromptMsg: string | Resource = '此条';
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local trackSize: string | number =
    new BreakPointType<string | number>({
      sm: 104,
      md: 164,
      lg: 211
    }).getValue(this.currentBreakpoint.value)!
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: getString('app.string.delete_watched_prompt', this.deletePromptMsg.toString()),
      primaryButton: {
        value: '取消',
        action: () => {
          this.deleteDialogController.close()
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: $r('sys.color.ohos_id_color_warning'),
        action: () => {
          if (this.selectCount > 0) {
            // 删除选中
            this.selectedIds.map(item => {
              unsetMyWatchRecord(item)
            })
            this.updateWatchedRecords()
            this.deleteDialogController.close()
            this.isDeleting = !this.isDeleting
            this.selectedIds = []
            this.selectCount = 0
          }
        },
      },
    }),
  })

  @Monitor('currentBreakpoint.value')
  onBreakChange(monitor: IMonitor) {
    this.trackSize = new BreakPointType<number>({ sm: 104, md: 164, lg: 211 }).getValue(this.currentBreakpoint.value)!
  }

  aboutToAppear(): void {
    container.resolve(RequestAPI).getMyWatchRecord({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myWatchRecordRes = new MyWatchRecordRes(res.getBody());
    })
  }

  build() {
    NavDestination() {
      Column() {
        this.title()
        Column() {
          if (this.myWatchRecordRes.myWatchRecord.length > 0) {
            this.WatchRecordItemsBuilder()
          } else {
            Text('暂无观看记录')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width('100%')

        Blank()
        this.footItemBuilder()
      }
      .height('100%')
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .onBackPressed(() => {
      appRouter.back(true)
      return true
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .attributeModifier(this.navDestinationModifier)

  }

  @Builder
  WatchRecordItemsBuilder() {
    Grid() {
      Repeat<MyWatchRecordData>(this.myWatchRecordRes.myWatchRecord)
        .each((ri: RepeatItem<MyWatchRecordData>) => {
          GridItem() {
            VideoSeries({
              title: ri.item.name,
              currentEpisode: ri.item.currentWatch + 1,
              totalCount: ri.item.totalCount,
              isDeleting: this.isDeleting,
              likeCount: ri.item.likeCount,
              isLike: false,
              isSelectBack: (isSelect) => {
                ri.item.isSelect = isSelect
                this.getSelectedIds()
              },
              cover: ri.item.coverUrl,
              isVip: ri.item.isVip,
              onContinueWatch: () => {
                if (!this.isDeleting) {
                  jumpDetailPage(ri.item, ri.item.currentWatch, 0, (params) => {
                    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                    const paramsInfo = params.result as ParamsModel
                    const drama = getDramaInfo(paramsInfo.id)
                    drama.curIndex = paramsInfo.curIndex
                    unsetMyWatchRecord(drama.id)
                    setMyWatchRecord(drama)
                    this.updateWatchedRecords()
                  })
                }
              }
            })
          }
        })
        .key((item: MyWatchRecordData, index: number): string => item.id)// 键值生成函数
        .virtualScroll({
          totalCount: this.myWatchRecordRes.myWatchRecord.length
        }) // 打开virtualScroll模式，totalCount为期望加载的数据长度
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate(`repeat(auto-stretch, ${this.trackSize})`)
    .scrollBar(BarState.Off)
    .cachedCount(4) // 容器组件的预加载区域大小
    .margin({ bottom: this.isDeleting ? 0 : 60 })
    .height(this.isDeleting ? '85%' : 'auto')
  }

  // 更新观看记录数据
  updateWatchedRecords(): void {
    container.resolve(RequestAPI).getMyWatchRecord({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myWatchRecordRes = new MyWatchRecordRes(res.getBody());
    })
  }

  // 获取列表id
  getSelectedIds() {
    this.selectedIds = this.myWatchRecordRes.myWatchRecord
      .filter(item => item.isSelect)
      .map(item => item.id)
    this.selectCount = this.selectedIds.length
    this.getSelectCount()
  }

  // 获取所有id
  getAllIds() {
    this.selectedIds = this.myWatchRecordRes.myWatchRecord
      .map(item => item.id);
    this.selectCount = this.selectedIds.length
    this.getSelectCount()
  }

  // 获取所有id
  getSelectCount() {
    if (this.selectCount < 1) {
      return
    }
    if (this.selectCount === 1) {
      this.deletePromptMsg = '此条'
    } else if (this.selectCount === this.myWatchRecordRes.myWatchRecord.length) {
      this.deletePromptMsg = '全部'
    } else {
      this.deletePromptMsg = this.selectCount + '条'
    }
  }

  @Builder
  title() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(fp2pxUtil(24))
          .fontColor([$r('sys.color.icon_primary')])
      }
      .accessibilityText('返回')
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .margin({ right: 8 })
      .onClick(() => {
        appRouter.back()
      })

      Text(getString('app.string.my_record'))
        .fontSize(fp2pxUtil(20))
        .fontWeight(FontWeight.Bold)
        .height(27)

      Blank()
      Button(this.isDeleting ? '取消' : '编辑')
        .fontSize(fp2pxUtil(16))
        .margin({ left: 8 })
        .height(40)
        .borderRadius(20)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.isDeleting = !this.isDeleting
          this.selectedIds = []
          this.selectCount = 0
          this.myWatchRecordRes.myWatchRecord.forEach(item => {
            item.isSelect = false;
          })
        })
    }
    .height(56)
    .width('100%')
  }

  @Builder
  footItemBuilder() {
    if (this.isDeleting) {
      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.eraser_line'))
            .fontSize(fp2pxUtil(22))
            .fontColor([$r('sys.color.icon_primary')])
          Text('一键清空')
            .height(14)
            .fontSize(fp2pxUtil(13))
            .margin({ top: 5.36 })
        }
        .width('50%')
        .onClick(() => {
          this.getAllIds()
          this.deleteDialogController.open()
        })

        Column() {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(fp2pxUtil(22))
            .fontColor([$r('sys.color.icon_primary')])
          Text('删除')
            .height(14)
            .fontSize(fp2pxUtil(13))
            .margin({ top: 5.36 })
        }
        .width('50%')
        .opacity(this.selectCount > 0 ? 1 : 0.4)
        .enabled(this.selectCount > 0)
        .onClick(() => {
          this.getSelectedIds()
          this.deleteDialogController.open()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({ top: 8, bottom: 8 })
    }
  }
}

@Builder
export function WatchRecordsPageBuilder() {
  WatchRecordsPage()
}