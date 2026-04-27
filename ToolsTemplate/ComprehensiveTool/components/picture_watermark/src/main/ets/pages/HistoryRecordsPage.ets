import { CommonHeader } from '../components/CommonHeader';
import { StyleConstants } from '../constants/Styles';
import { MarkOptions } from '../types/Types';
import { alertToConfirm } from '../utils/AlertUtil';
import { HistoryUtil } from '../utils/HistoryUtil';
import { WaterMarksVM } from '../viewmodel/WaterMarksVM';

@Builder
export function historyRecordsPageBuilder() {
  HistoryRecordsPage();
}

@ComponentV2
export struct HistoryRecordsPage {
  vm: WaterMarksVM = WaterMarksVM.instance;
  @Local stack?: NavPathStack;

  aboutToAppear(): void {
    this.vm.resetParamsInRecords();
  }

  build() {
    NavDestination() {
      /** 顶部标题区 **/
      this.header()

      /** 历史列表 **/
      this.list()

      /** 选择操作 **/
      this.actions()
    }
    .onReady((event) => {
      this.stack = event.pathStack;
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  header() {
    if (this.stack) {
      CommonHeader({
        title: '历史记录', stack: this.stack, moreUi: () => {
          this.headerMoreUi()
        },
      })
    }
  }

  @Builder
  headerMoreUi() {
    Column() {
      Image($r('app.media.ic_remove'))
        .width(StyleConstants.IMAGE_24)
        .height(StyleConstants.IMAGE_24)
        .fillColor($r('sys.color.font_primary'))
    }
    .width(40)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .borderRadius(StyleConstants.HALF_PERCENT)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.vm.editing = !this.vm.editing;
    })
  }

  @Builder
  list() {
    if (this.vm.optionsList.length) {
      List({ space: StyleConstants.SPACE_8 }) {
        ForEach(this.vm.optionsList, (options: MarkOptions, index) => {
          ListItem() {
            Row({ space: StyleConstants.SPACE_8 }) {
              Row() {
                Image('file://' + this.vm.fileDir + '/' + options.file).objectFit(ImageFit.Contain)
              }
              .width(StyleConstants.IMAGE_64)
              .height(StyleConstants.IMAGE_64)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .border({
                width: 2,
                color: $r('sys.color.comp_background_tertiary'),
                radius: StyleConstants.RADIUS_8,
              })

              Column() {
                Text(options.file)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Regular)

                Text(options.time)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Regular)
              }
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.SpaceBetween)
              .height(StyleConstants.FULL_PERCENT)
              .layoutWeight(1)

              if (this.vm.editing) {
                Toggle({ isOn: this.vm.selectedList[index], type: ToggleType.Checkbox })
                  .width(20)
                  .height(20)
                  .onChange((res) => {
                    this.vm.selectedList[index] = res;
                  })
              }
            }
            .padding({
              left: StyleConstants.SPACE_12,
              right: StyleConstants.SPACE_12,
              top: StyleConstants.SPACE_12,
              bottom: StyleConstants.SPACE_14,
            })
            .borderRadius(StyleConstants.RADIUS_16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onClick(() => {
              this.vm.clickRecord(this.vm.optionsList[index]);
              this.stack?.pop();
            })
          }
          .height(90)
        }, (options: MarkOptions) => options.file)
      }
      .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
      .margin({ top: StyleConstants.SPACE_8, bottom: StyleConstants.SPACE_8 })
      .layoutWeight(1)
    } else {
      Text('暂无历史记录')
        .fontColor($r('sys.color.font_secondary'))
        .layoutWeight(1)
    }
  }

  @Builder
  actions() {
    if (this.vm.optionsList.length && this.vm.editing) {
      Row() {
        Column({ space: StyleConstants.SPACE_6 }) {
          Image($r('app.media.ic_clear'))
            .width(StyleConstants.IMAGE_20)
            .height(StyleConstants.IMAGE_20)
            .fillColor($r('sys.color.font_primary'))
          Text('一键清空')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Regular)
        }
        .onClick(async () => {
          alertToConfirm('一键清空将删除所有历史记录', async () => {
            await HistoryUtil.clearRecords();
            this.vm.resetParamsInRecords();
          });
        })

        Column({ space: StyleConstants.SPACE_6 }) {
          Image($r('app.media.ic_remove'))
            .width(StyleConstants.IMAGE_18)
            .height(StyleConstants.IMAGE_20)
            .fillColor($r('sys.color.font_primary'))
          Text('删除')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Regular)
        }
        .onClick(async () => {
          const deleteList =
            this.vm.optionsList.filter((item, index) => this.vm.selectedList[index]).map(item => item.file);
          await HistoryUtil.deleteRecord(deleteList);
          this.vm.resetParamsInRecords();
        })
      }
      .width(StyleConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround)
      .transition(TransitionEffect.translate({ y: 100 }).animation({ duration: 200, curve: Curve.Ease }))
    }
  }
}