import { getColor, getMedia, getString } from '@agctemplate/resources'
import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { AppStorageV2 } from '@kit.ArkUI'
import { LiveCardModel } from '@agctemplate/widgets'
import { SearchRecords } from '../viewmodels/SearchRecordsVM'

@ComponentV2
export struct SearchPanel {
  @Param @Require textController: TextInputController | undefined
  @Param @Require searchText: string
  @Param @Require isEdit: boolean
  @Param @Require searchResult: Array<LiveCardModel> | undefined
  @Param @Require isInput: boolean
  @Param @Require backToSearch: boolean
  @Event inputFocusEvent: Function | undefined
  @Event inputValueChangedEvent: Function | undefined
  @Event searchEvent: Function | undefined
  @Event clearText: Function
  @Event backSearch: Function
  @Local searchRecords: SearchRecords = AppStorageV2.connect(SearchRecords, () => new SearchRecords())!

  build() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .size({ width: 40, height: 40 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .margin({ right: 8 })
      .onClick(() => {
        if (this.backToSearch) {
          this.backSearch()
        } else {
          RouterModule.pop()
        }
      })

      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_primary')])
            .margin({
              left: 12, right: this.isInput ? 0 : 8
            })
        }
        .zIndex(this.isInput ? 10000 : 0)

        if (!this.isInput) {
          Column() {
            Text(getString('app.string.search_placeholder'))
              .height(40)
              .fontSize(16)
              .fontColor($r('sys.color.font_secondary'))
          }
        } else {
          Column() {
            TextInput({
              controller: this.textController,
              placeholder: getString('app.string.search_placeholder'),
              text: this.searchText
            })
              .height(40)
              .maxLines(1)
              .maxLength(13)
              .caretColor('#EE5D1A')
              .placeholderColor($r('sys.color.font_secondary'))
              .backgroundColor('transparent')
              .defaultFocus(true)
              .onChange((value: string) => {
                this.inputValueChangedEvent?.(value)
              })
              .onFocus(() => {
                this.inputFocusEvent?.()
              })
              .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
                if (event.text.trim() !== '') {
                  this.searchRecords.records.unshift(event.text.trim())
                }
                this.searchEvent?.(event.text)
              })
          }
        }
        if (this.searchText) {
          Text('󰁖')
            .textAlign(TextAlign.Center)
            .fontColor($r('sys.color.icon_secondary'))
            .width(16)
            .height(16)
            .offset({ x: -60 })
            .onClick(() => {
              this.clearText()
            })
        }
      }
      .width('90%')
      .borderRadius(24)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (!this.isInput) {
          RouterModule.push({ url: RouterMap.SEARCH_PAGE })
        }
      })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
  }
}