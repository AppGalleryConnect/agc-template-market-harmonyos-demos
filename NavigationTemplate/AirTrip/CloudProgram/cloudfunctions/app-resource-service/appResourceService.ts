import { CloudDbZoneWrapper } from './CloudDBZoneWrapper';

let myHandler = async function (event, context, callback, logger) {
  let result;
  let cloudDBZoneWrapper = new CloudDbZoneWrapper();
  result = await cloudDBZoneWrapper.queryResourceData();
  return callback({
    ret: { code: 0, desc: "SUCCESS" },
    result
  });
};

export { myHandler };