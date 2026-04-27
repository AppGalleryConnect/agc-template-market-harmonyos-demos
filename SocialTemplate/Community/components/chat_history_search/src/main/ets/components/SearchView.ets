import { SearchModel } from '../viewmodel/SearchModel';

@ComponentV2
export struct SearchView {
  @Param @Require onSubmitSearch: () => void = () => {
  };
  @Param @Require searchVM: SearchModel;
  @Param @Require onReturnClick?: () => void
  @Local searchText: string = '';

  aboutToAppear(): void {
    this.searchVM.setOnSearchTextChangeListener((searchText: string) => {
      this.searchText = searchText;
    })
  }

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: 10 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.onReturnClick) {
          this.onReturnClick?.()
        }
      })

      Row() {
        Image($r('app.media.search_icon'))
          .opacity(0.6)
          .width($r('app.float.vp_16'))
          .objectFit(ImageFit.Contain)
        TextInput({ text: $$this.searchText, placeholder: $r('app.string.search') })
          .fontSize($r('sys.float.Body_L'))
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor($r('sys.color.font_secondary'))
          .margin({ top: $r('app.float.vp_2') })
          .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_2') })
          .enterKeyType(EnterKeyType.Search)
          .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
            this.searchVM.searchText = event.text;
            this.onSubmitSearch();
          })
          .onChange((value: string) => {
            if (value === undefined || value.length === 0) {
              this.searchVM.searchText = '';
              this.searchVM.searching = false;
            }
            this.searchText = value;
          })

        Image($r('app.media.clear'))
          .width($r('app.float.vp_40'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.float.vp_12'))
          .visibility(this.searchText?.length > 0 ? Visibility.Visible : Visibility.Hidden)
          .backgroundColor(Color.Transparent)
          .margin({ right: $r('app.float.vp_4') })
          .onClick(() => {
            this.searchText = '';
            this.searchVM.searchText = '';
            this.searchVM.searching = false;
          })
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
      .height($r('app.float.vp_40'))
      .backgroundColor($r('sys.color.gray_01'))
      .borderRadius($r('app.float.vp_20'))
      .padding({
        left: $r('app.float.vp_12'),
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height($r('app.float.vp_40'))
  }
}