import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { selectData } from '../constants';
import {
  addRemakeToOrder,
  deleteOrder,
  ExpressStatus,
  getOrderCount,
  getOrderList,
  GetOrderListRequest,
  IOrder,
  OrderStatus,
  OrderType,
} from 'lib_foundation';
import { BaseViewModel, contextUtil, IAddrInfo, Logger, toastUtil } from 'module_base';


@ObservedV2
export class QueryPageVM extends BaseViewModel {
  private static _instance: QueryPageVM;
  context: common.UIAbilityContext = contextUtil.getContext() as common.UIAbilityContext;
  @Trace public orderList: IOrder[] = []
  @Trace public selectedIndex: number = 0
  @Trace public selectedOrder: IOrder | undefined
  @Trace public type: OrderType = OrderType.SEND
  @Trace public status: OrderStatus = OrderStatus.SUCCESS
  @Trace public sendCount: number = 0
  @Trace public getCount: number = 0
  @Trace public pendingCount: number = 0
  @Trace public selectData: SelectOption[] = selectData
  @Trace public deleteExpressId: number = 0
  @Trace public remake: string = ''
  @Trace public searchText: string = ''
  @Trace public selectedExpressStatus: string = ''
  @Trace public sendAddress: IAddrInfo | undefined
  @Trace public getAddress: IAddrInfo | undefined

  public static get instance() {
    if (!QueryPageVM._instance) {
      QueryPageVM._instance = new QueryPageVM();
    }
    return QueryPageVM._instance;
  }

  init() {
    if (this.userInfoModel.isLogin) {
      this.getOrderCount()
      this.getOrderList()
    }
  }

  public reFresh() {
    this.getOrderCount()
    this.getOrderList()
  }

  public logout() {
    this.orderList = []
    this.sendCount = 0
    this.getCount = 0
    this.pendingCount = 0
  }

  public async getOrderList() {
    const data: GetOrderListRequest = {
      type: this.type,
      status: this.status,
      cellphone: '',
      orderNo: '',
      expressStatus: this.selectedExpressStatus as ExpressStatus,
    }
    if (this.searchText.length === 11) {
      data.cellphone = this.searchText
    } else {
      data.orderNo = this.searchText
    }
    const res = await getOrderList(data)
    this.orderList = res
    if (this.type === OrderType.SEND) {
      this.sendCount = res.length
    }
    if (this.type === OrderType.RECEIVE) {
      this.getCount = res.length
    }
    if (this.type === OrderType.ALL) {
      this.pendingCount = res.length
    }
  }

  public async getOrderCount() {
    const res = await getOrderCount()
    this.sendCount = res[0]
    this.getCount = res[1]
    this.pendingCount = res[2]
  }

  public async deleteOrder(id: number) {
    await deleteOrder(id)
    toastUtil.showToast('删除成功！');
    this.reFresh()
  }

  public async addRemakeToOrder(id: number, remake: string) {
    await addRemakeToOrder({ id, remake })
    toastUtil.showToast('修改成功！');
    this.remake = ''
    this.reFresh()
  }

  public async prepay() {
    paymentService
      .requestPayment(this.context, '')
      .then(() => {
        Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
        toastUtil.showToast('支付失败！');
        Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }
}
