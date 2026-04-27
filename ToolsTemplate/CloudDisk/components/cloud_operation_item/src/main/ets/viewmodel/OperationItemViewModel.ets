import { OperationItemModel, OperationItemType } from '../model/OperationItemModel';

// OperationItemView视图管理模型
@ObservedV2
export class OperationItemViewModel {
  originalOperationCount: number = 0

  // 展示列表
  @Trace showList: OperationItemModel[] = []

  // 默认支持的操作类型
  private _operationList: OperationItemType[] = [];

  public get operationList(): OperationItemType[] {
    return this._operationList;
  }

  public set operationList(value: OperationItemType[]) {
    this._operationList = value;

    const result: OperationItemModel[] = []
    this._operationList.forEach((itemType: OperationItemType) => {
      const model = new OperationItemModel(itemType)
      result.push(model)
    })
    this.showList = result
  }

  // 选择操作项
  didSelectedItemAction: (actionType: OperationItemType) => void = () => {
  }

  // 构造函数
  constructor(items?: OperationItemType[], callbackAction?: (actionType: OperationItemType) => void) {
    this.operationList = items ?? [
      OperationItemType.DOWNLOAD,
      OperationItemType.DELETE,
      OperationItemType.SHARE,
      OperationItemType.RENAME,
      OperationItemType.MOVE,
      OperationItemType.MOVETO_PRIVATESPACE,
      OperationItemType.COLLECTED
    ]

    this.originalOperationCount = this._operationList.length

    if (callbackAction !== undefined) {
      this.didSelectedItemAction = callbackAction
    }
  }
}

