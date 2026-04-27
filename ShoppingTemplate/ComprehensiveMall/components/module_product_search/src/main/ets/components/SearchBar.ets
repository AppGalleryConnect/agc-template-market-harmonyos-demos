import { UtilLog } from '@hw-agconnect/util-log';
import { Constants } from '../commons/Constants';

@ComponentV2
export struct SearchBar {
  @Param
  placeholder: string = ''
  @Param
  searchWords: string = '';
  @Param
  disabled: boolean = false;
  @Event
  updateSearchWords: (value: string) => void = () => {
  };
  @Event
  clickBack: () => void = () => {
  };
  @Event
  submitSearch: (value: string) => void = () => {
  };
  controller: SearchController = new SearchController();
  SEARCH_BAR_ID = 'search_bar';

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_left_arrow'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.font_color_level1'));
      }
      .width(40)
      .height(40)
      .borderRadius(Constants.BORDER_RADIUS_CAPSULE)
      .backgroundColor($r('app.color.background_color_button_grey'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ right: Constants.SPACE_S })
      .onClick(() => {
        this.clickBack?.();
      });

      if (this.disabled) {
        Row() {
          Text(this.searchWords)
            .fontColor($r('app.color.font_color_level2'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .height(40)
        .layoutWeight(1)
        .padding({ left: Constants.SPACE_L })
        .margin({
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S,
        })
        .borderRadius(Constants.BORDER_RADIUS_CAPSULE)
        .backgroundColor($r('app.color.background_color_button_grey'))
        .onClick(() => {
          this.clickBack?.();
        });
      } else {
        Search({
          value: this.searchWords,
          controller: this.controller,
          placeholder: this.placeholder ? this.placeholder : '请输入搜索内容',
        })
          .layoutWeight(1)
          .backgroundColor($r('app.color.background_color_button_grey'))
          .searchButton('搜索', {
            fontColor: Constants.THEME_COLOR,
          })
          .defaultFocus(true)
          .enableKeyboardOnFocus(true)
          .searchIcon({ size: 0 })
          .caretStyle({ color: Constants.THEME_COLOR })
          .id(this.SEARCH_BAR_ID)
          .onVisibleAreaChange([1], (_isExpanding: boolean, currentRatio: number) => {
            if (currentRatio === 1) {
              try {
                this.getUIContext().getFocusController().requestFocus(this.SEARCH_BAR_ID);
              } catch {
                UtilLog.error('request focus failed.')
              }
            }
          })
          .onChange((value) => {
            this.updateSearchWords?.(value);
          })
          .onSubmit((value) => {
            this.submitSearch?.(value ? value : this.placeholder);
          });
      }
    }
    .padding({
      left: Constants.SPACE_L,
      right: Constants.SPACE_S,
    })
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

  }
}