const light = document.querySelector('.light');
const status = document.getElementById('status');
const toggleSwitch = document.getElementById('toggleSwitch');
const lightStatus = document.querySelector('.light-status');
let isOn = false;

const DataType = {
    PUBLISH: 'publish',
    RECORD: 'record'
};

let send2ets = {
    type: "",
    payload: ""
}

let publish = {
    topic: "",
    payload: ""
};

let publishPayload = {
    lightSwitch: ""
};

toggleSwitch.addEventListener('change', function() {
    if (this.checked) {
        console.log("开关已打开");
        publishLightSwitch("on")
    } else {
        console.log("开关已关闭");
        publishLightSwitch("off")
    }
});

function publishLightSwitch(onOff) {
    publishPayload.lightSwitch = onOff

    publish.topic = 'light/$deviceUuid/cmd'
    publish.payload = JSON.stringify(publishPayload)

    send2ets.type = "publish"
    send2ets.payload = JSON.stringify(publish)

    postMsgToEts(JSON.stringify(send2ets))
}

let h5Port;
window.addEventListener('message', function (event) {
    if (event.data === '__init_port__') {
        if (event.ports[0] !== null) {
            h5Port = event.ports[0];
            h5Port.onmessage = function (event) {
                let result = event.data;
                handleMsgFromEts(result)
            }
        }
    }
})

function setLightOn() {
    lightStatus.classList.replace('light-off', 'light-on');
    lightStatus.textContent = '开';

    toggleSwitch.checked = true
}

function setLightOff() {
    lightStatus.classList.replace('light-on', 'light-off');
    lightStatus.textContent = '关';

    toggleSwitch.checked = false
}

function handleStateMessage(payload) {

    state = payload.onOff
    console.error('[lightHtml]handleStateMessage:' + state)
    if (state === 'on') {
        setLightOn()
    } else {
        setLightOff()
    }
}

function handleMsgFromEts(data) {
    console.error('[lightHtml]receive message from ets: ' + data)
    const message = JSON.parse(data)
    const topic = message.topic

    console.error('[lightHtml]payload: ' + message.payload)

    const payload = JSON.parse(message.payload)

    console.error('[lightHtml]topic:' + topic)
    console.error('[lightHtml]payload: ' + payload)

    if (topic === 'light/$deviceUuid/state') {
        handleStateMessage(payload)
    }
}

// 3. 使用h5Port向应用侧发送消息。
function postMsgToEts(data) {
    if (h5Port) {
        h5Port.postMessage(data);
    } else {
        console.error('h5Port is null, Please initialize first');
    }
}