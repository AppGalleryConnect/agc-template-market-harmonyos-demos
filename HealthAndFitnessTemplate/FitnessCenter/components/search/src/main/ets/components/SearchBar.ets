import { SymbolGlyphModifier } from '@kit.ArkUI';
import { Logger } from 'external_interactions';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

const TAG = '[SearchBar]'

@ComponentV2
export struct SearchBar {
  @Param placeholder: string[] = ['搜索门店...']
  @Param searchWords: string = '';
  @Param themeColor: ResourceColor = '#0A59F7'
  @Param isResult: boolean = false;
  @Param controller: SearchController = new SearchController();
  @Event
  updateSearchWords: (value: string) => void = () => {
  };
  @Event
  submitSearch: (value: string) => void = () => {
  };
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local searchWordIndex: number = 0;
  @Local timerID: number | null = null;

  aboutToAppear(): void {
    this.timerID = setInterval(() => {
      this.searchWordIndex = (this.searchWordIndex + 1) % this.placeholder.length;
    }, 2000);
  }

  aboutToDisappear(): void {
    clearInterval(this.timerID);
  }

  build() {
    Row() {
      Search({
        value: $$this.searchWords,
        controller: this.controller,
        placeholder: this.placeholder[this.searchWordIndex],
      })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Regular,
          family: 'HarmonyHeiTi'
        })
        .placeholderColor($r('sys.color.font_secondary'))
        .textFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Medium,
          family: 'HarmonyHeiTi',
        })
        .cancelButton({
          style: CancelButtonStyle.INPUT,
          icon: new SymbolGlyphModifier().fontSize('16vp')
        })
        .caretStyle({ color: this.themeColor })
        .searchButton('搜索', {
          fontSize: $r('sys.float.Body_M'),
          fontColor: this.themeColor,
        })
        .enableKeyboardOnFocus(true)
        .onChange((value) => {
          this.updateSearchWords?.(value);
        })
        .onSubmit((value) => {
          this.submitSearch?.(value ? value : this.placeholder[this.searchWordIndex]);
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
            Logger.error(TAG, 'Error in onEditChange:')
          }
        })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}