import {
  TicketStatus,
  DateItem,
  TimeTicketInfo,
  TicketListItem,
  TicketOwner,
  Contacts,
  TicketOwnerRequest,
  TicketTypeInfo,
} from '../types/Index';
import { GetOrderDetailResp, https, PrepayBuyTicketRequest, OrderDetailRequest } from 'network';
import { AccountUtil, RouterModule, RouterMap, FormatUtil, Logger } from 'commonlib';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';


const TAG = '[BuyVM]';

@ObservedV2
export class BuyVM {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // 联系人列表
  @Trace contactList: Contacts[] = [];
  @Trace currentIndex: number = 0;
  @Trace currentHourIndex: number = -1;
  @Trace dayTicketInfo: TimeTicketInfo[] = [];
  // 允许选择的时间范围
  @Trace ableData: DateItem[] = [];
  // 禁止选择的时间
  @Trace disableData: DateItem[] = [];
  @Trace dayList: TimeTicketInfo[] = [];
  // 日历选择的日期
  @Trace selected: Date = new Date();
  // 当前预约的日期
  @Trace currentSelected: TimeTicketInfo | undefined = undefined;
  // 当前选择的时间段
  @Trace selectedTime: string = '';
  // 联系电话
  @Trace contactPhone: string = '';
  // 票种信息
  @Trace selectTicketInfo: TicketTypeInfo[] = [];
  @Trace dialogVisible: boolean = false;
  // 当前的须知
  @Trace notice: string[] = [];
  // 票总数
  @Trace totalTicket: number = 0;
  // 票总价
  @Trace totalPrice: number = 0;
  // 选择的购票人
  @Trace ticketOwner: TicketOwner[] = [];
  // 待选票
  @Trace ticketList: TicketListItem[] = [];
  // 演出id
  @Trace performanceId: string = '';
  // 演出名
  @Trace performanceName: string = '';
  // 购票成功生成的订单号
  @Trace orderNo: string = '';
  // 订单成功后返回的订单详情
  @Trace orderDetail: GetOrderDetailResp | undefined = undefined;
  @Trace ticketTypeMap: Map<string, string> =
    new Map([['1', '标准票'], ['2', '未成年人免票'], ['3', '老年人票'], ['4', '学生票']]);
  // 是否展示警告图标
  @Trace isWarning: boolean = false;
  private static _instance: BuyVM;

  public static get instance() {
    if (!BuyVM._instance) {
      BuyVM._instance = new BuyVM();
    }
    return BuyVM._instance;
  }


  public initData() {
    this.currentSelected = undefined;
    this.selectedTime = '';
    this.totalTicket = 0;
    this.totalPrice = 0;
    this.ticketList.length = 0;
    this.ticketOwner.length = 0;
  }

  public clearOrderInfo() {
    this.contactPhone = '';
    this.ticketOwner.length = 0;
    this.isWarning = false;
  }


  public async getTimeTicketInfo() {
    const params: Record<string, string> | undefined = RouterModule.getNavParam({ url: RouterMap.BUY_TICKET });
    if (params) {
      https.getTimeTicket(params.performanceId).then(res => {
        if (res.code === 0) {
          const data = res.data;
          //  截取前四位用于渲染
          this.dayList = data.slice(0, 4);
          this.dayTicketInfo = data;
          data.forEach((item) => {
            if (item.status === TicketStatus.HAVE.toString()) {
              this.ableData.push({ label: item.statusCn, date: item.date });
            } else {
              this.disableData.push({ label: item.statusCn, date: item.date });
            }
          });
          //  获取最近可选日期
          this.selected = data.find((item) => item.status === TicketStatus.HAVE)!.date;
        }
      });
    }

  }


  public getCurrentPickDay(date: Date) {
    // 日历选择与已选择的一致不做处理
    if (this.currentSelected && FormatUtil.dateAsISO(date) === FormatUtil.dateAsISO(this.currentSelected?.date)) {
      return;
    }
    this.currentSelected = this.dayList.find((item) => FormatUtil.dateAsISO(date) === FormatUtil.dateAsISO(item.date));
    if (!this.currentSelected && this.dayList) {
      this.currentSelected =
        this.dayTicketInfo.find((item) => FormatUtil.dateAsISO(date) === FormatUtil.dateAsISO(item.date));
      this.dayList.pop();
      this.dayList.push(this.currentSelected as TimeTicketInfo);
      this.selectedTime = '';
    }
  }

  public async getContactsList() {
    const res = await https.getContacts();
    if (res.code === 0) {
      this.contactList = res.data;
    }
  }

  public async getTicketType() {
    const params: Record<string, string> | undefined = RouterModule.getNavParam({ url: RouterMap.BUY_TICKET });
    if (params) {
      this.performanceName = params.performanceName;
      this.performanceId = params.performanceId;
      const res = await https.getTicketType(this.performanceId);
      if (res.code === 0) {
        this.selectTicketInfo = [];
        res.data.forEach((item) => {
          const obj: TicketTypeInfo =
            new TicketTypeInfo(item.ticketType, item.typeCn, item.count, item.notice, item.des, item.limit,
              item.price);
          this.selectTicketInfo.push(obj);
        });
      }
    }
  }


  public getTotalTicket() {
    this.totalTicket = this.selectTicketInfo.reduce((acc: number, item) => acc + item.count, 0);
    this.totalPrice = this.selectTicketInfo.reduce((acc: number, item) => acc + item.count * item.price, 0);
  }

  // 创建一个选参观人的数组
  public createTicketList() {
    this.ticketList = [];
    let sortId = 1;
    this.selectTicketInfo.forEach((item, index) => {
      if (item.count > 0) {
        for (let i = 0; i < item.count; i++) {
          const ticketItem: TicketListItem = {
            ticketType: item.ticketType,
            typeCn: item.typeCn,
            price: item.price,
            sortId,
          };
          this.ticketList.push(ticketItem);
          sortId++;
        }
      }
    });

    // 剔除已有参观人
    if (this.ticketOwner.length > 0) {
      this.ticketOwner.forEach((item: TicketOwner) => {
        const index = this.ticketList.findIndex((val) => val.sortId === item.sortId);
        this.ticketList.splice(index, 1);
      });
    }

  }

  // 绑定购票人信息

  public bindTicketOwner(item: Contacts) {
    const params: Record<string, number> | undefined = RouterModule.getNavParam({ url: RouterMap.TICKET_OWNER });
    if (params) {
      if (params.ticketIndex !== undefined) {
        const index = params.ticketIndex;
        const ticketItem: TicketListItem = this.ticketList[index];
        this.ticketList.splice(index, 1);
        const owner: TicketOwner =
          new TicketOwner(item.personID, item.name, ticketItem.ticketType, ticketItem.typeCn, 1, ticketItem.price,
            item.cardType, item.cardID, ticketItem.sortId);
        this.ticketOwner.push(owner);

      }
      if (params.ownerIndex !== undefined) {
        const index = params.ownerIndex;
        this.ticketOwner[index].personId = item.personID;
        this.ticketOwner[index].cardType = item.cardType;
        this.ticketOwner[index].name = item.name;
        this.ticketOwner[index].cardId = item.cardID;
      }
      RouterModule.pop();
    }
  }

  // 购票支付
  public async prepayBuyTicket() {
    if (!this.prepayBuyTicket) {
      return;
    }
    const ticketOwnerList: TicketOwnerRequest[] = [];
    this.ticketOwner.forEach((item) => {
      const obj: TicketOwnerRequest = {
        personId: item.personId,
        name: item.name,
        ticketType: item.ticketType,
        ticket: item.ticket,
        price: item.price,
      };
      ticketOwnerList.push(obj);
    });

    const data: PrepayBuyTicketRequest = {
      visitTime: FormatUtil.dateAsISO(this.currentSelected!.date) + ' ' + this.selectedTime,
      orderAmount: this.totalPrice,
      ticketOwner: ticketOwnerList,
      contactPhone: this.contactPhone,
      performanceName: this.performanceName,
      performanceId: this.performanceId,
    };
    const res = await https.prePayBuyTicket(data);
    if (res.code === 0) {
      this.orderNo = res.data.orderNo;
      paymentService
        .requestPayment(this.context, res.data.orderStr)
        .then(() => {
          Logger.info('succeeded in paying');
          RouterModule.push({ url: RouterMap.BUY_SUCCESS });
          emitter.emit('refreshCard');
        })
        .catch((error: BusinessError) => {
          promptAction.showToast({ message: '支付失败！' });
          const timer = setTimeout(() => {
            RouterModule.push({
              url: RouterMap.TICKET_DETAIL,
              param: {
                userId: AccountUtil.getUserInfo().id,
                orderNo: this.orderNo,
              },
            });
            clearTimeout(timer);
          }, 1000);

          Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        });
    }
  }

  // 获取成功信息

  public async getBuySuccessInfo() {
    const data: OrderDetailRequest = {
      orderNo: this.orderNo,
      userId: AccountUtil.getUserInfo().id,
    };
    const res = await https.getOrderDetail(data);
    if (res.code === 0) {
      this.orderDetail = res.data;
    }
  }
}