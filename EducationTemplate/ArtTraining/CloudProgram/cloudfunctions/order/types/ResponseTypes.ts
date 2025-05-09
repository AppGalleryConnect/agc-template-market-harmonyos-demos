export interface OrderInfoResp {
  orderTime: string;
  expireTime: string;
  orderStatus: number;
  orderNo: string;
  paymentMethod: number;
  totalPrice: number;
  orderStr: string;
  student: string;
  phone: string;
  courseInfo: CourseInfoResp;
}

export interface CourseInfoResp {
  courseId: number;
  type: number;
  name: string;
  summary: string;
  detail: string;
  mainDiagram: string;
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
