import { CommonButton } from '../components/CommonButton';
import { CommonHeader } from '../components/CommonHeader';
import { DownloadButton } from '../components/DownLoadButton';
import { PicFetcher } from '../components/PicFetcher';
import { MENU_LIST } from '../constants/Constants';
import { MarksPage } from '../constants/Enum';
import { StyleConstants } from '../constants/Styles';
import { alertToConfirm } from '../utils/AlertUtil';
import { contextUtil } from '../utils/ContextUtil';
import { HistoryUtil } from '../utils/HistoryUtil';
import { WaterMarksVM } from '../viewmodel/WaterMarksVM';

@Builder
export function waterMarksShowPageBuilder() {
  WaterMarksShowPage();
}

@ComponentV2
export struct WaterMarksShowPage {
  vm: WaterMarksVM = WaterMarksVM.instance;
  @Local stack?: NavPathStack;

  aboutToAppear(): void {
    contextUtil.setUiContext(this.getUIContext())
    this.vm.resetParamsInShow();
    this.vm.getSandboxDir();
  }

  build() {
    NavDestination() {
      /** 顶部标题区 **/
      this.header()

      List({ space: StyleConstants.SPACE_12 }) {
        /** 上传图片区 **/
        this.upload()

        /** 图片展示区 **/
        this.show()
      }
      .margin({ top: StyleConstants.SPACE_8, bottom: StyleConstants.SPACE_8 })
      .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
      .layoutWeight(1)

      Row() {
        if (this.vm.pixelMapWithMarks) {
          DownloadButton()
        }

        CommonButton({
          title: '编辑水印',
          btnWidth: this.vm.pixelMapWithMarks ? 'calc(50% - 12vp)' : '100%',
          handleClick: () => {
            if (!this.vm.pixelMap) {
              try {
                this.getUIContext().getPromptAction().showToast({ message: '请先上传一张图片' });
              } catch (e) {
                console.log(JSON.stringify(e))
              }
              return;
            }
            this.stack?.pushPathByName(MarksPage.EDIT_PAGE, null, false);
          },
        })
      }
      .width('calc(100% - 32vp)')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .onReady((event) => {
      this.stack = event.pathStack;
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  header() {
    if (this.stack) {
      CommonHeader({
        title: '图片水印', stack: this.stack, moreUi: () => {
          this.headerMoreUi()
        },
      })
    }
  }

  @Builder
  headerMoreUi() {
    Column() {
      Image($r('app.media.ic_more'))
        .fillColor($r('sys.color.font_primary'))
        .width(StyleConstants.IMAGE_16)
        .height(StyleConstants.IMAGE_16)
    }
    .width(40)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .borderRadius(StyleConstants.HALF_PERCENT)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .bindMenu(this.menuBuilder)
  }

  @Builder
  upload() {
    ListItem() {
      PicFetcher()
    }
  }

  @Builder
  show() {
    if (this.vm.pixelMap) {
      ListItem() {
        Column({ space: StyleConstants.SPACE_12 }) {
          Row() {
            Text(this.vm.fileName)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)

            Column() {
              Image($r('app.media.ic_del'))
                .width(StyleConstants.IMAGE_10)
                .height(StyleConstants.IMAGE_10)
                .fillColor($r('sys.color.font_primary'))
            }
            .width(24)
            .height(24)
            .borderRadius(StyleConstants.HALF_PERCENT)
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.vm.resetParamsInShow();
            })
          }
          .width(StyleConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)

          Image(this.vm.pixelMapWithMarks || this.vm.pixelMap).width(StyleConstants.FULL_PERCENT)
        }
        .borderRadius(StyleConstants.RADIUS_16)
        .padding(StyleConstants.SPACE_12)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
    }
  }

  @Builder
  menuBuilder() {
    List() {
      ForEach(MENU_LIST, (item: string, index) => {
        ListItem() {
          Row() {
            Text(item)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
            Blank().layoutWeight(1)
            if (!index) {
              Image($r('app.media.ic_arrow')).width(7).height(14).fillColor('sys.color.icon_primary')
            }
          }
          .justifyContent(FlexAlign.Start)
        }
        .height(48)
        .onClick(() => {
          if (index) {
            alertToConfirm('清除缓存将删除所有历史记录', async () => {
              HistoryUtil.clearRecords();
            });
          } else {
            this.stack?.pushPathByName(MarksPage.HISTORY_PAGE, null);
          }
        })
      }, (item: string) => item)
    }
    .width(140)
    .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })
    .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
  }
}