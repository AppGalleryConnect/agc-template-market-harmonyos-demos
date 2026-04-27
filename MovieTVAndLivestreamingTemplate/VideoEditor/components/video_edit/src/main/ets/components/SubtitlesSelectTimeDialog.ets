import { ComponentContent } from '@kit.ArkUI';
import { BarVM, VEPromptAction } from 'video_common';
import { SUBTITLES_MINUTE_LIST } from '../utils/ConstantsUtil';

/**
 * 健康数据输入弹框
 */
export class SubtitlesSelectTimeDialog {
  private constructor() {
  }

  static ShowPopup(dialogVM: SubtitlesTimeModel, uiContext: UIContext) {
    if (VEPromptAction.contentNode === undefined) {
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildPopup), dialogVM);
        VEPromptAction.uiContext = uiContext;
        VEPromptAction.contentNode = contentNode;
        VEPromptAction.options = {
          alignment: DialogAlignment.TopStart,
          maskColor: Color.Transparent,
          autoCancel: true,
          onWillDismiss: (_reason: DismissDialogAction) => {
            SubtitlesSelectTimeDialog.ClosePopup();
            dialogVM.onValueCancelClick();
            return true;
          }
        };
        VEPromptAction.openDialog();
      }
    }
  }

  static ClosePopup() {
    VEPromptAction.closeDialog();
  }
}

@Builder
function buildPopup(dialogVM: SubtitlesTimeModel) {
  Column() {
    Row() {
      Text('分')
        .layoutWeight(1)
        .fontColor(0x99ffffff)
        .height('100%')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)

      Blank()
        .height('1vp')
        .color(0x99ffffff)
        .width(6)

      Text('秒')
        .layoutWeight(1)
        .fontColor(0x99ffffff)
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .height('100%')
    }
    .width('100%')
    .height(36)

    Row() {
      TextPicker({
        range: dialogVM.minuteList,
        value: dialogVM.minuteValue,
        selected: dialogVM.minuteSelect
      })
        .height('100%')
        .width(84)
        .canLoop(true)
        .selectedTextStyle({
          font: {
            size: 16,
            weight: FontWeight.Medium
          },
          color: '#01FCEA'
        })
        .defaultPickerItemHeight(36)
        .textStyle({
          font: {
            size: 14,
            weight: FontWeight.Regular
          },
          color: '#99FFFFFF'
        })
        .onChange((value: string | string[]) => {
          dialogVM.minuteValue = value as string;
        })
      TextPicker({
        range: dialogVM.secondList,
        value: dialogVM.secondValue,
        selected: dialogVM.secondSelect
      })
        .height('100%')
        .selectedTextStyle({
          color: '#01FCEA',
          font: {
            size: 16,
            weight: FontWeight.Medium
          }
        })
        .textStyle({
          color: '#99FFFFFF',
          font: {
            size: 14,
            weight: FontWeight.Regular
          }
        })
        .defaultPickerItemHeight(36)
        .width(84)
        .canLoop(true)
        .onChange((value: string | string[]) => {
          dialogVM.secondValue = value as string;
        })
    }
    .width('100%')
    .height(180)

    Row() {
      Button('取消')
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(Color.Transparent)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_on_primary'))
        .opacity(0.6)
        .onClick(() => {
          SubtitlesSelectTimeDialog.ClosePopup();
          dialogVM.onValueCancelClick();
        })

      Blank()
        .height(10)
        .width('1px')
        .color($r('sys.color.comp_divider'))

      Button('确认')
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(Color.Transparent)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_on_primary'))
        .opacity(0.8)
        .onClick(() => {
          SubtitlesSelectTimeDialog.ClosePopup();
          dialogVM.onValueConfirmClick(dialogVM);
        })
    }
    .width('100%')
    .height(36)
  }
  .width(166)
  .height(252)
  .position({ x: 16, y: BarVM.instance.staBarH + 222 })
  .borderRadius($r('sys.float.corner_radius_level4'))
  .backgroundColor('#202E3E')
  .clip(true)
}

@ObservedV2
export class SubtitlesTimeModel {
  minuteList: string[] = SUBTITLES_MINUTE_LIST;
  minuteValue: string = '00';
  minuteSelect: number = 0;
  secondList: string[] = SUBTITLES_MINUTE_LIST;
  secondValue: string = '00';
  secondSelect: number = 0;
  onValueConfirmClick = (_model: SubtitlesTimeModel) => {
  };
  onValueCancelClick = () => {
  };
}