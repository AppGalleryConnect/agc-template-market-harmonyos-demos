import { Recipes } from '../components/Recipes';
import { BrowsingHistoryVM } from '../viewModels/BrowsingHistoryVM';

@Builder
export function BrowsingHistoryBuilder() {
  BrowsingHistory();
}

@ComponentV2
struct BrowsingHistory {
  vm: BrowsingHistoryVM = BrowsingHistoryVM.instance;

  aboutToAppear(): void {
    this.vm.queryRecipeHistory()
  }

  build() {
    NavDestination() {
      Recipes({ recipeList: this.vm.history });
    }.title('浏览记录');
  }
}

