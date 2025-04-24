import { CloudDbZoneWrapper } from './CloudDBZoneWrapper';

let myHandler = async function (event, context, callback, logger) {
    logger.info(event);
    let result;
    let operation=event.body?JSON.parse(event.body).operation:event.operation;
    let serviceType =event.body?JSON.parse(event.body).serviceType:event.serviceType;
    let cloudDBZoneWrapper = new CloudDbZoneWrapper();
    switch (operation) {
        case "query":
            result = await cloudDBZoneWrapper.queryServiceList(serviceType);
            break;
        default:
            return callback({
                ret: {
                    code: -1,
                    desc: "no such operation"
                }
            });
    }
    logger.info('result: ' + JSON.stringify(result))
    return callback({
        ret: { code: 0, desc: "SUCCESS" },
        result
    });
};

export { myHandler };