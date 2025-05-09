export interface UserInfo {
  avatar: string;
  nickname: string;
  phone: string;
  studentID: string;
  wechat: string;
  birthday: string;
}

export interface SwiperItem {
  image: ResourceStr;
  id: number;
}

export interface CourseAdvantageItem {
  icon: ResourceStr;
  label: string;
}

export interface StoreInfo {
  shopName: string;
  latitude: number;
  longitude: number;
  address: string;
  phoneNumber: string;
  email: string;
  logoUrl: ResourceStr;
  bannerImg: ResourceStr;
  desc: string;
  businessTime: string;
}

export interface CourseInfo {
  courseId: number;
  type: number;
  name: string;
  summary: string;
  detail: string;
  mainDiagram: ResourceStr;
  price: number;
  expireType: number;
  startTime: string;
  endTime: string;
  orderTime: string;
  classHour: number;
  status: number; // 1未上课 2在读中 3已结课
  currentHour: number; // 当前课时
  timetable: CourseTimetable;
}

export interface CourseTimetable {
  weekdays: number[]; // 课程安排在星期几,0为星期日
  startTime: string; // 开始时刻 hh:mm
  endTime: string; // 结束时刻 hh:mm
}

export interface OrderInfo {
  orderTime: string;
  expireTime: string;
  orderStatus: number;
  orderNo: string;
  paymentMethod: number;
  totalPrice: number;
  orderStr?: string;
  student: string;
  phone: string;
  courseInfo: CourseInfo;
}

export interface TaskRequirement {
  textSwitch: number;
  textMinLimit: number;
  audioSwitch: number;
  audioMinLimit: number;
  videoSwitch: number;
  videoMinLimit: number;
  pictureSwitch: number;
  pictureMinLimit: number;
}

export interface CheckInActivity {
  activityId: number;
  name: string;
  summary: string;
  detail: string;
  mainDiagram: ResourceStr;
  price: number;
  orderTime: string;
  requirement: TaskRequirement;
  participationCount: number;
  historyCount: number;
  taskDirectory: CheckInTaskItem[];
}

export interface CheckInTaskItem {
  taskName: string; // 打卡任务名称
  taskId: number;
  taskDetail: string; // 打卡任务描述
  taskStatus: number; // 1未打卡 2已打卡
}

export interface CheckInRecord {
  taskId: number;
  activityId: number;
  textDetail?: string;
  pictureDetail?: ResourceStr[];
  audioDetail?: ResourceStr[];
  videoDetail?: ResourceStr[];
  createTime: string;
}

export interface StoreConfig {
  banners?: ResourceStr[];
  storeInfo?: StoreInfo;
  courseList?: CourseInfo[];
}

export interface OrderSubmittedRouteParam {
  orderNo: string;
  paymentMethod: number;
  orderStatus: number;
}

export interface ConfirmDialogOption {
  title: string;
  message: string;
}
