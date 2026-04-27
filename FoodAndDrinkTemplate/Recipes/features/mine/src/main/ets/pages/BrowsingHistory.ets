import { buildTitleBar } from 'commonlib';
import { Recipes } from '../components/Recipes';
import { BrowsingHistoryVM } from '../viewModels/BrowsingHistoryVM';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function BrowsingHistoryBuilder() {
  BrowsingHistory();
}

@ComponentV2
struct BrowsingHistory {
  vm: BrowsingHistoryVM = BrowsingHistoryVM.instance;

  aboutToAppear(): void {
    this.vm.queryRecipeHistory();
  }

  build() {
    NavDestination() {
      Recipes({ recipeList: this.vm.history });
    }
    .title(buildTitleBar('浏览记录'), { paddingStart: LengthMetrics.vp(16) })
    .padding({top: 40})
  }
}

