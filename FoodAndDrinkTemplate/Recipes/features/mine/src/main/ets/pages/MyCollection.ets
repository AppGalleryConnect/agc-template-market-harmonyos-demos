import { buildTitleBar } from 'commonlib';
import { Recipes } from '../components/Recipes';
import { MyCollectionVM } from '../viewModels/MyCollectionVM';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function MyCollectionBuilder() {
  MyCollection();
}

@ComponentV2
struct MyCollection {
  vm: MyCollectionVM = MyCollectionVM.instance;

  build() {
    NavDestination() {
      Recipes({ recipeList: this.vm.collections });
    }
    .title(buildTitleBar('我的收藏'), { paddingStart: LengthMetrics.vp(16) })
    .padding({top: 40})
    .onWillShow(() => {
      this.vm.queryCollection();
    });
  }
}

