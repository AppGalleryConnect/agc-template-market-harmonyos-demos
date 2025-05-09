import { cloud, CloudDBCollection, CloudDBZoneObjectOperator, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { CheckInActivity } from './models/CheckInActivity';
import { UserCheckInActivity } from './models/UserCheckInActivity';
import { CheckInRecord } from './models/CheckInRecord';
import { ListResp } from './models/ListResp';
import {
  BaseReq,
  GetActivityDetailReq,
  CheckInActivityOrderReq,
  SubmitCheckInReq,
  GetUserCheckInRecordListReq,
} from './types/RequestTypes';
import { CheckInActivityResp, RecordResp, CheckInTaskItem } from './types/ResponseTypes';
import { CheckInTriggerMap } from './constants';

const ZONE_NAME = 'ArtTraining';
const TAG = '[check-in-activity-db]';

export class DatabaseHelper {
  private logger;
  private userId: string;
  private activityList: CloudDBCollection<CheckInActivity>;
  private userActivityList: CloudDBCollection<UserCheckInActivity>;
  private recordList: CloudDBCollection<CheckInRecord>;

  constructor(logger, userId) {
    this.logger = logger;
    this.userId = userId;
    this.activityList = cloud.database({ zoneName: ZONE_NAME }).collection(CheckInActivity);
    this.userActivityList = cloud.database({ zoneName: ZONE_NAME }).collection(UserCheckInActivity);
    this.recordList = cloud.database({ zoneName: ZONE_NAME }).collection(CheckInRecord);
  }

  public async getCheckInActivityList() {
    const LOGGER_TAG = TAG + CheckInTriggerMap.GET_CHECKIN_ACTIVITY_LIST;
    try {
      let activityQuery: CloudDBZoneQuery<UserCheckInActivity> = this.userActivityList
        .query()
        .orderByAsc('activityId')
        .equalTo('userId', this.userId);
      let userData = await activityQuery.get();
      if (!userData.length) {
        // 首次访问初始化用户数据
        await this._createUserCheckInActivityList(this.userId);
        activityQuery = this.userActivityList.query().orderByAsc('activityId').equalTo('userId', this.userId);
      }
      const listResp = this._createActivityRespList(activityQuery);
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async getCheckInActivityDetail(params: GetActivityDetailReq) {
    const LOGGER_TAG = TAG + CheckInTriggerMap.GET_CHECKIN_ACTIVITY_DETAIL;
    const activityId = params.activityId;
    try {
      const activityQuery: CloudDBZoneQuery<UserCheckInActivity> = this.userActivityList
        .query()
        .orderByAsc('activityId')
        .equalTo('userId', this.userId)
        .equalTo('activityId', activityId);
      const activityData = await activityQuery.get();
      if (activityData?.length) {
        const res = this._createActivityRespItem(activityData[0]);
        return res;
      } else {
        this.logger.error(LOGGER_TAG + ` cannot find activity`);
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
    }
  }

  public async createCheckInActivityOrder(params: CheckInActivityOrderReq) {
    const activityId = params.activityId;
    const LOGGER_TAG = TAG + CheckInTriggerMap.CREATE_CHECKIN_ACTIVITY_ORDER;
    try {
      const activityQuery: CloudDBZoneQuery<UserCheckInActivity> = this.userActivityList
        .query()
        .orderByAsc('activityId')
        .equalTo('userId', this.userId)
        .equalTo('activityId', activityId);
      const activityData = await activityQuery.get();
      if (activityData?.length === 1) {
        const activityResource = activityData[0];
        if (activityResource.orderTime && activityResource.status !== 0) {
          this.logger.error(TAG + 'activity has been ordered');
          return;
        }
        const orderTime = new Date().getTime().toString();
        const operator = CloudDBZoneObjectOperator.build(activityResource)
          .update('status', 1)
          .update('orderTime', orderTime);
        const res = await this.userActivityList.update(operator);
        this.logger.info(LOGGER_TAG + 'create activity order success');
        return res;
      } else {
        this.logger.error(LOGGER_TAG + `cannot find activity`);
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async cancelCheckInActivityOrder(params: CheckInActivityOrderReq) {
    const activityId = params.activityId;
    const LOGGER_TAG = TAG + CheckInTriggerMap.CANCEL_CHECKIN_ACTIVITY_ORDER;
    try {
      const activityQuery: CloudDBZoneQuery<UserCheckInActivity> = this.userActivityList
        .query()
        .orderByAsc('activityId')
        .equalTo('userId', this.userId)
        .equalTo('activityId', activityId);
      const activityData = await activityQuery.get();
      if (activityData?.length === 1) {
        const activityResource = activityData[0];
        if (!activityResource.orderTime && activityResource.status === 0) {
          this.logger.error(TAG + 'activity has been canceled');
          return;
        }
        const operator = CloudDBZoneObjectOperator.build(activityResource).update('status', 0).update('orderTime', '');
        const res = await this.userActivityList.update(operator);
        this.logger.info(LOGGER_TAG + 'cancel activity order success');
        return res;
      } else {
        this.logger.error(LOGGER_TAG + `cannot find activity`);
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async getActivityListOrdered() {
    const LOGGER_TAG = TAG + CheckInTriggerMap.GET_CHECKIN_ACTIVITY_LIST_ORDERED;
    try {
      let activityQuery: CloudDBZoneQuery<UserCheckInActivity> = this.userActivityList
        .query()
        .equalTo('userId', this.userId)
        .notEqualTo('orderTime', '');
      const listResp = this._createActivityRespList(activityQuery);
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async commitUserCheckIn(params: SubmitCheckInReq) {
    const activityId = params.activityId;
    const taskId = params.taskId;
    const LOGGER_TAG = TAG + CheckInTriggerMap.COMMIT_USER_CHECKIN + ' ';
    try {
      const record = new CheckInRecord();
      record.setUserId(this.userId);
      record.setTaskId(taskId);
      record.setActivityId(activityId);
      record.setTextDetail(params.textDetail);
      record.setPictureDetail(JSON.stringify(params.pictureDetail ?? []));
      record.setAudioDetail(JSON.stringify(params.audioDetail ?? []));
      record.setVideoDetail(JSON.stringify(params.videoDetail ?? []));
      record.setCreateTime(new Date());
      record.setRecordId(`${this.userId}_${activityId}_${taskId}`);
      const res = await this.recordList.upsert(record);
      if (res) {
        this.logger.info(LOGGER_TAG + ` create record finished`);
        // 更新task状态
        const updateRes = await this._updateTaskStatus(activityId, taskId);
      }

      return res;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async getUserCheckInRecordList(params: GetUserCheckInRecordListReq) {
    const activityId = params.activityId;
    const LOGGER_TAG = TAG + CheckInTriggerMap.GET_USER_CHECKIN_RECORD_LIST + ' ';
    try {
      let recordQuery: CloudDBZoneQuery<CheckInRecord> = this.recordList
        .query()
        .orderByAsc('activityId')
        .equalTo('userId', this.userId)
        .equalTo('activityId', activityId);
      const listResp = this._createRecordRespList(recordQuery);
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  private async _createActivityRespList(query: CloudDBZoneQuery<UserCheckInActivity>) {
    const LOGGER_TAG = TAG + '[create activity resp list]';
    try {
      const userData = await query.get();
      const totalCount: number = await query.countQuery('activityId');
      const listResp: ListResp<CheckInActivityResp> = new ListResp<CheckInActivityResp>(0, 0, []);
      if (!userData.length) {
        return listResp;
      }
      userData.forEach((item: UserCheckInActivity) => {
        const activityResp: CheckInActivityResp = this._createActivityRespItem(item);
        listResp.list.push(activityResp);
      });
      listResp.totalCount = totalCount;
      listResp.returnCount = totalCount;
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  private _createActivityRespItem(item: UserCheckInActivity): CheckInActivityResp {
    const res: CheckInActivityResp = {
      activityId: item.getActivityId(),
      name: item.getName(),
      summary: item.getSummary(),
      detail: item.getDetail(),
      mainDiagram: item.getMainDiagram(),
      price: item.getPrice(),
      orderTime: item.getOrderTime(),
      status: item.getStatus(),
      requirement: JSON.parse(item.getRequirement() ?? '{}'),
      participationCount: item.getParticipationCount(),
      historyCount: item.getHistoryCount(),
      taskDirectory: JSON.parse(item.getTaskDirectory() ?? '{}'),
    };
    return res;
  }

  private async _createUserCheckInActivityList(userId: string) {
    try {
      const initActivityList = await this.activityList.query().get();
      const upsertData: UserCheckInActivity[] = [];
      if (initActivityList.length) {
        initActivityList.forEach((activity: CheckInActivity) => {
          const userItem = new UserCheckInActivity();
          userItem.setId(`${activity.activityId}_${userId}`);
          userItem.setActivityId(activity.activityId);
          userItem.setUserId(userId);
          userItem.setName(activity.name);
          userItem.setSummary(activity.summary);
          userItem.setDetail(activity.detail);
          userItem.setMainDiagram(activity.mainDiagram);
          userItem.setPrice(activity.price);
          userItem.setRequirement(activity.requirement);
          userItem.setStatus(1);
          userItem.setOrderTime('');
          userItem.setTaskDirectory(activity.taskDirectory);
          userItem.setParticipationCount(activity.participationCount);
          userItem.setHistoryCount(activity.historyCount);
          upsertData.push(userItem);
        });
        const res = await this.userActivityList.upsert(upsertData);
        this.logger.info(TAG, `init user activity list,list length is ${res}`);
      }
    } catch (err) {
      this.logger.error(TAG + `init user course list failed. errpr: ${err}`);
    }
  }

  private async _createRecordRespList(query: CloudDBZoneQuery<CheckInRecord>) {
    const LOGGER_TAG = TAG + '[create record resp list]';
    try {
      const recordList = await query.get();
      const totalCount: number = await query.countQuery('activityId');
      const listResp: ListResp<RecordResp> = new ListResp<RecordResp>(0, 0, []);
      if (!recordList.length) {
        return listResp;
      }
      recordList.forEach((item: CheckInRecord) => {
        const recordResp: RecordResp = this._createRecordRespItem(item);
        listResp.list.push(recordResp);
      });
      listResp.totalCount = totalCount;
      listResp.returnCount = totalCount;
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  private _createRecordRespItem(item: CheckInRecord): RecordResp {
    const res: RecordResp = {
      activityId: item.getActivityId(),
      taskId: item.getTaskId(),
      textDetail: item.getTextDetail(),
      pictureDetail: JSON.parse(item.getPictureDetail()),
      audioDetail: JSON.parse(item.getAudioDetail()),
      videoDetail: JSON.parse(item.getVideoDetail()),
      createTime: new Date(item.getCreateTime()).getTime().toString(),
    };
    return res;
  }

  private async _updateTaskStatus(activityId: number, taskId: number) {
    const LOGGER_TAG = TAG + '[update task status]';
    try {
      const activityQuery = this.userActivityList
        .query()
        .orderByAsc('activityId')
        .equalTo('userId', this.userId)
        .equalTo('activityId', activityId);
      const activityData = await activityQuery.get();
      if (activityData.length === 1) {
        const activityResource = activityData[0];
        const taskDirectory: CheckInTaskItem[] = JSON.parse(activityResource.getTaskDirectory() ?? '[]');
        if (taskDirectory.length) {
          taskDirectory.forEach((item) => {
            if (item.taskId === taskId) {
              item.taskStatus = 2;
            }
          });
        }
        const operator = CloudDBZoneObjectOperator.build(activityResource).update(
          'taskDirectory',
          JSON.stringify(taskDirectory),
        );
        const res = await this.userActivityList.update(operator);
        this.logger.info(LOGGER_TAG, 'update task status success');
        return res;
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }
}
