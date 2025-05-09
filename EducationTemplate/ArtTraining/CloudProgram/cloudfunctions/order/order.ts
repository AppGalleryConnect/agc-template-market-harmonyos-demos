import { OrderTriggerMap } from './constants';
import { DatabaseHelper } from './DatabaseHelper';

const TAG = '[order]';

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
      case OrderTriggerMap.CREATE_COURSE_ORDER:
        result = await databaseHelper.createCourseOrder(params);
        break;
      case OrderTriggerMap.CANCEL_COURSE_ORDER:
        result = await databaseHelper.cancelCourseOrder(params);
        break;
      case OrderTriggerMap.REQUEST_REFUND_COURSE_ORDER:
        result = await databaseHelper.requestRefundCourseOrder(params);
        break;
      case OrderTriggerMap.CANCEL_REFUND_COURSE_ORDER:
        result = await databaseHelper.cancelRefundCourseOrder(params);
        break;
      case OrderTriggerMap.DELETE_COURSE_ORDER:
        result = await databaseHelper.deleteCourseOrder(params);
        break;
      case OrderTriggerMap.GET_ORDER_LIST:
        result = await databaseHelper.getOrderList(params);
        break;
      case OrderTriggerMap.GET_ORDER_DETAIL:
        result = await databaseHelper.getOrderDetail(params);
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
          code: 2,
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
