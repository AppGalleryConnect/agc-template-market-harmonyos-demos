import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BreakpointModel,
  CommonEmpty,
  CommonTitle,
  CommonUtil,
  GridRowColSetting,
  HttpApi,
  PageStatus,
  PointDetail,
  ToastLoading,
  UserInfoModel,
  WindowInfo,
} from 'lib_foundation';
import { openMonthFilterSheet } from '../components/MonthFilterSheet';
import { IDateRange } from '../models/Models';


@Builder
export function PointsHistoryPageBuilder() {
  PointsHistoryPage()
}

@ComponentV2
struct PointsHistoryPage {
  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local allHistory: PointDetail[] = [];
  @Local pointsHistory: PointDetail[] = [];
  @Local dateLabel: string = '';
  @Local year: number = 0;
  @Local month: number = 0;
  @Local curIndex: number = 0;
  // 页面状态
  @Local pageStatus: PageStatus = PageStatus.IDLE;

  aboutToAppear(): void {
    this.pageStatus = PageStatus.LOADING;
    this.initFilterDate();
    this.queryPointHistory();
  }

  initFilterDate() {
    this.dateLabel = CommonUtil.formatDate(new Date(), 'YYYY.MM');
    const dateArr = this.dateLabel.split('.');
    this.year = Number(dateArr[0]);
    this.month = Number(dateArr[1]);
  }

  // 获取指定年份和月份的起始与结束时间戳
  getMonthRange(year: number, month: number) {
    const start = new Date(year, month - 1, 1, 0, 0, 0, 0);
    const end = new Date(year, month, 1, 0, 0, 0, 0);
    return {
      startTime: start.getTime(),
      endTime: end.getTime(),
    } as IDateRange;
  }

  queryPointHistory() {
    ToastLoading.open();
    const range = this.getMonthRange(this.year, this.month);
    const userId = this.userInfoModel.id
    HttpApi.queryPointsHistory(userId, range.startTime, range.endTime).then((resp) => {
      this.allHistory = resp;
      this.handlePointHistory();
    }).finally(() => {
      this.pageStatus = PageStatus.SUCCESS;
      ToastLoading.close();
    })
  }

  handlePointHistory() {
    if (this.curIndex === 0) {
      this.pointsHistory = this.allHistory.filter((item) => item.amount > 0);
    } else {
      this.pointsHistory = this.allHistory.filter((item) => item.amount < 0);
    }
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '积分明细',
      })
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
      }) {
        GridCol({
          span: { xs: 4, sm: 4, md: 8, lg: 8 },
          offset: { lg: 2 }
        }) {
          if (this.pageStatus === PageStatus.SUCCESS) {
            Column() {
              // 总积分
              this.totalPoints()

              // tab
              this.tabNavBuilder()

              Column() {
                if (this.pointsHistory.length) {
                  List({ space: 12 }) {
                    Repeat(this.pointsHistory)
                      .each((pointInfo: RepeatItem<PointDetail>) => {
                        ListItem() {
                          Column() {
                            Text(pointInfo.item.description)
                              .fontSize(14)
                              .fontWeight(400)
                              .fontColor($r('sys.color.font_primary'))
                              .lineHeight(19)
                            Row() {
                              Text(CommonUtil.formatDate(pointInfo.item.createTime, 'YYYY-MM-DD HH:mm:ss'))
                                .fontSize(12)
                                .fontWeight(400)
                                .fontColor($r('sys.color.font_primary'))
                                .lineHeight(16)
                              Text(pointInfo.item.amount > 0 ? `+${pointInfo.item.amount}` : `${pointInfo.item.amount}`)
                                .fontSize(14)
                                .fontWeight(400)
                                .fontColor($r('sys.color.font_emphasize'))
                                .lineHeight(19)
                            }
                            .justifyContent(FlexAlign.SpaceBetween)
                            .width('100%')
                          }
                          .width('100%')
                          .alignItems(HorizontalAlign.Start)
                        }
                      })
                      .key((item) => JSON.stringify(item))
                  }
                  .width('100%')
                  .height('auto')
                  .constraintSize({ maxHeight: '100%'})
                  .scrollBar(BarState.Off)
                  .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
                  .contentStartOffset(12)
                  .contentEndOffset(12)
                  .backgroundColor(Color.White)
                  .padding({ left: 12, right: 12 })
                  .borderRadius({ bottomLeft: 16, bottomRight: 16 })
                } else {
                  Column() {
                    CommonEmpty({
                      emptyDesc: '暂无数据',
                    })
                  }
                  .width('100%')
                  .height(180)
                  .backgroundColor(Color.White)
                  .padding({ left: 12, right: 12 })
                  .borderRadius({ bottomLeft: 16, bottomRight: 16 })
                }
              }
              .width('100%')
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height('100%')
            .padding({
              left: this.breakPointModel.pagePadding,
              right: this.breakPointModel.pagePadding,
              bottom: this.windowModel.windowBottomPadding
            })
          }
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .height('100%')
    .linearGradient(
      {
        colors: [['rgba(168, 202, 240, 1)', 0.2], ['rgba(241, 243, 245, 0)', 1]],
      })
  }

  @Builder
  totalPoints() {
    Column({ space: 4 }) {
      Text('总积分').fontSize(14).fontWeight(400).fontColor($r('sys.color.font_primary')).lineHeight(19)
      Text(`${this.userInfoModel.points}`)
        .fontSize(16)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 12, bottom: 24 })
  }

  @Builder
  tabNavBuilder() {
    Row() {
      TabNavItem({
        label: '收入',
        index: 0,
        curIndex: this.curIndex,
        onChange: (idx: number) => {
          this.curIndex = idx;
          this.handlePointHistory();
        },
      })
      TabNavItem({
        label: '支出',
        index: 1,
        curIndex: this.curIndex,
        onChange: (idx: number) => {
          this.curIndex = idx;
          this.handlePointHistory();
        },
      }).margin({ left: 16 })

      Blank()

      Row() {
        Text(this.dateLabel)
          .fontSize(14)
          .fontWeight(400)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(19)
        SymbolGlyph($r('sys.symbol.chevron_down'))
          .fontSize(20)
          .fontColor([$r('sys.color.icon_tertiary')])
      }
      .onClick(() => {
        openMonthFilterSheet(this.dateLabel, (date: string) => {
          this.dateLabel = date;
          const dateArr = this.dateLabel.split('.');
          this.year = Number(dateArr[0]);
          this.month = Number(dateArr[1]);
          this.queryPointHistory();
        })
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: 16,
      topRight: 16
    })
  }
}

@ComponentV2
struct TabNavItem {
  @Param label: string = '';
  @Param index: number = 0;
  @Param curIndex: number = 0;
  @Event onChange: (index: number) => void;

  build() {
    Column() {
      Text(this.label)
        .fontSize(14)
        .fontWeight(this.index === this.curIndex ? 500 : 400)
        .lineHeight(19)
        .fontColor(this.index === this.curIndex ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
      Row().width(20).height(2)
        .backgroundColor(this.index === this.curIndex ? $r('sys.color.font_emphasize') : Color.Transparent)
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onChange(this.index)
    })
  }
}