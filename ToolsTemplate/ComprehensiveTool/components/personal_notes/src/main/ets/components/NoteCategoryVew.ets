import { CategoryController } from '../controller/CategoryController';
import { Category } from '../models/Category';
import { CategoryUtil } from '../utils/CategotyUtil';


@ComponentV2
export struct NoteCategoryVew {
  @Param @Require currentCategory: Category;
  @Event resetCategory: (category: Category) => void = (category: Category) => {}
  @Event editCategory: () => void = () => {}

  categoryUtil: CategoryUtil = CategoryUtil.instance;
  categoryController: CategoryController = CategoryController.instance;

  build() {
    Column() {
      Column() {
        List() {
          ForEach(this.categoryUtil.getCategoryList(), (category: Category, index: number) => {
            ListItem() {
              Column() {
                if (index !== 0) {
                  Divider().color($r('sys.color.comp_divider'));
                }
                Row() {
                  Text(category.name)
                    .fontSize(16)
                    .fontColor(this.currentCategory.id === category.id ?
                    $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                    .fontWeight(this.currentCategory?.id === category.id ? FontWeight.Medium : FontWeight.Regular)

                  Blank();
                  Text(String(category.totalCount))
                    .fontSize(16);
                }
                .width('100%')
                .height(50)
              }
            }
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.resetCategory && this.resetCategory(category)
            });
          }, (category: Category) => category.id);
        }
        .borderRadius(8)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None);
      }
      .height(250);

      Blank();

      this.btnView()
    }
    .height(344)
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .backgroundColor($r('sys.color.background_secondary'));
  }

  @Builder
  btnView() {
    Button() {
      Row() {
        Text('前往笔记分类')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium);
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
          .fontColor([Color.White])
          .padding({
            left: 13,
          })
      }
    }
    .height(40)
    .width('100%')
    .backgroundColor('#FFAA00')
    .margin({ bottom: 30 })
    .onClick(() => {
      this.editCategory()
    });
  }
}