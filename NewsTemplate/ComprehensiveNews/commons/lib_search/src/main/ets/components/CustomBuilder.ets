import { FlexLayoutPage } from 'lib_flex_layout';
import { NewsResponse } from 'lib_news_api';
import { BaseAgent } from 'lib_widget';
import { SearchItem } from 'module_search';

/**
 * 自定义搜索结果项构建器（全局函数）
 */
@Builder
export function resultItemBuilder(item: SearchItem, searchValue: string) {
  FlexLayoutPage({
    setting: JSON.parse(item.setting || '{}'),
    articles: [item.rawData as NewsResponse],
    extraInfo: { 'searchKey': searchValue, 'channelId': 'searchResult', 'flexId': item.id as string },
  })
}

@Builder
export function searchAbstractBuilder(searchValue: string, searchAbstractResult: string) {
  Column({ space: 12 }) {
    Text('摘要：')
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
    Text(searchAbstractResult)
      .fontSize(14)
      .fontColor($r('sys.color.font_primary'))
      .lineHeight(20)
    BaseAgent({ queryText: searchValue })
  }
  .visibility(searchAbstractResult.length ? Visibility.Visible : Visibility.None)
  .padding(12)
  .margin({ top: 16 })
  .width('calc(100% - 32vp)')
  .borderRadius(16)
  .backgroundColor($r('sys.color.comp_background_tertiary'));
}
