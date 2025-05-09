import { CheckInTriggerMap } from './constants';
import { DatabaseHelper } from './DatabaseHelper';

const TAG = '[check-in-activity]';

let myHandler = async function (event, context, callback, logger) {
  logger.info(event);
  let userId: string = event.body ? JSON.parse(event.body).userId : event.userId;
  let trigger: string = event.body ? JSON.parse(event.body).trigger : event.trigger;
  if (!userId) {
    callback({
      ret: {
        code: -1,
        message: TAG + 'userId is empty',
      },
    });
    return;
  }
  const params = event.body ? JSON.parse(event.body) : event;
  let result;
  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger, userId);
    switch (trigger) {
      case CheckInTriggerMap.GET_CHECKIN_ACTIVITY_LIST:
        result = await databaseHelper.getCheckInActivityList();
        break;
      case CheckInTriggerMap.GET_CHECKIN_ACTIVITY_DETAIL:
        result = await databaseHelper.getCheckInActivityDetail(params);
        break;
      case CheckInTriggerMap.CREATE_CHECKIN_ACTIVITY_ORDER:
        result = await databaseHelper.createCheckInActivityOrder(params);
        break;
      case CheckInTriggerMap.CANCEL_CHECKIN_ACTIVITY_ORDER:
        result = await databaseHelper.cancelCheckInActivityOrder(params);
        break;
      case CheckInTriggerMap.GET_CHECKIN_ACTIVITY_LIST_ORDERED:
        result = await databaseHelper.getActivityListOrdered();
        break;
      case CheckInTriggerMap.COMMIT_USER_CHECKIN:
        result = await databaseHelper.commitUserCheckIn(params);
        break;
      case CheckInTriggerMap.GET_USER_CHECKIN_RECORD_LIST:
        result = await databaseHelper.getUserCheckInRecordList(params);
        break;
      default:
        return callback({
          ret: {
            code: -1,
            message: 'no such operation',
          },
        });
    }
    if (result) {
      callback({
        ret: {
          code: 0,
          message: TAG + 'request successful',
        },
        result,
      });
    } else {
      callback({
        ret: {
          code: 1,
          message: TAG + ' request failed',
        },
        data: null,
      });
    }
  } catch (err) {
    logger.error(TAG, ` func error: ${err.message}`);
    callback({
      ret: {
        code: 3,
        message: TAG + 'operation exception',
      },
    });
  }
};

export { myHandler };
