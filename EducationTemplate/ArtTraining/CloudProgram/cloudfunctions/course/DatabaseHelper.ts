import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { CourseInfo } from './models/CourseInfo';
import { UserCourseInfo } from './models/UserCourseInfo';
import { GetCourseListReq, GetCourseDetailReq, GetCourseListOrderedReq } from './types/RequestTypes';
import { CourseInfoResp } from './types/ResponseTypes';
import { ListResp } from './models/ListResp';
import { CourseTriggerMap, BANNERS, STORE_INFO } from './constants';

const ZONE_NAME = 'ArtTraining';
const TAG = '[course-db]';

export class DatabaseHelper {
  logger;
  private userId: string;
  courseList: CloudDBCollection<CourseInfo>;
  userCourseList: CloudDBCollection<UserCourseInfo>;

  constructor(logger, userId) {
    this.logger = logger;
    this.userId = userId;
    this.courseList = cloud.database({ zoneName: ZONE_NAME }).collection(CourseInfo);
    this.userCourseList = cloud.database({ zoneName: ZONE_NAME }).collection(UserCourseInfo);
  }

  public async getStoreConfig() {
    const LOGGER_TAG = TAG + CourseTriggerMap.GET_STORE_CONFIG;
    try {
      const initList = await this.courseList.query();
      const listResp = await this._createCourseInfoRespList(initList);
      const result = {
        banners: BANNERS,
        storeInfo: STORE_INFO,
        courseList: listResp.courseList ?? [],
      };
      return result;
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
    }
  }

  public async getCourseList(params: GetCourseListReq) {
    const LOGGER_TAG = TAG + CourseTriggerMap.GET_COURSE_LIST;
    const type = params.type;
    const keyword = params.keyword;
    try {
      let courseQuery: CloudDBZoneQuery<UserCourseInfo> = this.userCourseList
        .query()
        .orderByAsc('courseId')
        .equalTo('userId', this.userId);
      let userData = await courseQuery.get();
      if (!userData.length) {
        await this._createUserCourseInfoList();
        courseQuery = this.userCourseList.query().orderByAsc('courseId').equalTo('userId', this.userId);
      }
      if (keyword) {
        courseQuery.contains('name', keyword);
      }
      if (typeof type === 'number' && type !== 0) {
        courseQuery.equalTo('type', type);
      }
      const listResp = this._createCourseInfoRespList(courseQuery);
      return listResp;
    } catch (error) {
      this.logger.error(LOGGER_TAG + ` error: ${error}`);
    }
  }

  public async getCourseInfoDetail(params: GetCourseDetailReq) {
    const LOGGER_TAG = TAG + CourseTriggerMap.GET_COURSE_DETAIL;
    const courseId = params.courseId;
    try {
      const courseQuery: CloudDBZoneQuery<UserCourseInfo> = this.userCourseList
        .query()
        .orderByAsc('courseId')
        .equalTo('userId', this.userId)
        .equalTo('courseId', courseId);
      const courseData = await courseQuery.get();
      if (courseData?.length) {
        const res = this._createCourseInfoRespItem(courseData[0]);
        return res;
      } else {
        this.logger.error(LOGGER_TAG + ` cannot find activity`);
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
    }
  }

  public async getCourseInfoListOrdered(params: GetCourseListOrderedReq) {
    const courseStatus = params.courseStatus;
    const LOGGER_TAG = TAG + CourseTriggerMap.GET_COURSE_LIST_ORDERED;
    try {
      let courseQuery: CloudDBZoneQuery<UserCourseInfo> = this.userCourseList
        .query()
        .equalTo('userId', this.userId)
        .notEqualTo('orderTime', '');
      if (typeof courseStatus === 'number' && courseStatus !== 0) {
        courseQuery.equalTo('status', courseStatus);
      }
      const listResp = this._createCourseInfoRespList(courseQuery);
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  private async _createCourseInfoRespList(query: CloudDBZoneQuery<UserCourseInfo> | CloudDBZoneQuery<CourseInfo>) {
    const LOGGER_TAG = TAG + 'create activity resp list';
    try {
      const userData = await query.get();
      const totalCount: number = await query.countQuery('courseId');
      const listResp: ListResp<CourseInfoResp> = new ListResp<CourseInfoResp>(0, 0, []);
      if (!userData.length) {
        return listResp;
      }
      userData.forEach((item: UserCourseInfo) => {
        const activityResp: CourseInfoResp = this._createCourseInfoRespItem(item);
        listResp.courseList.push(activityResp);
      });
      listResp.totalCount = totalCount;
      listResp.returnCount = totalCount;
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  private _createCourseInfoRespItem(item: UserCourseInfo | CourseInfo): CourseInfoResp {
    const res: CourseInfoResp = {
      courseId: item.getCourseId(),
      type: item.getType(),
      name: item.getName(),
      summary: item.getSummary(),
      detail: item.getDetail(),
      mainDiagram: item.getMainDiagram(),
      price: item.getPrice(),
      expireType: item.getExpireType(),
      startTime: item.getStartTime(),
      endTime: item.getEndTime(),
      orderTime: item.getOrderTime(),
      classHour: item.getClassHour(),
      status: item.getStatus(),
      currentHour: item.getCurrentHour(),
      timetable: JSON.parse(item.getTimetable() ?? '{}'),
    };
    return res;
  }

  private async _createUserCourseInfoList() {
    try {
      const initCourseInfoList = await this.courseList.query().get();
      const upsertData: UserCourseInfo[] = [];
      if (initCourseInfoList.length) {
        initCourseInfoList.forEach((course: CourseInfo) => {
          const userCourseItem = new UserCourseInfo();
          userCourseItem.setId(course.courseId + this.userId);
          userCourseItem.setUserId(this.userId);
          userCourseItem.setCourseId(course.courseId);
          userCourseItem.setType(course.type);
          userCourseItem.setName(course.name);
          userCourseItem.setSummary(course.summary);
          userCourseItem.setDetail(course.detail);
          userCourseItem.setMainDiagram(course.mainDiagram);
          userCourseItem.setPrice(course.price);
          userCourseItem.setExpireType(course.expireType);
          userCourseItem.setStartTime(course.startTime);
          userCourseItem.setEndTime(course.endTime);
          userCourseItem.setOrderTime(course.orderTime);
          userCourseItem.setClassHour(course.classHour);
          userCourseItem.setStatus(course.status);
          userCourseItem.setCurrentHour(course.currentHour);
          userCourseItem.setTimetable(course.timetable);
          upsertData.push(userCourseItem);
        });
        const res = await this.userCourseList.upsert(upsertData);
        this.logger.info(TAG, `init user course list success,list length is ${res}`);
      }
    } catch (err) {
      this.logger.error(TAG + `init user course list failed. errpr: ${err}`);
    }
  }
}
