import { promptAction } from '@kit.ArkUI';
import { Constants } from 'common';
import { MyOrderSearchPageVM } from '../../viewmodel/MyOrderSearchPageVM';

@ComponentV2
export struct SearchMyOrderComponent {
  private searchController: MyOrderSearchPageVM = MyOrderSearchPageVM.instance;
  @Param @Require appPathStack: NavPathStack;
  @BuilderParam historySearchBuilder: VoidCallback;
  @BuilderParam searchResultBuilder: VoidCallback;
  @Local textWidth: number = 0;
  @Event backFunc: () => void = () => {
  };
  @Param @Require getSearchResult: VoidCallback;

  @Monitor('searchController.searchCondition')
  searchConditionMonitor(monitor: IMonitor) {
    this.searchController.searchCondition = monitor.value()?.now as string;
  }

  aboutToAppear(): void {
    // 清空搜索条件
    this.searchController.searchCondition = '';
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .onClick(() => {
            this.searchController.isShowResult = false;
            // 调用返回方法
            this.backFunc();
          })
          .width(40)
        Blank();
        Search({
          value: $$this.searchController.searchCondition,
          placeholder: '请输入',
        })
          .textFont({
            weight: FontWeight.Regular,
            size: $r('sys.float.Body_L')
          })
          .placeholderFont({
            size: $r('sys.float.Body_L'),
          })
          .fontColor($r('sys.color.font_primary'))
          .placeholderColor($r('sys.color.font_secondary'))
          .layoutWeight(1)
          .margin({
            right: '4%',
            left: '4%',
          })
          .onChange((searchCondition: string) => {
            if (searchCondition === '') {
              this.searchController.searchCondition = '';
              this.searchController.isShowResult = false;
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
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0,0,0,0.90)')
          .fontSize(14)
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
      .margin({ top: Constants.PADDING_2XL })
      .padding({ left: 17, right: 16 })

      if (!this.searchController.isShowResult) {
        Column({ space: 24 }) {
          this.historySearchBuilder();
        }
        .padding({
          left: 16,
          top: 15
        });
      } else {
        this.searchResultBuilder();
      }
    }
    .height('100%')
    .width('100%')
  }
}