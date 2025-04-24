@ObservedV2
export class ActivityModel{
  // 活动id
  id: number | null;

  // 活动名称
  name: string | null;

  // 活动报名开始时间
  bookingStartTime: Date | null;

  // 活动报名截止时间
  bookingEndTime: Date | null;

  // 活动开始时间
  startTime: Date | null;

  // 活动截止时间
  endTime: Date | null;

  // 活动类型
  type: string | null;

  // 活动城市
  city: string | null;

  // 活动支持门店名
  supportStoreName: string | null;

  // 活动介绍
  desc: string| null;

  // 活动介绍图片链接
  picDescUrl: Resource| null;

  // 活动状态
  state: number| null;

  constructor(id: number|null, name: string|null, bookingStartTime: Date|null,
    bookingEndTime: Date|null, startTime: Date|null, endTime: Date|null,
    type: string|null, city: string|null, supportStoreName: string|null,
    desc: string|null, picDescUrl: Resource|null, state: number|null) {
    this.id = id;
    this.name = name;
    this.bookingStartTime = bookingStartTime;
    this.bookingEndTime = bookingEndTime;
    this.startTime = startTime;
    this.endTime = endTime;
    this.type = type;
    this.city = city;
    this.supportStoreName = supportStoreName;
    this.desc = desc;
    this.picDescUrl = picDescUrl;
    this.state = state;
  }

  static createEmptyActivity(): ActivityModel {
    return new ActivityModel(null, null, null, null, null, null, null, null, null, null, null, null)
  }
}