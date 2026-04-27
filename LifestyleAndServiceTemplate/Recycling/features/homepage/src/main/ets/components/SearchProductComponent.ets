import { promptAction } from '@kit.ArkUI';
import { Constants } from 'common';
import { SearchProductPageVM } from '../viewmodel/SearchProductPageVM';

@ComponentV2
export struct SearchProductComponent {
  private searchController: SearchProductPageVM = SearchProductPageVM.instance;
  @Param @Require appPathStack: NavPathStack;
  @BuilderParam hotSearchBuilder: VoidCallback;
  @BuilderParam historySearchBuilder: VoidCallback;
  @BuilderParam searchResultBuilder: VoidCallback;
  @BuilderParam phoneSelectBuilder: VoidCallback;
  @BuilderParam photoSelectBuilder: VoidCallback;
  @BuilderParam watchSelectBuilder: VoidCallback;
  @Param @Require getSearchResult: VoidCallback;
  @Local textWidth: number = 0;
  @Event backFunc: () => void = () => {
  };

  aboutToAppear(): void {
    // 清空搜索条件
    this.searchController.searchCondition = '';
    this.searchController.isShowResult = false;
    this.searchController.searchResult.productList = [];
  }

  @Monitor('searchController.searchCondition')
  searchConditionMonitor(monitor: IMonitor) {
    this.searchController.searchCondition = monitor.value()?.now as string;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .onClick(() => {
            this.searchController.isShowResult = false;
            // 调用返回方法
            this.backFunc();
          });
        Blank();
        Search({
          placeholder: '请输入',
          value: $$this.searchController.searchCondition,
        })
          .textFont({
            size: $r('sys.float.Body_L'),
            weight: FontWeight.Regular
          })
          .fontColor($r('sys.color.font_primary'))
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
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0,0,0,0.90)')
          .onClick(() => {
            if (this.searchController.searchCondition === undefined ||
              this.searchController.searchCondition === '') {
              promptAction.showToast({
                message: '请输入搜索内容',
                duration: 1000,
              });
              return;
            }
            this.searchController.isShowResult = true;
            this.searchController.updateHistorySearch(this.searchController.searchCondition);
            this.getSearchResult();
          });
      }
      .width('100%')
      .padding({ left: 17, right:  16 })
      .margin({ top: Constants.PADDING_2XL })

      if (!this.searchController.isShowResult) {
        Column({ space: 24 }) {
          this.historySearchBuilder();
          this.hotSearchBuilder();
        }
        .padding({
          top: 15,
          left: 16
        });
      } else {
        this.searchResultBuilder();
      }
    }
    .width('100%')
    .height('100%');
  }
}