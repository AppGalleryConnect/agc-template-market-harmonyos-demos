let myHandler = async function (event, context, callback, logger) {
    logger.info(`Input event: ${JSON.stringify(event)}`);

    let hmSystem = {
        status: 1,
        msg: 'success',
        storeId: '26',
        storeType: 1
    }
    logger.info(`hmSystem: ${hmSystem}`);
    let tableTitleArr = [{
        id: '1',
        name: '1号桌',
        typeName: '1人桌',
        num: '1',
        status: '0'
    }, {
        id: '2',
        name: '2号桌',
        typeName: '2人桌',
        num: '2',
        status: '0'
    }, {
        id: '3',
        name: '3号桌',
        typeName: '3人桌',
        num: '3',
        status: '0'
    }, {
        id: '4',
        name: '4号桌',
        typeName: '4人桌',
        num: '4',
        status: '0'
    }, {
        id: '5',
        name: '5号桌',
        typeName: '5人桌',
        num: '5',
        status: '0'
    }, {
        id: '6',
        name: '6号桌',
        typeName: '6人桌',
        num: '6',
        status: '0'
    }, {
        id: '7',
        name: '7号桌',
        typeName: '7人桌',
        num: '7',
        status: '0'
    }, {
        id: '8',
        name: '8号桌',
        typeName: '8人桌',
        num: '8',
        status: '0'
    }, {
        id: '9',
        name: '9号桌',
        typeName: '9人桌',
        num: '9',
        status: '0'
    }, {
        id: '10',
        name: '10号桌',
        typeName: '10人桌',
        num: '10',
        status: '0'
    }]
    logger.info(`tableTitleArr: ${tableTitleArr}`);
    let result = {hmSystem,tableTitleArr}
    let res = new context.HTTPResponse(result, {
        "faas-content-type": "json"
    }, "application/json", "200");

    callback(res);
};

module.exports.myHandler = myHandler;