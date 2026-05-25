import { SearchController } from '../controller/SearchController';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct SearchComponent {
  private searchController: SearchController = SearchController.instance;
  @Param @Require appPathStack: NavPathStack;
  @Local searchCondition: string = '';
  @BuilderParam hotSearchBuilder: VoidCallback;
  @BuilderParam historySearchBuilder: VoidCallback;
  @BuilderParam searchResultBuilder: VoidCallback;
  @Param @Require getSearchResult: VoidCallback;
  @Local textWidth: number = 0;

  @Monitor('searchController.searchCondition')
  searchConditionMonitor(monitor: IMonitor) {
    this.searchCondition = monitor.value()?.now as string;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .onClick(() => {
            this.searchController.isShowResult = false;
            this.appPathStack.pop();
          });
        Blank();
        Search({
          placeholder: '请输入关键字查询',
          value: $$this.searchCondition,
        })
          .placeholderFont({
            size: $r('sys.float.Body_L'),
          })
          .placeholderColor($r('sys.color.font_secondary'))
          .layoutWeight(1)
          .margin({
            left: '4%',
            right: '4%',
          })
          .onChange((searchCondition: string) => {
            if (searchCondition === '') {
              this.searchController.isShowResult = false;
              this.searchController.searchCondition = '';
            }
          })
          .onSubmit((searchCondition: string) => {
            if (searchCondition === undefined || searchCondition === '') {
              this.getUIContext().getPromptAction().showToast({
                message: '请输入搜索内容',
                duration: 1000,
              });
              return;
            }

            this.searchController.isShowResult = true;
            this.searchController.updateHistorySearch(searchCondition);
            this.searchController.searchCondition = searchCondition;
            this.getSearchResult();
          });

        Blank();
        Text('搜索')
          .fontSize(14)
          .fontColor($r('app.color.base_font_color'))
          .onClick(() => {
            if (this.searchCondition === undefined ||
              this.searchCondition === '') {
              this.getUIContext().getPromptAction().showToast({
                message: '请输入搜索内容',
                duration: 1000,
              });
              return;
            }
            this.searchController.isShowResult = true;
            this.searchController.searchCondition = this.searchCondition;
            this.searchController.updateHistorySearch(this.searchCondition);
            this.getSearchResult();
          });
      }
      .width('100%');

      if (!this.searchController.isShowResult) {
        Column({ space: 30 }) {
          this.hotSearchBuilder();
          this.historySearchBuilder();
        }
        .layoutWeight(1)
        .padding({
          top: 20,
        });
      } else {
        this.searchResultBuilder();
      }
    }
    .width('100%')
    .height('100%');
  }
}