import { FilterList, FilterOption, LayoutType } from 'module_filter_list';

@Entry
@ComponentV2
export struct FilterComponentPage {
  types: string[] = ['一居室', '两居室', '三居室', '四居室'];
  styles: string[] = ['原木风', '简约风', '新中式', '奶油风'];
  @Local typeIndex: number = 0;
  @Local styleIndex: number = 0;
  @Local listArr: string[] = new Array(5).fill('');
  @Local filterOptions: FilterOption[] = [
    new FilterOption('房屋户型', this.typeIndex, this.types),
    new FilterOption('房屋风格', this.styleIndex, this.styles),
  ];

  build() {
    Column() {
      FilterList(
        {
          filterOptions: this.filterOptions,
          layoutStyle: LayoutType.SPLIT,
          onchange: (res) => {
            this.typeIndex = res[0].selectIndex;
            this.styleIndex = res[1].selectIndex;
          },
        },
      ) {
        List({ space: 12 }) {
          ForEach(this.listArr, (item: string, index) => {
            ListItem() {
              Column({ space: 12 }) {
                Image($r('app.media.sample')).width('100%').height(140).borderRadius(16);
                Text(this.types[this.typeIndex] + '  ' + this.styles[this.styleIndex]);
              };
            };
          }, (item: string, index) => JSON.stringify(item) + index);

        }
        .padding({ top: 12, right: 16, left: 16 })
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      };
    };
  }
}
