import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { Constants } from './Constants';

export class UiUtils {
  static buildAlertDialogOption(msg: string):
  AlertDialogParamWithConfirm | AlertDialogParamWithButtons | AlertDialogParamWithOptions {
    return {
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      buttons: [
        {
          enabled: true,
          defaultFocus: true,
          style: DialogButtonStyle.HIGHLIGHT,
          backgroundColor: $r('app.color.button_background_color'),
          value: 'OK',
          action: () => {
            console.info('Callback when the second button is clicked');
          }
        }
      ],
    };
  }

  static showToast(error: BusinessError | string) {
    const message: string = typeof error === 'string' ? error : error.message
    promptAction.showToast({
      message,
      duration: 2000
    });
  }
}

export function getPicResult(result: TextPickerResult): string {
  if (typeof result.value === 'string') {
    return result.value;
  } else {
    if (result.value.length > 1 && result.value[1] !== '') {
      return result.value.join(Constants.BAR);
    } else {
      return result.value[0];
    }
  }
}

@Builder
export function navigationTitleBuilder(title: string): CustomBuilder {
  Text(title)
    .fontColor($r('app.color.text_font_color_black'))
    .fontSize(18)
    .fontWeight(FontWeight.Regular)
    .fontFamily(Constants.HARMONY_HEITI)
    .height(56)
    .margin({ left: 8 })
}


@Builder
export function buildRealNameLabelForList(msg:string, bgColor: Resource) {
  Text(msg)
    .fontSize(10)
    .backgroundColor(bgColor)
    .fontColor($r('app.color.text_font_color_black'))
    .width(48)
    .height(20)
    .borderRadius(8)
    .textAlign(TextAlign.Center)
}