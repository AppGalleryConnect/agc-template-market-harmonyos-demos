import {
  BookingInfo,
  BookingRecordInfo,
  CourseBookingInfo,
  CourseDetailModel,
  DateUtil,
} from 'external_interactions';
import { WidgetSmallCard } from './WidgetSmallCard';
import { WidgetMidCard } from './WidgetMidCard';

let storageUpdateByMsg = new LocalStorage();

@Entry(storageUpdateByMsg)
@Component
struct WidgetCard {
  @LocalStorageProp('formDimension') formDimension: number = 2;
  @LocalStorageProp('loginState') @Watch('getInfo') loginState: boolean = false;
  @LocalStorageProp('bookRecordList') @Watch('getInfo') bookRecordList: BookingRecordInfo[] = [];
  @LocalStorageProp('courseBookingList') @Watch('getInfo') courseBookingList: CourseBookingInfo[] = [];
  @LocalStorageProp('courseDetailList') @Watch('getInfo') courseDetailList: CourseDetailModel[] = [];
  courseBookingInfo?: CourseBookingInfo = undefined;
  courseDetailInfo?: CourseDetailModel = undefined;
  bookingRecordInfo: BookingRecordInfo = {} as BookingRecordInfo;
  @State buttonText: string = '立即预约';
  @State courseName: string = '';
  @State recordDate: string = '';
  @State recordTime: string = '';
  @State showImg: string = 'app.media.material1';
  @State hasRecord: boolean = false;

  getInfo() {
    if (this.bookRecordList.length === 0) {
      this.hasRecord = false
      this.showImg = 'app.media.material1'
      return
    }
    this.hasRecord = true
    const now = new Date()
    let minDiff = Infinity

    for (const record of this.bookRecordList) {
      const course = this.courseBookingList.find(c => c.id === record.courseBookingId)
      if (!course) {
        continue
      }
      const diff = DateUtil.parseDateString(record.bookingDate + ' ' + course.timeStart).getTime() - now.getTime()

      // 只考虑未来&最近的课程
      if (diff > 0 && diff < minDiff) {
        minDiff = diff
        this.courseBookingInfo = course
        this.bookingRecordInfo = record
        this.courseDetailInfo = this.courseDetailList.find(c => c.id === course.courseId)
        this.showImg = this.courseDetailInfo?.advImage || 'app.media.material11'
        this.courseName = this.courseDetailInfo?.courseName!;
        this.recordDate = this.courseBookingInfo?.date.replace(/-/g, '.');
        this.recordTime = this.courseBookingInfo?.timeStart;
      }
    }
  }

  build() {
    if (this.formDimension === 2) {
      WidgetSmallCard({
        courseName: this.courseName,
        recordTime: this.recordTime,
        showImg: this.showImg,
        hasRecord: this.hasRecord,
        bookingInfo: this.buildBookingInfo()
      })
    } else {
      WidgetMidCard({
        courseName: this.courseName,
        recordDate: this.recordDate,
        recordTime: this.recordTime,
        showImg: this.showImg,
        hasRecord: this.hasRecord,
        bookingInfo: this.buildBookingInfo()
      })
    }
  }

  buildBookingInfo(): BookingInfo {
    let bookingInfo: BookingInfo = {
      courseBookingInfo: this.courseBookingInfo!,
      courseDetail: this.courseDetailInfo!,
      phone: this.bookingRecordInfo.phone,
      name: this.bookingRecordInfo.name,
      personNum: this.bookingRecordInfo.personNum,
      remark: this.bookingRecordInfo.remark,
      bookState: this.bookingRecordInfo.bookState
    }
    return bookingInfo
  }
}