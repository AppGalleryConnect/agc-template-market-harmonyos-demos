import { AccountTriggerMap } from './constants';
import { DatabaseHelper } from './utils/DatabaseHelper';

const TAG = '[account-management]';

let myHandler = async function (event, context, callback, logger) {
  logger.info(event);
  let userId: string = event.body ? JSON.parse(event.body).userId : event.userId;
  let trigger: string = event.body ? JSON.parse(event.body).trigger : event.trigger;
  if (!userId) {
    callback({
      ret: {
        code: 1,
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
      case AccountTriggerMap.BIND_PHONE:
        result = await databaseHelper.bindPhone(params);
        break;
      case AccountTriggerMap.UNBIND_PHONE:
        result = await databaseHelper.unbindPhone();
        break;
      case AccountTriggerMap.GET_INFO:
        result = await databaseHelper.getUserInfo();
        break;
      case AccountTriggerMap.UPDATE_INFO:
        result = await databaseHelper.updateUserInfo(params);
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
