import { TicketStatus, DayTicketInfo, DateItem, TimeStatus, Contacts } from '../types/Index';
import { FormatUtil, RouterModule, RouterMap } from 'commonlib';
import { GetOrderDetailResp, https, OrderFreeRequest, OrderVisitor } from 'network';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

const TAG = '[OrderTicketVM]';

@ObservedV2
export class OrderTicketVM {
  // 联系人列表
  @Trace contactList: Contacts[] = [];
  @Trace currentIndex: number = 0;
  @Trace currentHourIndex: number = -1;
  @Trace dayTicketInfo: DayTicketInfo[] = [];
  // 允许选择的时间范围
  @Trace ableData: DateItem[] = [];
  // 禁止选择的时间
  @Trace disableData: DateItem[] = [];
  @Trace dayList: DayTicketInfo[] = [];
  // 日历选择的日期
  @Trace selected: Date = new Date();
  // 当前预约的日期
  @Trace currentSelected: DayTicketInfo | undefined = undefined;
  // 当前选择的时间段
  @Trace selectedTime: TimeStatus | undefined = undefined;
  // 当前选择的参观人
  @Trace selectContacts: Contacts[] = [];
  // 确认的参观人
  @Trace confirmContacts: Contacts[] = [];
  // 联系电话
  @Trace contactPhone: string = '';
  // 预约成功后的返回信息
  @Trace orderSuccessDetail: GetOrderDetailResp | undefined = undefined;
  // 是否显示警告
  @Trace isWarning: boolean = false;
  // 当前将要删除参观人的index
  @Trace delIndex: number = 0;
  // 时间段映射
  timeMap: Map<TimeStatus, string> = new Map([[TimeStatus.MORNING, '上午'], [TimeStatus.AFTERNOON, '下午']]);
  private static _instance: OrderTicketVM;

  public static get instance() {
    if (!OrderTicketVM._instance) {
      OrderTicketVM._instance = new OrderTicketVM();
    }
    return OrderTicketVM._instance;
  }

  public initData() {
    this.currentSelected = undefined;
    this.selectedTime = undefined;
  }

  public clearOrderInfo() {
    this.contactPhone = '';
    this.confirmContacts = [];
  }

  public addContacts(contact: Contacts) {
    this.selectContacts.push(contact);
  }

  public delContacts() {
    this.confirmContacts.splice(this.delIndex, 1);
  }

  public removeContacts(contact: Contacts) {
    const index: number = this.selectContacts.findIndex((item: Contacts) => item.personID === contact.personID);
    this.selectContacts.splice(index, 1);
  }

  public async getDayTicketInfo() {
    https.getDayTicket().then(res => {
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
      this.dayList.push(this.currentSelected as DayTicketInfo);
      this.selectedTime = undefined;
    }
  }

  public async getContactsList() {
    const res = await https.getContacts();
    if (res.code === 0) {
      this.contactList = res.data;
    }
  }

  public async submitOrderInfo() {
    const visitors = this.confirmContacts.map((item) => {
      const visitor: OrderVisitor = {
        personId: item.personID,
        name: item.name,
      };
      return visitor;
    });

    const data: OrderFreeRequest = {
      orderTime: FormatUtil.formatFullDate(new Date()),
      visitTime: FormatUtil.dateAsISO(this.currentSelected!.date) + ' ' + this.timeMap.get(this.selectedTime!),
      visitor: this.confirmContacts.length,
      visitors: visitors,
      contactPhone: this.contactPhone,
    };
    const res = await https.orderFree(data);
    if (res.code === 0) {
      promptAction.showToast({ message: '预约成功！' });
      // 刷新卡片
      emitter.emit('refreshCard')
      this.orderSuccessDetail = res.data;
      setTimeout(() => {
        RouterModule.push({ url: RouterMap.ORDER_SUCCESS });
      }, 1000);
    }

  }
}