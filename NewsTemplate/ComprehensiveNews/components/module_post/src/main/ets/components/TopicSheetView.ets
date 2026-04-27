import { Topic } from '../types/Types';
import { emptyBuilder } from './EmptyView';

@ComponentV2
export struct TopicSheetView {
  @Param topicList: Topic[] = [];
  @Event onSelect: (topic: Topic) => void = () => {
  };
  @Event jumpTopicPage: (topic: Topic) => void = () => {
  };
  @Local topicSearchValue: string = '';

  @Computed
  get isSearchMode() {
    return this.topicSearchValue !== '';
  }

  @Computed
  get filterList() {
    return this.topicList.filter(topic => topic.title.includes(this.topicSearchValue));
  }

  build() {
    Column() {
      Search({ value: $$this.topicSearchValue, placeholder: '搜索话题' })
        .width('100%')
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 8 })

      List() {
        ForEach(this.filterList, (topic: Topic, index: number) => {
          ListItem() {
            Row() {
              Text(index + 1 + '.')
                .fontSize(14)
                .fontColor(index <= 2 ? $r('sys.color.warning') : $r('sys.color.font_secondary'))
                .constraintSize({ minWidth: 24 })
                .visibility(this.isSearchMode ? Visibility.None : Visibility.Visible)
              Text(topic.title)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .layoutWeight(1)

              Row() {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontColor([$r('sys.color.font_secondary')])
                  .fontWeight(FontWeight.Normal)
                  .fontSize(24)
              }
              .padding({ left: 24 })
              .onClick(() => {
                this.jumpTopicPage(topic);
              })
            }
            .width('100%')
            .height(40)
            .onClick(() => {
              this.onSelect(topic);
            })
          }
        }, (topic: Topic) => topic.id)

        ListItem() {
          emptyBuilder()
        }
        .layoutWeight(1)
        .visibility(this.filterList.length <= 0 ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .padding({ bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }
}