import { AppStorageV2, CommonModifier, PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { DisplayModel } from 'common';
import { WorkListViewModel, WorkViewModel } from 'video_common';

@ObservedV2
export class WorkListPageVM {
  private static _instance: WorkListPageVM;
  tabsController: TabsController = new TabsController();
  tabBarModifier: CommonModifier = new CommonModifier();
  @Trace displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
  @Trace deleteId: string = '';
  @Trace currentTabIndex: number = 0;
  @Trace workList: WorkListViewModel =
    PersistenceV2.connect(WorkListViewModel, 'WorkList', () => new WorkListViewModel())!;

  // 响应式计算分类列表
  @Computed
  public get finishList(): WorkViewModel[] {
    return this.workList.getFinishWorkList();
  }

  @Computed
  public get draftList(): WorkViewModel[] {
    return this.workList.getUnFinishWorkList();
  }

  public static get instance() {
    if (!WorkListPageVM._instance) {
      WorkListPageVM._instance = new WorkListPageVM();
    }
    return WorkListPageVM._instance;
  }

  // 初始化加载数据
  public async init(context: common.UIAbilityContext) {
    this.workList = PersistenceV2.connect(WorkListViewModel, 'WorkList', () => new WorkListViewModel())!;
  }

  // 删除选中的列表
  deleteWork() {
    const deleteIndex = this.workList.lists.findIndex(item => item.id === this.deleteId);
    if (deleteIndex >= 0) {
      this.workList.removeList(deleteIndex);
      PersistenceV2.save('WorkList')
    }
  }
}