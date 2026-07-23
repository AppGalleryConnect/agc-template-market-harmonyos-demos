import { getColor, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { appRouter } from '@agctemplate/utils'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { AppStorageV2 } from '@kit.ArkUI'
import { SearchRecords } from '../viewmodels/SearchRecordsVM'

@ComponentV2
export struct SearchPanel {

  @Param @Require textController: TextInputController | undefined
  @Param @Require searchText: string
  @Param @Require isEdit: boolean
  @Param @Require searchResult: Array<DramaCoverVM> | undefined
  @Param @Require isInput: boolean
  @Event inputFocusEvent: Function | undefined
  @Event inputValueChangedEvent: Function | undefined
  @Event searchEvent: Function | undefined
  @Event clearText: Function
  @Local searchRecords: SearchRecords = AppStorageV2.connect(SearchRecords, () => new SearchRecords())!

  build() {
    Row() {
      Column() {
        Row() {
          Column() {
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .fontSize(16)
              .fontColor([$r('sys.color.icon_secondary')])
              .margin({
                left: 12, right: this.isInput ? 0 : 8
              })
          }
          .zIndex(this.isInput ? 10000 : 0)

          if(!this.isInput) {
            Column() {
              Text(getString('app.string.search_placeholder'))
                .height(40)
                .fontSize(16)
                .margin({
                  right: 28
                })
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
                .margin({
                  right: 28,
                  left: -8
                })
                .maxLines(1)
                .maxLength(15)
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
        .margin({
          top: 8,
          bottom: 8
        })
        .width('100%')
        .borderRadius(24)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          if(!this.isInput) {
            appRouter.push({
              builderName: NAV_PAGE_NAME.SearchPage.name
            })
          }
        })
      }
      .width('100%')
    }
    .padding({ left: 8,right: 8 })
    .layoutWeight(1)
  }
}