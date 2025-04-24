export class ActivityInfo {
  activityId: number = 0;
  name: string = '';
  subTitle: string = '';
  desc: string = '';
  city: string = '';
  address: string = '';
  fee: number = 0.0;
  activityStartTime: number = 0;
  activityEndTime: number = 0;
  activityUserNumber: number = 0;
  activityEnrolledCount: number = 0;
  resource0Url: string = '';
  resource1Url: string = '';
  resource2Url: string = '';
  resource3Url: string = '';
  descTitle: string = '';
  descDetail: string = '';

  constructor(activityId: number, name: string, subTitle: string, desc: string, city: string, address: string,
    fee: number, activityStartTime: number, activityEndTime: number, activityUserNumber: number,
    activityEnrolledCount: number, resource0Url: string, resource1Url: string, resource2Url: string,
    resource3Url: string, descTitle: string, descDetail: string) {
    this.activityId = activityId;
    this.name = name;
    this.subTitle = subTitle;
    this.desc = desc;
    this.city = city;
    this.address = address;
    this.fee = fee;
    this.activityStartTime = activityStartTime;
    this.activityEndTime = activityEndTime;
    this.activityUserNumber = activityUserNumber;
    this.activityEnrolledCount = activityEnrolledCount;
    this.resource0Url = resource0Url;
    this.resource1Url = resource1Url;
    this.resource2Url = resource2Url;
    this.resource3Url = resource3Url;
    this.descTitle = descTitle;
    this.descDetail = descDetail;
  }
}