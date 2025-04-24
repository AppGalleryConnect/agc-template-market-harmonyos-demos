@ObservedV2
export class StoreBookingRecordItem {
  id: number;
  userName: string;
  telephoneNum: string;
  storeName: ResourceStr;
  date: string;
  project: number;
  @Trace status: number;
  address: string;
  @Trace alreadyAddedToEvent: boolean; // 新增字段，表示是否已添加到日历中

  constructor(id: number, userName: string, telephoneNum: string, storeName: ResourceStr, date: string, project: number,
    status: number, address: string, alreadyAddedToEvent: boolean) {
    this.id = id;
    this.userName = userName;
    this.telephoneNum = telephoneNum;
    this.storeName = storeName;
    this.date = date;
    this.project = project;
    this.status = status;
    this.address = address;
    this.alreadyAddedToEvent = alreadyAddedToEvent;
  }
}