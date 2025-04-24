import { CloudDbZoneWrapper } from './CloudDBZoneWrapper';

let myHandler = async function (event, context, callback, logger) {
  let result;
  let operation = event.body ? JSON.parse(event.body).operation : event.operation;
  let searchType = event.body ? JSON.parse(event.body).searchType : event.searchType;
  let refreshType = event.body ? JSON.parse(event.body).refreshType : event.refreshType;
  logger.info('searchType',searchType,'refreshType',refreshType)
  let cloudDBZoneWrapper = new CloudDbZoneWrapper();
  switch (operation) {
    case "query":
      result = await cloudDBZoneWrapper.queryUserInfo(searchType, refreshType,logger);
      break;
    default:
      return callback({
        ret: {
          code: -1,
          desc: "no such operation"
        }
      });
  }
  logger.info('result', result);
  return callback({
    ret: { code: 0, desc: "success" },
    result
  });
};

export { myHandler };