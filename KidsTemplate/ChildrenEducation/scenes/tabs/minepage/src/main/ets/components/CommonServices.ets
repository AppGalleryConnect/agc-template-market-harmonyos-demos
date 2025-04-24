import { CommonServiceModel, mineCommonService } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, rightArrow } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct CommonServices {
  isLogin: string = '未登录';
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private mineCommonService: Array<CommonServiceModel> = mineCommonService;

  build() {
    Row() {
      Column({ space: 20 }) {
        Text($r('app.string.common_service'))
          .padding({ top: 25 })
          .fontColor($r('sys.color.black'))
          .fontWeight(FontWeight.Bold)
          .fontSize(18);
        ForEach(this.mineCommonService, (item: CommonServiceModel, index: number) => {
          Row() {
            SymbolGlyph($r(item.symbol)).padding({ right: 16 });
            Text($r(item.serviceName)).fontSize(16).fontWeight(FontWeight.Medium).fontFamily('鸿蒙黑体');
            Blank();
            rightArrow()
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding({ bottom: index !== mineCommonService.length - 1 ? 0 :25 })
          .onClick(() => {
            this.appPathStack.pushPathByName(item.pageName, undefined);
          });

          if (index !== mineCommonService.length - 1) {
            Divider().width('85%').alignSelf(ItemAlign.End);
          }
        });
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.FULL_PERCENT)
      .padding({ right: '4%', left: '4%' });
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16);
  }
}


