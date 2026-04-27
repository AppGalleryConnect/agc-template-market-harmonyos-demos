import { SearchController } from '../controller/SearchController';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct SearchComponent {
  private searchController: SearchController = SearchController.instance;
  @Local searchCondition: string = '';
  @BuilderParam imageBuilder?: VoidCallback;
  @BuilderParam hotSearchBuilder?: VoidCallback;
  @BuilderParam historySearchBuilder: VoidCallback;
  @BuilderParam searchResultBuilder: VoidCallback;
  @Param @Require getSearchResult: VoidCallback;
  @Param @Require placeholderText: string
  @Local textWidth: number = 0;
  @Event popPage: () => void = () => {
  }

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
            this.popPage();
          });
        Blank();
        Search({
          placeholder: this.placeholderText,
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
              promptAction.showToast({
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
          .fontColor('rgba(0,0,0,0.90)')
          .onClick(() => {
            if (this.searchCondition === undefined ||
              this.searchCondition === '') {
              promptAction.showToast({
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
        if (this.imageBuilder) {
          this.imageBuilder()
        }
        Column({ space: 30 }) {
          if (this.searchController.historySearch.length > 0) {
            this.historySearchBuilder();
          }
          if (this.hotSearchBuilder) {
            this.hotSearchBuilder()
          }
        }
        .padding({
          top: 20,
        });
      } else {
        this.searchResultBuilder();
      }
    }
    .width('100%')
  }
}