export class ActivityBriefInfo {
  activityId: number = 0;
  name: string = '';
  desc: string = '';
  resource0Url: string = '';
  activityStartTime: number;
  activityEndTime: number;


  constructor(activityId: number, name: string, desc: string, resource0Url: string, activityStartTime: number,
    activityEndTime: number) {
    this.activityId = activityId;
    this.name = name;
    this.desc = desc;
    this.resource0Url = resource0Url;
    this.activityStartTime = activityStartTime;
    this.activityEndTime = activityEndTime;
  }

}