import {
  CalendarUtil,
  CourseInfo,
  CourseStatusMap,
  DialogInfo,
  DialogMap,
  FormatUtil,
  RouterModule,
} from 'commonlib';
import { ConfirmParam } from 'componentlib';
import { https } from 'network';
import { TimetableCourse } from '../types/Index';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { CourseInCalendar, DateBarItemModel } from '../models/Index';
import { WEEKDAY_MAP } from '../constants/Constants';


@ObservedV2
export class TimetableVM {
  @Trace courseList: CourseInfo[] = [];
  @Trace selectDayCourses: TimetableCourse[] = [];
  @Trace dateList: DateBarItemModel[] = [];
  @Trace isLoading: boolean = false;
  @Trace currentIndex: number = 0;
  @Trace today: Date = new Date();
  @Trace courseInCalendar: CourseInCalendar = PersistenceV2.connect(CourseInCalendar, () => new CourseInCalendar())!;
  private static _instance: TimetableVM;

  public static get instance() {
    if (!TimetableVM._instance) {
      TimetableVM._instance = new TimetableVM();
    }
    return TimetableVM._instance;
  }

  @Computed
  public get showAddButton() {
    const todayIndex = this.today.getDay();
    return this.currentIndex >= todayIndex;
  }

  public async initTimetable() {
    this.today = new Date();
    this._getCurrentWeekDates();
    this._initCourseInCalendar();
    await this._getUserCourseListOrdered();
    this.getTimetable(this.currentIndex);
  }

  private _initCourseInCalendar() {
    const curWeek = FormatUtil.getWeekOfYear(this.today);
    if (curWeek > this.courseInCalendar.curWeek) {
      this.courseInCalendar.curWeek = curWeek;
      this.courseInCalendar.list = [];
    }
  }

  private async _getUserCourseListOrdered() {
    this.isLoading = true;
    const res = await https.getCourseListOrdered({
      courseStatus: CourseStatusMap.IN_PROGRESS,
    });
    if (res.ret.code === 0) {
      this.courseList = res.result.courseList;
      this.courseList.forEach((item) => {
        const classDays = item.timetable.weekdays;
        classDays.forEach((day) => {
          if (this.dateList[day]) {
            this.dateList[day].hasClass = true;
          }
        });
      });
    }
    this.isLoading = false;
  }

  public async getTimetable(index = 0) {
    this.currentIndex = index;

    this.selectDayCourses = this.courseList.filter((item) =>
    item.timetable?.weekdays?.includes(index))
      .map((item: TimetableCourse) => {
        if (this.courseInCalendar.list.includes(this._getCalendarDate(item).getTime())) {
          item.isAddCalendar = true;
        }
        return item;
      });
    if (this.selectDayCourses.length) {
      this.selectDayCourses.sort((a, b) => {
        if (a < b) {
          return -1;
        }
        if (a > b) {
          return 1;
        }
        return 0;
      });
    }

  }

  public getCurrentMonthLabel() {
    const year = this.today.getFullYear();
    const month = this.today.getMonth() + 1;
    return `${year}年${month}月`;
  }

  private _getCurrentWeekDates() {
    this.dateList = [];
    const dayOfWeek = this.today.getDay();
    this.currentIndex = dayOfWeek;
    const startOfWeek = new Date(this.today);
    startOfWeek.setDate(this.today.getDate() - dayOfWeek);
    for (let i = 0; i < 7; i++) {
      const date = new Date(startOfWeek);
      date.setDate(startOfWeek.getDate() + i);
      const dayValue = WEEKDAY_MAP.get(i) as string;
      const formattedDate = FormatUtil.formatSimpleDate(date);
      const dateBarItem: DateBarItemModel = new DateBarItemModel(dayValue, formattedDate, false);
      this.dateList.push(dateBarItem);
    }
  }

  public async addCalendar(course: TimetableCourse) {
    if (course.isAddCalendar) {
      promptAction.showToast({ message: '暂不支持取消，请前往日历取消日程~' });
      return;
    }
    const date = this._getCalendarDate(course);
    const curTime = new Date();
    if (date.getTime() < curTime.getTime()) {
      promptAction.showToast({ message: '课程已结束，无法添加日程~' });
      return;
    }
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        title: '提示',
        message: '是否确认将课程添加至日历？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          const res = await CalendarUtil.addEvent(course.name, date);
          if (res) {
            promptAction.showToast({ message: '日程添加成功！记得按时上课~' });
            this.courseInCalendar.list.push(date.getTime());
            await this._getUserCourseListOrdered();
            this.getTimetable(this.currentIndex);
          }
        }
      },
    });
  }

  private _getCalendarDate(course: CourseInfo) {
    const currentYear = this.today.getFullYear();
    const courseDate = this.dateList[this.currentIndex].date;
    const courseTime = course.timetable.startTime;

    const month = Number(courseDate.split('.')[0]);
    const day = Number(courseDate.split('.')[1]);
    const hours = Number(courseTime.split(':')[0]);
    const minutes = Number(courseTime.split(':')[1]);

    const date = new Date(currentYear, month - 1, day, hours, minutes);
    return date;
  }
}