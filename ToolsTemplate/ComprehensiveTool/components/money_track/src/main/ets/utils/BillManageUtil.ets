import { BillCardItem } from '../commons/Types';
import { billManageSheetBuilder, BillManageSheetOptions } from '../components/BillManageSheet';
import { resourceManageSheetBuilder, ResourceManageSheetOptions } from '../components/ResourceManageSheet';
import { AccountingDB } from './accountingdb/AccountingDB';
import { UserTransaction, TransactionTableBasis } from './accountingdb/Types';
import { PopViewUtil } from './PopViewUtil';

class BillManageUtil {
  public manageBill(
    initBill: BillCardItem | undefined = undefined,
    assetId: number | undefined = undefined,
    callback?: (data: UserTransaction) => void,
  ) {
    PopViewUtil.openSheet(
      wrapBuilder(billManageSheetBuilder),
      {
        detents: [SheetSize.LARGE],
        title: { title: '记一笔' },
        preferType:SheetType.BOTTOM,
      },
      {
        initBill,
        handleConfirm: (data: UserTransaction) => {
          if (!initBill) {
            this._addBill(data, assetId, callback);
          } else {
            this._editBill(data, callback);
          }
        },
        handleResourceManage: () => {
          this.openResourceManageSheet();
        },
      } as BillManageSheetOptions,
    );
  }

  public openResourceManageSheet() {
    PopViewUtil.openSheet(
      wrapBuilder(resourceManageSheetBuilder),
      {
        detents: [SheetSize.FIT_CONTENT],
        title: { title: '分类管理' },
        backgroundColor: '#ffffff',
        preferType:SheetType.BOTTOM,
      },
      {
        handleDeleteSuccess: async (key) => {
          await AccountingDB.deleteTransactionsByResource(key);
        },
      } as ResourceManageSheetOptions,
    );
  }

  private async _addBill(
    data: UserTransaction,
    assetId: number | undefined = undefined,
    callback?: (data: UserTransaction) => void,
  ) {
    if (typeof assetId === 'number') {
      data.assetId = assetId;
    }
    await AccountingDB.addTransaction(data);
    PopViewUtil.closeSheet();
    callback?.(data);
  }

  private async _editBill(
    data: UserTransaction,
    callback?: (data: UserTransaction) => void,
  ) {
    await AccountingDB.updateTransactions(data as TransactionTableBasis);
    PopViewUtil.closeSheet();
    callback?.(data);
  }
}

const util = new BillManageUtil();

export { util as BillManageUtil };
