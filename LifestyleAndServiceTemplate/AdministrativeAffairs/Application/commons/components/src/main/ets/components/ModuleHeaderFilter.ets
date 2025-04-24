import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { Constants, getCurrentLocation, PermissionRequestUtils } from 'common'
import { common } from '@kit.AbilityKit'

@ComponentV2
export struct ModuleHeaderFilter {
  @Local currentLocation: string = '北京市'
  @Param searchValue: string = ''
  controller: SearchController = new SearchController()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Event searchOnChange: (value: string) => void = (value: string) => {
  };
  @Event initDataSource: () => void = () => {
  };
  @Event searchFocus: () => void = () => {
  };
  @Event searchBlur: () => void = () => {
  }
  @Event valueChange: (value: string) => void = () => {
  }
  dealError() {
    promptAction.showToast({ message: $r('app.string.failed_location') })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        Row() {
          Text(this.currentLocation)
          Image($r('app.media.pull_down')).size({ width: $r('app.float.pull_down_width') })
        }

        Row() {
          Search({ value: this.searchValue, placeholder: $r('app.string.search_key'), controller: this.controller })
            .onChange((value: string) => {
              this.valueChange(value)
              this.searchOnChange(value)
            })
            .onFocus(() => {
              this.searchFocus()
            })
            .onBlur(() => {
              this.searchBlur()
            })
            .cancelButton({
              style: CancelButtonStyle.CONSTANT,
              icon: new SymbolGlyphModifier($r('sys.symbol.xmark')),
            })
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({
              size: $r('sys.float.Body_L'),
            })
            .width(Constants.FULL_PERCENT_WIDTH)
        }.width($r('app.float.module_filter_width')).height($r('app.float.module_filter_height'))
      }
      .padding({
        left: $r('app.float.institutions_search_margin_lf'),
        right: $r('app.float.institutions_search_margin_lf'),
      })
      .margin({
        top: $r('app.float.institutions_search_padding_lf'),
        bottom: $r('app.float.institutions_search_padding_bt'),
      })
      .onAppear(() => {
        new PermissionRequestUtils(this.context).locationPermissionRequest().then(async (res) => {
          if (res === 'success') {
            getCurrentLocation().then((res: string) => {
              this.currentLocation = res
              this.initDataSource()
            })
          } else {
            this.dealError()
          }
        }).catch(() => {
          this.dealError()
        })
      })
    }.backgroundColor($r('sys.color.background_primary')).width(Constants.FULL_PERCENT_WIDTH)
  }
}