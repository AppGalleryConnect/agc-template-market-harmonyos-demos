import { getColor, getMedia, getString } from '@agctemplate/resources'
import { SlicedText, StringUtil } from '@agctemplate/utils'
import { AppStorageV2 } from '@kit.ArkUI'
import { SearchRecords } from '../viewmodels/SearchRecordsVM'

@ComponentV2
export struct SearchTipPanel {
  @Param @Require searchText: string
  @Param @Require tipInfos: Array<string>
  @Event searchEvent: Function = () => {}
  @Local searchRecords: SearchRecords = AppStorageV2.connect(SearchRecords, () => new SearchRecords())!

  build() {
    Row() {
      if (this.tipInfos.length > 0) {
        Column() {
          ForEach(this.tipInfos, (tipInfo: string) => {
            Row() {
              Column() {
                SymbolGlyph($r('sys.symbol.magnifyingglass'))
                  .fontSize(16)
                  .fontColor([$r('sys.color.icon_primary')])
              }

              Column() {
                Text() {
                  ForEach(StringUtil.getSlicedText(tipInfo, this.searchText, true), (itemText: SlicedText) => {
                    if (itemText.text && itemText.text !== '') {
                      Span(itemText.text)
                        .fontColor(itemText.isHighlight ?
                        getColor('app.color.high_light_font_color') : $r('sys.color.font_primary'))
                    }
                  }, (itemText: SlicedText, index: number) => {
                    return index + itemText.text
                  })
                }
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .margin({
                  top: 14,
                  bottom: 13,
                  left: 18
                })

                Divider()
                  .margin({
                    left: 18
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({
                right: 30
              })
              .onClick(() => {
                this.searchRecords.records.unshift(tipInfo.trim())
                this.searchEvent(tipInfo)
              })
            }
          }, (tipInfo: string, index: number) => {
            return index + '_' + tipInfo;
          })
        }
      } else {
        this.nullBuilder()
      }
    }
    .width('100%')
    .height(200)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  nullBuilder() {
    Column() {

      Image(getMedia('app.media.search_no_result'))
        .width(120)
        .aspectRatio(1)
        .margin({ top: 20 })
      Text(getString('app.string.search_null'))
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ top: 4, bottom: 10 })
    }
    .padding(12)
    .borderRadius(16)
    .width('100%')
  }
}