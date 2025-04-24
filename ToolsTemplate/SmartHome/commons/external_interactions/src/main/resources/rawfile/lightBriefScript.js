const lightStatus = document.querySelector('.light-status');

let send2ets = {
    type: "",
    payload: ""
}

let publish = {
    topic: "",
    payload: ""
};

let subscribe = {
    topic: ""
};

let globalConnectState = 'off'

function publishTopic(topic, payload) {
    publish.topic = topic
    publish.payload = payload

    send2ets.type = "publish"
    send2ets.payload = JSON.stringify(publish)

    postMsgToEts(JSON.stringify(send2ets))
}

function addDeviceMessageRecord(message) {
    send2ets.type = "record"
    send2ets.payload = message

    postMsgToEts(JSON.stringify(send2ets))
}

function updateDeviceBriefStateText(message) {
    send2ets.type = "state"
    send2ets.payload = message

    postMsgToEts(JSON.stringify(send2ets))
}

function addDeviceConnectStateRecord(message) {
    if (message === 'on') {
        addDeviceMessageRecord("灯上线")
        updateDeviceBriefStateText("状态：上线")
    } else {
        addDeviceMessageRecord("灯离线")
        updateDeviceBriefStateText("状态：离线")
    }
}

function updateDeviceConnectState(message) {
    if (globalConnectState === message) {
        return
    }
    globalConnectState = message

    send2ets.type = "connect"
    send2ets.payload = message
    postMsgToEts(JSON.stringify(send2ets))

    addDeviceConnectStateRecord(message)
}

function subscribeTopic(topic) {
    subscribe.topic = topic

    send2ets.type = "subscribe"
    send2ets.payload = JSON.stringify(subscribe)

    postMsgToEts(JSON.stringify(send2ets))
}

function setLightOn() {
    lightStatus.classList.replace('light-off', 'light-on');
    lightStatus.textContent = '开';
}

function setLightOff() {
    lightStatus.classList.replace('light-on', 'light-off');
    lightStatus.textContent = '关';
}

function handleStateMessage(payload) {
    updateDeviceConnectState('on')

    state = payload.onOff
    console.error('[lightHtml]handleStateMessage:' + state)
    if (state === 'on') {
        setLightOn()
        addDeviceMessageRecord("灯打开")
        updateDeviceBriefStateText("状态：开")
    } else {
        setLightOff()
        addDeviceMessageRecord("灯关闭")
        updateDeviceBriefStateText("状态：关")
    }
}

let h5BriefPort;
window.addEventListener('message', function (event) {
    if (event.data === '__init_port__') {
        if (event.ports[0] !== null) {
            h5BriefPort = event.ports[0];
            h5BriefPort.onmessage = function (event) {
                let result = event.data;
                handleMsgFromEts(result)
            }
        }
    }
})

function handleDeviceMqttBrokerConnectStateMessage(payload) {
    state = payload.onOff
    if (state === 'off') {
        updateDeviceConnectState('off')
        lightImage.src = 'light_off.svg'
    }
}

function handleLocalMqttBrokerConnectedMessage(payload) {
    state = payload.onOff
    if (state === 'on') {
        addDeviceMessageRecord("mqtt连接成功")

        subscribeTopic('light/$deviceUuid/state')
        subscribeTopic('light/$deviceUuid/connect')
        publishTopic('light/$deviceUuid/getState', '')
    } else {
        addDeviceMessageRecord("mqtt连接断开")
        lightImage.src = 'light_off.svg'
    }
}

function handleMsgFromEts(data) {
    console.error('[lightBriefHtml]receive message from ets: ' + data)
    const message = JSON.parse(data)
    const topic = message.topic

    console.error('[lightBriefHtml]payload: ' + message.payload)

    const payload = JSON.parse(message.payload)

    console.error('[lightBriefHtml]topic:' + topic)
    console.error('[lightBriefHtml]payload: ' + payload)

    if (topic === 'light/$deviceUuid/state') {
        handleStateMessage(payload)
    } else if (topic === 'light/$deviceUuid/connect') {
        handleDeviceMqttBrokerConnectStateMessage(payload)
    } else if (topic === 'local/connect') {
        handleLocalMqttBrokerConnectedMessage(payload)
    }
}

// 3. 使用h5BriefPort向应用侧发送消息。
function postMsgToEts(data) {
    if (h5BriefPort) {
        h5BriefPort.postMessage(data);
    } else {
        console.error('h5BriefPort is null, Please initialize first');
    }
}