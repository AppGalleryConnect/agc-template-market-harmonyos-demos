import { ScheduleConfigUtil } from 'commonlib';
import { ResponseStatusCode } from '../constants/NetworkEnums';
import { QueryDayCourseReq } from '../models/request/QueryDayCourseReq';
import { ClassSignInResp, SignCodeState } from '../models/response/ClassSignInResp';
import { CourseScheduleConfigResp } from '../models/response/CourseScheduleConfigResp';
import { GetUserInfoResp } from '../models/response/GetUserInfoResp';
import { QueryAllCourseResp } from '../models/response/QueryAllCourseResp';
import { QueryDayCourseResp, SimpleCourseInfo } from '../models/response/QueryDayCourseResp';
import { BaseResponse } from '../types/ResponseTypes';


class HttpApiMock {
  private static _userNickName: string = '华为用户';

  private static _courseScheduleConfigMock: CourseScheduleConfigResp = {
    courseTimeRangeList: [
      '8:05-8:50',
      '8:55-9:40',
      '10:00-10:45',
      '10:50-11:35',
      '11:40-12:25',
      '13:30-14:15',
      '14:20-15:05',
      '15:15-16:00',
      '16:05-16:50',
    ],
    totalWeekNum: 16,
    divideTime: 5,
  };

  private static _todayCourseMock: QueryDayCourseResp = {
    courseList: [],
  };

  private static _tomorrowCourseMock: QueryDayCourseResp = {
    courseList: [],
  };

  private static _emptyCourseMock: QueryDayCourseResp = {
    courseList: [],
  };

  private static _allCourseMock: QueryAllCourseResp = {
    studentNo: '19011306',
    semester: 4,
    courseList: [
      {
        courseName: '视觉设计作品赏析',
        classroom: 'XXX D2-307',
        teacher: '索*',
        weekDay: 1,
        daySchedule: [
          1, 2,
        ],
        weekSchedule: [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        ],
        scheduleFlag: 'NORMAL',
      },
      {
        courseName: '数据库设计',
        classroom: 'XXX D3-405',
        teacher: '陈*',
        weekDay: 1,
        daySchedule: [
          6, 8,
        ],
        weekSchedule: [
          2, 4, 6, 8, 10, 12, 14, 16,
        ],
        scheduleFlag: 'EVEN_WEEK ',
      },
      {
        courseName: '编译原理',
        classroom: 'XXX D9-999',
        teacher: '单*',
        weekDay: 2,
        daySchedule: [
          3, 5,
        ],
        weekSchedule: [
          1, 2, 3, 4, 5, 6, 7, 8,
        ],
        scheduleFlag: 'NORMAL',
      },
      {
        courseName: '计算机导论',
        classroom: 'XXX D6-101',
        teacher: '于*',
        weekDay: 2,
        daySchedule: [
          8, 9,
        ],
        weekSchedule: [
          9, 10, 11, 12, 13, 14, 15, 16,
        ],
        scheduleFlag: 'NORMAL',
      },
      {
        courseName: '离散数学',
        classroom: 'XXX D7-201',
        teacher: '刘*',
        weekDay: 3,
        daySchedule: [
          2, 4,
        ],
        weekSchedule: [
          1, 3, 5, 7, 9, 11, 13, 15,
        ],
        scheduleFlag: 'ODD_WEEK',
      },
      {
        courseName: '鸿蒙布道',
        classroom: 'XXX D7-201',
        teacher: '刘*',
        weekDay: 3,
        daySchedule: [
          7, 8,
        ],
        weekSchedule: [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        ],
        scheduleFlag: 'NORMAL',
      },
      {
        courseName: '创新实践',
        classroom: 'XXX D7-201',
        teacher: '赵*',
        weekDay: 4,
        daySchedule: [
          3, 4,
        ],
        weekSchedule: [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        ],
        scheduleFlag: 'NORMAL',
      },
      {
        courseName: '大学生就业指导',
        classroom: 'XXX D7-201',
        teacher: '刘*',
        weekDay: 5,
        daySchedule: [
          1, 5,
        ],
        weekSchedule: [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        ],
        scheduleFlag: 'NORMAL',
      },
    ],
  };

  public getScheduleConfig(): Promise<BaseResponse<CourseScheduleConfigResp>> {
    const resp: BaseResponse<CourseScheduleConfigResp> = {
      code: ResponseStatusCode.SUCCESS,
      data: HttpApiMock._courseScheduleConfigMock,
    };
    return Promise.resolve(resp);
  }

  public queryDayCourse(req: QueryDayCourseReq): Promise<BaseResponse<QueryDayCourseResp>> {
    const date = new Date(req.dateTime);

    let allSimpleCourseList = HttpApiMock._allCourseMock.courseList
      .map(totalCourseInfo => {
        const simpleCourseInfo: SimpleCourseInfo = {
          courseName: totalCourseInfo.courseName,
          classroom: totalCourseInfo.classroom,
          teacher: totalCourseInfo.teacher,
          weekDay: totalCourseInfo.weekDay,
          daySchedule: totalCourseInfo.daySchedule,
          weekSchedule: totalCourseInfo.weekSchedule,
        };
        return simpleCourseInfo;
      });

    const today = new Date();
    const todayWeek = ScheduleConfigUtil.getCurrentWeek(today);
    const todayWeekDay = today.getDay() === 0 ? 7 : today.getDay();
    HttpApiMock._todayCourseMock.courseList = allSimpleCourseList
      .filter(simpleCourse => simpleCourse.weekDay === todayWeekDay &&
        simpleCourse.weekSchedule.some(week => week === todayWeek));

    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    const tomorrowWeek = ScheduleConfigUtil.getCurrentWeek(tomorrow);
    const tomorrowWeekDay = tomorrow.getDay() === 0 ? 7 : tomorrow.getDay();
    HttpApiMock._tomorrowCourseMock.courseList = allSimpleCourseList
      .filter(simpleCourse => simpleCourse.weekDay === tomorrowWeekDay &&
        simpleCourse.weekSchedule.some(week => week === tomorrowWeek));

    const resp: BaseResponse<QueryDayCourseResp> = {
      code: ResponseStatusCode.SUCCESS,
      data: today.getDate() === date.getDate() ? HttpApiMock._todayCourseMock : HttpApiMock._tomorrowCourseMock,
    };
    return Promise.resolve(resp);
  }

  public queryAllCourse(): Promise<BaseResponse<QueryAllCourseResp>> {
    const resp: BaseResponse<QueryAllCourseResp> = {
      code: ResponseStatusCode.SUCCESS,
      data: HttpApiMock._allCourseMock,
    };
    return Promise.resolve(resp);
  }

  public async signIn(): Promise<BaseResponse<ClassSignInResp>> {
    const now = new Date();
    const todayCourses = HttpApiMock._todayCourseMock.courseList;
    const courseTimeRanges = todayCourses.map(courseInfo => {
      return ScheduleConfigUtil.getDayScheduleDate(courseInfo.daySchedule, now);
    });
    let inTimeCourse: SimpleCourseInfo | undefined = undefined;
    for (let i = 0; i < todayCourses.length; i++) {
      const courseStartTime = courseTimeRanges[i].first;
      const courseEndTime = courseTimeRanges[i].second;
      if (now.getTime() < courseEndTime.getTime() && now.getTime() > courseStartTime.getTime()) {
        inTimeCourse = todayCourses[i];
        break;
      }
    }
    const data: ClassSignInResp = {
      signState: SignCodeState.INVALID_CODE,
      courseName: '',
    };
    if (inTimeCourse) {
      data.signState = SignCodeState.SUCCESS;
      data.courseName = inTimeCourse.courseName;
    }
    const resp: BaseResponse<ClassSignInResp> = { code: 0, data: data };
    return Promise.resolve(resp);
  }

  public bindPhone(): Promise<BaseResponse<undefined>> {
    const resp: BaseResponse = { code: 0, data: undefined };
    return Promise.resolve(resp);
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    const resp: BaseResponse<GetUserInfoResp> = {
      code: 0,
      data: {
        avatar: 'ic_user_avatar',
        nickname: HttpApiMock._userNickName,
        phone: '10011111111',
      },
    };
    return Promise.resolve(resp);
  }

  public updateUserNickname(request: Record<string, string>): Promise<BaseResponse<string>> {
    const resp: BaseResponse<string> = { code: 0, data: 'SUCCESS' };
    HttpApiMock._userNickName = request.nickname;
    return Promise.resolve(resp);
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
