import { TabIndexEnum } from 'base_ui';
import { FeaturedRecipes, LazyDataSource, RecipeBriefInfo } from 'featured_recipes';

@ComponentV2
export struct PersonalHomepage {
  @Param recipeList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Param currentIndex: number = TabIndexEnum.FIRST;
  @Param isToDelete: boolean = false;
  @BuilderParam uploadBuilderParam: () => void = this.uploadBuilder;
  @Event onClickCb: (id: number, index: number) => void = () => {
  }
  @Event jumpBloggerInfo: (id: number) => void = () => {
  }
  @Event deleteRecipes: (ids: number[]) => void = () => {
  }
  @Event changeDeleteState: (isToDelete: boolean) => void = () => {
  }
  @Event changeSelect: (id: number, flag: boolean) => void = () => {
  }

  @Builder
  uploadBuilder() {
  }

  @Computed
  get showDeleteBtn() {
    return this.isToDelete && this.currentIndex === TabIndexEnum.FIRST
  }

  build() {
    Column() {
      FeaturedRecipes({
        dishesList: this.recipeList,
        canDelete: this.showDeleteBtn,
        isToDelete: this.isToDelete,
        isLoading: false,
        hasMore: false,
        onClickCb: (id: number, index: number) => {
          this.onClickCb(id, index)
        },
        jumpBloggerInfo: (id: number) => {
          this.jumpBloggerInfo(id)
        },
        deleteRecipes: (ids: number[]) => {
          this.deleteRecipes(ids)
        },
        changeSelect: (id: number, flag: boolean) => {
          this.changeSelect(id, flag)
        },
        changeDeleteState: (isToDelete: boolean) => {
          this.changeDeleteState(isToDelete)
        },
      }) {
        if (this.currentIndex === TabIndexEnum.FIRST) {
          this.uploadBuilderParam()
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}