import { CloudDbZoneWrapper } from './CloudDBZoneWrapper';

let myHandler = async function (event, context, callback, logger) {
    logger.info(event);
    let result;
    let operation=event.body?JSON.parse(event.body).operation:event.operation;
    let authorizationCode=event.body?JSON.parse(event.body).authorizationCode:event.authorizationCode;
    logger.info('authorizationCode: ' + JSON.stringify(authorizationCode))
    let cloudDBZoneWrapper = new CloudDbZoneWrapper();
    switch (operation) {
        case "query":
            result = await cloudDBZoneWrapper.queryUserInfo(authorizationCode,logger);
            break;
        case "upsert":
            // result = await cloudDBZoneWrapper.upsertTickets(records);
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