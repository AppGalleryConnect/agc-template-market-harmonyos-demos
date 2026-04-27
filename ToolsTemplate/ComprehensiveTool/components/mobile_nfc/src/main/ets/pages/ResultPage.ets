import { ResultInfo, ResultModel } from '../model/Index';
import { getNavPathStack } from '../common/Route';
import { RESULT_INFO_MAP } from '../common/nfc/Common';
import { RTYPE } from '../common/Enum';

@Builder
export function ResultPageBuilder() {
  ResultPage();
}

@ComponentV2
struct ResultPage {
  @Local data: ResultModel = new ResultModel();
  @Local resultInfo: ResultInfo = new ResultInfo();

  build() {
    NavDestination() {
      Column() {
        Image(this.data?.rtype !== RTYPE.RTYPE_CLONE_SUCCESS ? $r('app.media.ic_read_error') :
          $r('app.media.ic_clone_success')).fitOriginalSize(true).margin({ top: 76 });
        Text(this.resultInfo.hintInfo)
          .fontColor($r('sys.color.font_secondary')).fontSize(14).margin({ top: 12, bottom: 160 });

        Button(this.data?.rtype !== RTYPE.RTYPE_CLONE_SUCCESS ? '重试' : '返回')
          .width('100%')
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.background_emphasize'))
          .height(40)
          .onClick(() => {
            if (this.resultInfo.retry) {
              getNavPathStack().pushPathByName('ActionPage', this.data.actionModel);
            } else {
              let names = getNavPathStack().getAllPathName();
              if (names.find((item => item === 'CloneCardPage'))) {
                getNavPathStack().popToName('CloneCardPage');
              } else {
                getNavPathStack().popToName('DetailPage');
              }
            }
          });
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding(16);
    }.hideTitleBar(true).onReady((ctx) => {
      this.data = ctx.pathInfo.param as ResultModel;
      this.resultInfo = RESULT_INFO_MAP.get(this.data?.rtype) ?? new ResultInfo();
      if (this.data.msg) {
        this.resultInfo.hintInfo = this.data.msg;
      }
    });
  }
}
