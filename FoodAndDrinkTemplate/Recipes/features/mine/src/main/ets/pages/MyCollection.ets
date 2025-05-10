import { Recipes } from '../components/Recipes';
import { MyCollectionVM } from '../viewModels/MyCollectionVM';

@Builder
export function MyCollectionBuilder() {
  MyCollection();
}

@ComponentV2
struct MyCollection {
  vm: MyCollectionVM = MyCollectionVM.instance;

  aboutToAppear(): void {
    this.vm.queryCollection();
  }

  build() {
    NavDestination() {
      Recipes({ recipeList: this.vm.collections });
    }.title('我的收藏');
  }
}

