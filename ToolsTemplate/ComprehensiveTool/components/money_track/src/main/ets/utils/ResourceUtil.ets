import { PersistenceV2 } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BillConstants } from '../commons/Constants';
import { BalanceChangeType } from '../commons/Enums';
import {
  BalanceResourceItemModel,
  BalanceResourceModel,
} from '../commons/Models';
import { BalanceResourceItem } from '../commons/Types';
import { toastUtil } from './ToastUtil';

@ObservedV2
class ResourceUtil {
  @Trace private _resource: BalanceResourceModel;

  constructor() {
    if (!deviceInfo.deviceType) {
      this._resource = new BalanceResourceModel();
    } else {
      this._resource = PersistenceV2.connect(
        BalanceResourceModel,
        () => new BalanceResourceModel(),
      )!;
    }
    this.getResourceList();
  }

  @Computed
  public get displayIncomeResource() {
    const list = Array.from(this._resource.income).map((item) => {
      const initItem = BillConstants.INCOME_RESOURCE_MAP.find(
        (it) => it.key === item.key,
      );
      const displayItem: BalanceResourceItem = {
        key: item.key,
        name: item.name,
        type: BalanceChangeType.INCOME,
        icon: initItem?.icon ?? $r('app.media.ic_income_others'),
        uncheckedIcon:
          initItem?.uncheckedIcon ?? $r('app.media.ic_income_unchecked_others'),
        sortNum: item.sortNum,
        isCustom: item.isCustom,
      };
      return displayItem;
    });
    return list;
  }

  @Computed
  public get displayExpenseResource() {
    const list = Array.from(this._resource.expense).map((item) => {
      const initItem = BillConstants.EXPENSE_RESOURCE_MAP.find(
        (it) => it.key === item.key,
      );
      const displayItem: BalanceResourceItem = {
        key: item.key,
        name: item.name,
        type: BalanceChangeType.EXPENSE,
        icon: initItem?.icon ?? $r('app.media.ic_expense_others'),
        uncheckedIcon:
          initItem?.uncheckedIcon ??
          $r('app.media.ic_expense_unchecked_others'),
        sortNum: item.sortNum,
        isCustom: item.isCustom,
      };
      return displayItem;
    });
    return list;
  }

  // 获取账单来源列表
  public getResourceList() {
    if (!this._resource?.income?.length && !this._resource?.expense?.length) {
      this._createResourceMap();
      return this._resource;
    }
    return this._resource;
  }

  // 获取账单来源单项数据
  public getResourceItem(key: number): BalanceResourceItem {
    const list =
      key > 200 ? this.displayIncomeResource : this.displayExpenseResource;
    const resource = list.find((item) => item.key === key)!;
    return resource;
  }

  // 新增自定义来源，应用卸载后失效
  public addResource(name: string, type: BalanceChangeType) {
    const isIncome: boolean = Boolean(type === BalanceChangeType.INCOME);
    try {
      const sortNum = isIncome
        ? this._resource.income.length
        : this._resource.expense.length;
      const key: number = isIncome ? 201 + sortNum : 101 + sortNum;
      const item: BalanceResourceItemModel = this._createResourceModel(
        key,
        name,
        sortNum,
        type,
      );
      item.isCustom = 1;
      if (type === BalanceChangeType.INCOME) {
        this._resource.income.push(item);
      } else {
        this._resource.expense.push(item);
      }
      toastUtil.showToast('自定义分类添加成功~');
      return true;
    } catch {
      toastUtil.showToast('自定义分类添加失败');
      return false;
    }
  }

  // 编辑自定义来源
  public editCustomResource(
    key: number,
    type: BalanceChangeType,
    newName: string,
  ) {
    const isIncome: boolean = Boolean(type === BalanceChangeType.INCOME);
    let existItem: BalanceResourceItemModel | undefined = undefined;
    if (isIncome) {
      existItem = this._resource.income.find((item) => item.key === key);
    } else {
      existItem = this._resource.expense.find((item) => item.key === key);
    }
    if (!existItem) {
      return false;
    }
    existItem.name = newName;
    return true;
  }

  // 删除自定义来源
  public deleteCustomResource(key: number) {
    const list = key > 200 ? this._resource.income : this._resource.expense;
    const idx = list.findIndex((item) => item.key === key)!;
    if (typeof idx === 'number') {
      list.splice(idx, 1);
      return true;
    }
    return false;
  }

  private _createResourceMap() {
    BillConstants.INCOME_RESOURCE_MAP.forEach((item) => {
      const resource = this._createResourceModel(
        item.key,
        item.name,
        item.sortNum,
        BalanceChangeType.INCOME,
        item.isCustom,
      );
      this._resource.income.push(resource);
    });
    this._resource.income.sort((a, b) => a.sortNum - b.sortNum);
    BillConstants.EXPENSE_RESOURCE_MAP.forEach((item) => {
      const resource = this._createResourceModel(
        item.key,
        item.name,
        item.sortNum,
        BalanceChangeType.EXPENSE,
        item.isCustom,
      );
      this._resource.expense.push(resource);
    });
    this._resource.expense.sort((a, b) => a.sortNum - b.sortNum);
  }

  private _createResourceModel(
    key: number,
    name: string,
    sortNum: number,
    type: BalanceChangeType,
    isCustom: number = 0,
  ): BalanceResourceItemModel {
    const item = new BalanceResourceItemModel();
    item.key = key;
    item.name = name;
    item.sortNum = sortNum;
    item.type = type;
    item.isCustom = isCustom;
    return item;
  }
}

const resourceUtil = new ResourceUtil();

export { resourceUtil as ResourceUtil };
