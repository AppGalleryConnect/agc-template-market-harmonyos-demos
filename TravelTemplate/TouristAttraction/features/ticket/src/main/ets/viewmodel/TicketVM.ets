import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, CommonUtil, LazyDataSource, Logger, SystemUtil } from 'common';
import { CreateTicketOrderRequest, GetOrderDetailRequest, https, TouristRequest } from 'network';
import { TouristInfo, TouristList } from 'types';
import { mapperTicketList, mapTouristInfo } from '../mapper/Index';
import { TicketInfo, TicketType } from '../model/TicketInfo';

@ObservedV2
export class TicketVM {
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace initDates: Date[] = [];
  @Trace selectedIndex: number = 0;
  @Trace selectedDate: Date = new Date();
  @Trace touristList: TouristList = [];
  @Trace selectedTourists: TouristInfo[] = [];
  @Trace selectedTouristsId: string[] = [];
  @Trace selectTouristCount: number = 1;
  @Trace ticketList: LazyDataSource<TicketInfo> = new LazyDataSource();
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  public constructor() {
    this.getTicketList();
  }

  public static _instance: TicketVM;

  public static get instance() {
    if (!TicketVM._instance) {
      TicketVM._instance = new TicketVM();
    }
    return TicketVM._instance;
  }

  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

  getDate() {
    let date = new Date();
    this.initDates = CommonUtil.getInitDates(date.getFullYear(), date.getMonth(), date.getDate());
  }

  getSheetHeight(isInReserve: boolean) {
    if (isInReserve) {
      return this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 748 : 612;
    } else {
      return this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 748 : 560;
    }
  }

  getTourists() {
    https.getTouristList().then((res) => {
      if (res.code === 0) {
        this.touristList = mapTouristInfo(res.data);
      }
    });
  }

  editItemInfo(item: TouristInfo, isEdit: boolean, defaultSelect: boolean = false) {
    let params: TouristRequest = {
      id: isEdit ? item.id : SystemUtil.doRandBySync(2),
      name: item?.name,
      phone: item?.phone,
      cardType: item?.cardType,
      cardNo: item?.cardNo,
      isChecked: item?.isChecked,
    };

    if (isEdit) {
      https.modifyTourist(params).then((res) => {
        if (res.code === 0) {
          let index = this.touristList.findIndex((item) => item.id === params.id); // 更新游客信息
          this.touristList[index].name = params.name;
          this.touristList[index].phone = params.phone;
          this.touristList[index].cardType = params.cardType;
          this.touristList[index].cardNo = params.cardNo;
          this.touristList[index].isChecked = params.isChecked;
          if (defaultSelect) {
            this.setSelectedTourist();
          }
        }
      });
    } else {
      https.createTourist(params).then((res) => {
        if (res.code === 0) {
          item.id = params.id;
          this.touristList.push(item);
          if (defaultSelect) {
            this.changeSelectedStatus(true, item.id);
            this.setSelectedTourist();
          }
        }
      });
    }
  }

  getTouristIds() {
    let touristIds: string[] = [];
    this.selectedTourists.forEach(item => {
      touristIds.push(item.id);
    });
    return touristIds;
  }

  validate(uiContext: UIContext) {
    if (this.selectedTourists.length === 0) {
      uiContext.getPromptAction().showToast({ message: '请选择游客信息', duration: 1000 });
      return false;
    }
    if (!CommonUtil.verifyPhoneNo(this.selectedTourists[0].phone)) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客手机号码', duration: 1000 });
      return false;
    } else if (this.selectedTourists.some((item) => !CommonUtil.verifyCardNo(item.cardNo))) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客身份证号', duration: 1000 });
      return false;
    } else if (this.selectedTourists.some((item) => (!item.name.length || !item.cardNo.length)) ||
      (!this.selectedTourists[0].name.length || !this.selectedTourists[0].cardNo.length)) {
      uiContext.getPromptAction().showToast({ message: '请填写完整游客信息', duration: 1000 });
      return false;
    } else if (this.selectedTourists.length < this.selectTouristCount) {
      let needCount = this.selectTouristCount - this.selectedTourists.length;
      uiContext.getPromptAction().showToast({ message: '还需选择/填写 ' + needCount + ' 人', duration: 1000 });
      return false;
    }
    return true;
  }

  createOrder(ticketType: TicketType | null) {
    let ticketRequest: CreateTicketOrderRequest = {
      orderNo: SystemUtil.doRandBySync(6),
      orderTime: CommonUtil.getFormatTime(new Date()),
      orderStatus: 1,
      couponId: 0,
      count: this.selectTouristCount,
      touristId: this.getTouristIds(), // 首个游客id
      contactId: this.selectedTourists[0].id,
      productName: ticketType?.ticketTypeName ?? '',
      productPrice: ticketType?.originalPrice ?? 0,
      startTime: CommonUtil.getFormatDate(this.selectedDate),
      endTime: CommonUtil.getValidEndTime(this.selectedDate),
    };
    this.selectedTourists.forEach((item) => {
      let params: TouristRequest = {
        id: item.id,
        name: item.name,
        phone: item.phone,
        cardType: item.cardType,
        cardNo: item.cardNo,
        isChecked: item.isChecked,
      };
      https.createTourist(params).then((res) => {
        if (res.code === 0) {
          Logger.info('create tourist success');
        }
      });
    });
    https.createTicketOrder(ticketRequest).then((res) => {
      if (res.code === 0) {
        this.pathStack.pushPathByName('TicketOrderDetail', {
          category: 0, orderNo: ticketRequest.orderNo,
        } as GetOrderDetailRequest);
      }
    });
  }

  getTicketList() {
    https.getTicketList().then((res) => {
      this.ticketList.pushArrayData(mapperTicketList(res.data));
    });
  }

  getAmount(price: number) {
    return price * this.selectTouristCount;
  }

  changeTourist(value: number) {
    if (this.selectedTourists.length > value) {
      this.selectedTourists.pop();
      const id = this.selectedTouristsId[this.selectedTouristsId.length - 1];
      this.touristList = this.touristList.map((tourist) => {
        if (tourist.id === id) {
          tourist.isChecked = false;
        }
        return tourist;
      });
      this.selectedTouristsId.pop();
    }
    this.selectTouristCount = value;
  }

  async getWindowSizeChange(context: Context) {
    try {
      let windowClass = await window.getLastWindow(context);
      windowClass.on('windowSizeChange', (data) => {
        Logger.info('Succeeded in enabling the listener for window size changes. Data: ' + JSON.stringify(data));
        this.getDate();
        this.changeSelectedByWindow();
      });
    } catch (exception) {
      Logger.error(
        `Failed to enable the listener for window size changes. Cause code: ${exception.code}, message: ${exception.message}`);
    }
  }

  changeSelectedByWindow() {
    const startDate = new Date(this.initDates[0]);
    const endDate = new Date(this.selectedDate);
    const timeDifference = endDate.getTime() - startDate.getTime();
    const dayDifference = timeDifference / (1000 * 3600 * 24);
    if (CommonUtil.isDisplayModeFull()) {
      if (2 < dayDifference && dayDifference <= 6) {
        this.selectedIndex = dayDifference;
      }
      if (dayDifference > 6) {
        this.initDates[6] = this.selectedDate;
        this.selectedIndex = 6;
      }
    }
    if (!CommonUtil.isDisplayModeFull() && dayDifference > 2) {
      this.initDates[2] = this.selectedDate;
      this.selectedIndex = 2;
    }
  }

  changeSelectedStatus(isChecked: boolean, touristId: string): void {
    if (isChecked) {
      if (this.selectedTouristsId.length >= this.selectTouristCount) {
        this.touristList = this.touristList.map((tourist) => {
          if (tourist.id === touristId) {
            tourist.isChecked = false;
          }
          return tourist;
        });
        promptAction.showToast({ message: '仅需' + this.selectTouristCount + '位游客，当前已选满', duration: 1000 });
        return;
      }
      this.selectedTouristsId.push(touristId);
    } else {
      const index = this.selectedTouristsId.findIndex((id) => id === touristId);
      if (index !== -1) {
        this.selectedTouristsId.splice(index, 1);
      }
    }

    this.touristList = this.touristList.map((tourist) => {
      if (tourist.id === touristId) {
        tourist.isChecked = isChecked;
      }
      return tourist;
    });
  }

  setSelectedTourist(): void {
    let tourists = this.touristList.filter(item => item.isChecked);
    for (let i = 0; i < tourists.length; i++) {
      if (!this.selectedTourists[i]) {
        this.selectedTourists[i] = new TouristInfo();
      }
      this.selectedTourists[i].id = tourists[i].id;
      this.selectedTourists[i].name = tourists[i].name;
      this.selectedTourists[i].phone = tourists[i].phone;
      this.selectedTourists[i].cardType = tourists[i].cardType;
      this.selectedTourists[i].cardNo = tourists[i].cardNo;
      this.selectedTourists[i].isChecked = tourists[i].isChecked;
    }
  }

  clearSelected(tourist: TouristInfo) { // 同时从 selectedTouristsId 中移除
    this.selectedTourists = this.selectedTourists.filter(item => item.id !== tourist.id);
    this.selectedTouristsId = this.selectedTouristsId.filter(item => item !== tourist.id); // 同步清除游客列表中的选中状态
    this.touristList = this.touristList.map((item) => {
      if (item.id === tourist.id) {
        item.isChecked = false;
      }
      return item;
    });
  }

  deleteItemInfo(id: string) {
    https.deleteTourist(id).then((res) => {
      if (res.code === 0) {
        this.touristList = this.touristList.filter(item => item.id !== id);
        this.selectedTourists = this.selectedTourists.filter(item => item.id !== id);
        this.selectedTouristsId = this.selectedTouristsId.filter(item => item !== id);
      }
    });
  }
}