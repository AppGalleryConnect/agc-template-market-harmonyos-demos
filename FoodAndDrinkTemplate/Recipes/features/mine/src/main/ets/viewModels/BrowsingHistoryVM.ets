import { queryRecipeHistoryList } from 'network';
import { historyListMapper } from '../mapper/Index';
import { RecipeItem } from '../types/Index';
import { common } from '@kit.AbilityKit';
import { RdbManager, recipesData, CommonConstants, GlobalContextUtils } from 'commonlib';

@ObservedV2
export class BrowsingHistoryVM {
  private static _instance: BrowsingHistoryVM;
  @Trace history: RecipeItem[] = [];
  private context: common.UIAbilityContext = GlobalContextUtils.globalUIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);

  async queryRecipeHistory() {
    // rdb查询
    if (CommonConstants.RDB_FLAG) {
      await this.rdbManager.initDatabase(this.context);
      let result: recipesData[] = await this.rdbManager.query('', true);
      // 屏蔽菜谱上传的数据，因为是模拟，实际上没有id对应的详情，实际开发需要删除这行代码
      result = result.filter((item) => item.views !== 0)
      this.history = historyListMapper(result);
    } else {
      // 接口查询
      const res = await queryRecipeHistoryList();
      this.history = historyListMapper(res.data);
    }
  }

  public static get instance() {
    if (!BrowsingHistoryVM._instance) {
      BrowsingHistoryVM._instance = new BrowsingHistoryVM();
    }
    return BrowsingHistoryVM._instance;
  }
}
