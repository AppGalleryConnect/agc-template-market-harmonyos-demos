import { CourseTriggerMap } from './constants';
import { DatabaseHelper } from './DatabaseHelper';

const TAG = '[course]';

let myHandler = async function (event, context, callback, logger) {
  logger.info(event);
  logger.info(context);
  let userId: string = event.body ? JSON.parse(event.body).userId : event.userId;
  let trigger: string = event.body ? JSON.parse(event.body).trigger : event.trigger;

  const params = event.body ? JSON.parse(event.body) : event;
  let result;
  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger, userId);
    if (!trigger) {
      result = await databaseHelper.getStoreConfig();
    } else {
      if (!userId) {
        callback({
          ret: {
            code: 1,
            message: TAG + 'userId is empty',
          },
        });
        return;
      }
      switch (trigger) {
        case CourseTriggerMap.GET_COURSE_LIST:
          result = await databaseHelper.getCourseList(params);
          break;
        case CourseTriggerMap.GET_COURSE_DETAIL:
          result = await databaseHelper.getCourseInfoDetail(params);
          break;
        case CourseTriggerMap.GET_COURSE_LIST_ORDERED:
          result = await databaseHelper.getCourseInfoListOrdered(params);
          break;
        default:
          return callback({
            ret: {
              code: -1,
              message: 'no such operation',
            },
          });
      }
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
