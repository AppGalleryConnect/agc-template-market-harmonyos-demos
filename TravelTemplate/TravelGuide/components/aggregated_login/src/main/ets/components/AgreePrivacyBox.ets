import { loginComponentManager } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AggregatedLoginVM } from '../viewmodel/AggregatedLoginVM';
import { Constants } from '../common/Constant';
import { PrivacyContent, ProtocolRouterParams } from '../model/Index';

@ComponentV2
export struct AgreePrivacyBox {
  @Local vm: AggregatedLoginVM = AggregatedLoginVM.getInstance(false);
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param privacyContent: PrivacyContent[] = []
  @Param routerModule: NavPathStack = new NavPathStack()
  @Param isSheet: boolean = false;
  @Param sheetType: SheetType = SheetType.BOTTOM;
  selectedContent: PrivacyContent | undefined = new PrivacyContent()
  privacyText = this.vm.generatePrivacyText(this.privacyContent)

  build() {
    Row({ space: Constants.SPACE_M }) {
      Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
        .width(Constants.BOX_WIDTH)
        .height(Constants.BOX_HEIGHT)
        .focusable(true)
        .focusOnTouch(true)
        .selectedColor(this.themeColor)
        .select(this.vm.isSelected)
        .enabled(this.vm.enableStatus)
        .onChange((value: boolean) => {
          hilog.info(0x0001, 'CheckBoxComponent', `agreementChecked: ${value}`);
          this.vm.agreePrivacyChange(value)
        });

      this.buildSelectView(this.themeColor)
    }
  }

  @Builder
  buildSelectView(themeColor: ResourceColor) {
    Row() {
      Text() {
        ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
          if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
            Span(item?.text)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
          } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
            Span(item?.text)
              .fontSize($r('sys.float.Body_S'))
              .fontColor(themeColor)
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Medium)
              .focusable(true)
              .focusOnTouch(true)
              .onClick(() => {
                // 根据item.tag查找对应的PrivacyContent
                this.selectedContent = this.privacyContent.find(
                  content => content.privacyTag === item.tag
                );
                if (this.selectedContent) {
                  this.routerModule.pushPathByName('ProtocolWebView', {
                    content: this.selectedContent.privacyUrl,
                    isSheet: this.isSheet,
                    sheetType: this.sheetType,
                  } as ProtocolRouterParams, true);
                }
              })
          }
        }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
      }
      .width(Constants.FULL_PERCENT)
    }
    .layoutWeight(1)
  }
}