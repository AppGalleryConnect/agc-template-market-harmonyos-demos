import { CommonPicker } from './CommonPicker';
import { DrawerController, Drawer } from './Drawer';
import { FilterOption, ResultItem, LayoutType } from '../types/Index';

@ComponentV2
export struct FilterList {
  @Param filterOptions: FilterOption[] = [
    new FilterOption('全部风格', -1,
      ['全部风格', '现代简约', '极简', '轻奢风', '奶油风', '北欧风', '原木风', '复古风', '日式', '新中式', '法式',
        '美式', '混搭风', '小清新', '大理石', '其他']),
    new FilterOption('全部户型', -1, ['全部户型', '一居室', '二居室', '三居室', '四居以上', '复式', '样板间', '别墅']),
    new FilterOption('全部面积', -1,
      ['全部面积', '60㎡以下', '60-80㎡', '81-100㎡', '101-120㎡', '121-150㎡', '151-200㎡', '200㎡以上']),
    new FilterOption('全部造价', -1,
      ['全部造价', '0-5万', '5-10万', '10-15万', '15-20万', '20-25万', '25-30万', '30万以上']),
  ];
  @Param layoutStyle: LayoutType = LayoutType.DEFAULT;
  @BuilderParam listBuilderParam: () => void = this.lisBuilder;
  @Local isDrawOpen: boolean = false;
  @Local curIndex: number = -1;
  @Local selectResult: ResultItem[] = [];
  controller: DrawerController = new DrawerController();
  @Event onchange: (res: ResultItem[]) => void = () => {

  };

  @Builder
  lisBuilder() {

  }

  build() {
    Column() {
      Row({ space: 16 }) {
        ForEach(this.filterOptions, (item: FilterOption, index) => {
          Row({ space: 2 }) {
            Text(item.selectArr[item.selectIndex] || item.name)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor(this.curIndex === index && this.isDrawOpen ? $r('sys.color.font_primary') :
              $r('sys.color.font_secondary'));
            Image(this.curIndex === index && this.isDrawOpen ? $r('app.media.ic_arrow_on') :
            $r('app.media.ic_arrow_off'))
              .width(12).height(12);
          }.onClick(() => {
            if (this.isDrawOpen && this.curIndex === index) {
              this.controller.close();
              this.curIndex = -1;
            } else {
              this.curIndex = index;
              this.controller.open();
            }
          });
        }, (item: FilterOption) => item.name + item.selectIndex);
      }
      .width('100%')
      .height(39)
      .padding({ top: 8 })
      .justifyContent(this.layoutStyle === LayoutType.DEFAULT ? FlexAlign.SpaceBetween : FlexAlign.Start)
      .padding({ left: 16, right: 16 });

      if (this.layoutStyle === LayoutType.SPLIT) {
        Divider().width('100%').color($r('sys.color.comp_divider'));
      }

      Drawer({
        controller: this.controller,
        onDrawChange: (res) => {
          this.isDrawOpen = res;
        },
      }) {
        CommonPicker({
          curIndex: this.filterOptions[this.curIndex].selectIndex,
          contentArr: this.filterOptions[this.curIndex].selectArr,
          onItemClick: (index) => {
            this.filterOptions[this.curIndex].selectIndex = index;
            this.selectResult = this.filterOptions.map((item) => {
              const obj: ResultItem = {
                filterName: item.name,
                selectIndex: item.selectIndex,
              };
              return obj;
            });
            this.onchange(this.selectResult);
            this.controller.close();
          },
        });
      };

      this.listBuilderParam();
    }.width('100%').layoutWeight(1);
  }
}