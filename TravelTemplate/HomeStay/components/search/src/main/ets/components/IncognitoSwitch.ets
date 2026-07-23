import { Constants } from '../common/Constant';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

@ComponentV2
export struct IncognitoSwitch {
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param breakpoint: string = 'sm';
  @Require @Param vm: SearchViewModel = SearchViewModel.getInstance();

  build() {
    Row() {
      Text('无痕搜索模式')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .flexShrink(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Toggle({ type: ToggleType.Switch, isOn: this.vm.isIncognitoMode!! })
        .selectedColor(this.themeColor)
        .onChange((isOn: boolean) => {
          this.vm.isIncognitoMode = isOn;
        })
    }
    .width(Constants.FULL_PERCENT)
    .borderRadius(Constants.BORDER_RADIUS_20)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .margin({ top: Constants.SPACE_XL })
    .padding({
      top: Constants.PADDING_L,
      bottom: Constants.PADDING_L,
      left: Constants.PADDING_M,
      right: Constants.PADDING_M,
    })
  }
}