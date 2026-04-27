import { SymbolGlyphModifier } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

@ComponentV2
export struct SearchBar {
  @Param placeholder: string = 'Search';
  @Param searBarFgColor: ResourceColor = $r('sys.color.font_primary');
  @Param searchBarPlaceholderColor: ResourceColor = $r('sys.color.font_secondary');
  @Param searchBarBgColor: ResourceColor = $r('sys.color.comp_background_tertiary');
  @Param searchWords: string = '';
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param isResult: boolean = false;
  @Param controller: SearchController = new SearchController();
  @Require @Param vm: SearchViewModel = SearchViewModel.getInstance();
  @Event
  updateSearchWords: (value: string) => void = () => {
  };
  @Event
  submitSearch: (value: string) => void = () => {
  };

  build() {
    Row() {
      Search({
        value: $$this.searchWords,
        controller: this.controller,
        placeholder: this.placeholder,
      })
        .defaultFocus(false)
        .accessibilityText('搜索按钮')
        .backgroundColor(this.searchBarBgColor)
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Regular,
          family: 'HarmonyHeiTi',
        })
        .placeholderColor(this.searchBarPlaceholderColor)
        .textFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Medium,
          family: 'HarmonyHeiTi',
        })
        .fontColor(this.searBarFgColor)
        .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontColor([this.searchBarPlaceholderColor]))
        .cancelButton({
          style: CancelButtonStyle.INPUT,
          icon: new SymbolGlyphModifier().fontSize('16vp').fontColor([this.searchBarPlaceholderColor]),
        })
        .caretStyle({ color: this.themeColor })
        .searchButton('搜索', {
          fontSize: $r('sys.float.Body_M'),
          fontColor: this.themeColor,
        })
        .enableKeyboardOnFocus(false)
        .onChange((value) => {
          this.updateSearchWords?.(value);
        })
        .onSubmit((value) => {
          this.submitSearch?.(value ? value : this.placeholder);
        })
        .onEditChange((data: boolean) => {
          try {
            if (data && ['lg', 'xl'].includes(this.vm.breakpoint) && this.vm.isShallowWindow) {
              if (this.isResult) {
                this.vm.showPopupInResult = true;
              } else {
                this.vm.showPopup = true;
              }
            }
          } catch (error) {
            UtilLog.error('Error in onEditChange:')
          }
        })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}