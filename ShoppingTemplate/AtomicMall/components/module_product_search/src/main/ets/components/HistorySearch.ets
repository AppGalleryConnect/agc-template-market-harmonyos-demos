import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { HistorySearchItem } from '../commons/Types';
import { LengthMetrics, PromptAction } from '@kit.ArkUI';
import { Constants } from '../commons/Constants';

const TAG: string = '[HistorySearch]';

@ComponentV2
export struct HistorySearch {
  @Param
  historyList: HistorySearchItem[] = [];
  @Event
  handleClickItem: (label: string) => void;
  @Event
  updateList: (list: HistorySearchItem[]) => void;
  @Local
  isEdit: boolean = false;
  @Local
  tempHistoryList: HistorySearchItem[] = [];
  @Local
  showAll: boolean = false;

  @Computed
  get listMaxHeight() {
    if (this.showAll) {
      return Infinity;
    }
    return 80;
  }

  @Monitor('historyList')
  getListView() {
    this.tempHistoryList = this.historyList;
  }

  aboutToAppear(): void {
    this.getListView();
  }

  build() {
    if (this.tempHistoryList.length) {
      Column() {
        Row() {
          Text('历史搜索')
            .fontSize(14)
            .fontColor($r('app.color.font_color_level2'));
          if (!this.isEdit) {
            Row() {
              Image($r('app.media.ic_delete'))
                .width(16)
                .height(16)
                .fillColor($r('app.color.font_color_level2'))
                .margin({ right: Constants.SPACE_XS });
              Text('删除').labelStyle();
            }
            .onClick(() => {
              this.isEdit = true;
            });
          } else {
            Row() {
              Text('全部删除')
                .labelStyle()
                .onClick(() => {
                  this.deleteAll();
                });
              Divider()
                .height(16)
                .vertical(true)
                .margin({ left: Constants.SPACE_S, right: Constants.SPACE_S });
              Text('完成')
                .labelStyle()
                .onClick(() => {
                  this.updateList?.(this.tempHistoryList);
                  this.isEdit = false;
                });
            };
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)
        .margin({ bottom: Constants.SPACE_M });

        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(this.tempHistoryList, (item: HistorySearchItem) => {
            this.historyItemBuilder(item);
          },(item:HistorySearchItem,index:number)=>index+'__'+item.label);
        }
        .constraintSize({ maxHeight: this.listMaxHeight })
        .clip(true)
        .onSizeChange((_old, newVal) => {
          if (newVal.height && newVal.height < this.listMaxHeight) {
            this.showAll = true;
          }
        });

        if (!this.showAll) {
          Text('查看全部')
            .labelStyle()
            .margin({ top: Constants.SPACE_S })
            .onClick(() => {
              this.showAll = true;
            });
        }
      };
    }
  }

  @Builder
  historyItemBuilder(item: HistorySearchItem) {
    Row() {
      Text(item.label).labelStyle();
      if (this.isEdit) {
        Image($r('app.media.ic_close'))
          .fillColor($r('app.color.font_color_level2'))
          .width(12)
          .height(12)
          .margin({ left: Constants.SPACE_XS })
          .onClick(() => {
            this.tempHistoryList = this.tempHistoryList.filter((it) => it.label !== item.label);
          });
      }
    }
    .backgroundColor($r('app.color.background_color_button_grey'))
    .padding(Constants.SPACE_S)
    .borderRadius(Constants.BORDER_RADIUS_CAPSULE)
    .onClick(() => {
      if (this.isEdit) {
        return;
      }
      this.handleClickItem?.(item.label);
    });
  }

  deleteAll() {
    let uiContext = this.getUIContext();
    let promptAction: PromptAction = uiContext.getPromptAction();
    try {
      promptAction.showDialog({
        message: '确定要清空所有搜索历史吗？',
        buttons: [
          {
            text: '取消',
            color: $r('app.color.font_color_level2'),
          },
          {
            text: '删除',
            color: Constants.THEME_COLOR,
          },
        ],
      }, (err, data) => {
        if (err) {
          Logger.error(TAG, 'handle dialog failed. error:' + JSON.stringify(err));
        }
        if (data.index === 1) {
          this.tempHistoryList = [];
          this.updateList?.([]);
          this.isEdit = false;
        }
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }
}

@Extend(Text)
function labelStyle() {
  .fontSize(14)
  .fontColor($r('app.color.font_color_level2'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis });
}