import { BalanceChangeType } from '../commons/Enums';
import { BalanceResourceModel } from '../commons/Models';
import { BalanceResourceItem } from '../commons/Types';
import { contextUtil } from '../utils/ContextUtil';
import { ResourceUtil } from '../utils/ResourceUtil';
import { toastUtil } from '../utils/ToastUtil';

@ObservedV2
export class ResourceManageVM {
  @Trace balanceType: BalanceChangeType = BalanceChangeType.EXPENSE;
  @Trace resource: BalanceResourceModel | undefined = undefined;
  @Trace customResourceName: string = '';
  @Trace editExist: boolean = false;
  @Trace selectedItem: BalanceResourceItem | undefined = undefined;

  @Computed
  public get displayResourceList() {
    if (this.balanceType === BalanceChangeType.INCOME) {
      return ResourceUtil.displayIncomeResource;
    }
    return ResourceUtil.displayExpenseResource;
  }

  public handleTypeChange(type: BalanceChangeType) {
    this.balanceType = type;
  }

  public addResource() {
    const isExist = this.displayResourceList.find(
      (item) => item.name === this.customResourceName,
    );
    if (isExist) {
      toastUtil.showToast('类型名称已存在~');
      return false;
    }
    if (!this.selectedItem) {
      const res = ResourceUtil.addResource(
        this.customResourceName,
        this.balanceType,
      );
      if (res) {
        this.customResourceName = '';
      }
      return true;
    } else {
      const res = ResourceUtil.editCustomResource(
        this.selectedItem.key,
        this.balanceType,
        this.customResourceName,
      );
      if (res) {
        return true;
      }
    }
    return false;
  }

  public async deleteResource(
    key: number,
    dialogId: number,
    callback?: (key: number) => void,
  ) {
    const res = ResourceUtil.deleteCustomResource(key);
    if (res) {
      callback?.(key);
      toastUtil.showToast('自定义类型删除成功~');
      contextUtil.getPromptAction()?.closeCustomDialog(dialogId);
      return;
    }
    toastUtil.showToast('自定义类型删除失败，请稍后重试');
  }

  public customSortResource(index1: number, index2: number) {
    const list =
      this.balanceType === BalanceChangeType.INCOME
        ? this.resource!.income
        : this.resource!.expense;
    if (index2 >= list.length) {
      return;
    }
    let temp = list[index1];
    let sortNum1 = list[index1].sortNum;
    let sortNum2 = list[index2].sortNum;
    list[index1] = list[index2];
    list[index1].sortNum = sortNum1;
    list[index2] = temp;
    list[index2].sortNum = sortNum2;
  }
}
