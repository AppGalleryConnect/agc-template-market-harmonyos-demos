import { UtilLog } from '@hw-agconnect/util-log';
import { buffer, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { WorkerDataMessage, WorkerMessage } from '../model/Worker';
import { common } from '@kit.AbilityKit';
import { KinshipDictionary, KinshipMap } from '../model/Data';
import { expandSelector } from '../utils/ExpandSelector';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

let mapData: KinshipMap = {}

workerPort.onmessage = (event: MessageEvents) => {
  const data = event.data as WorkerMessage
  getRawFileJsonData(data.context)
}

function getRawFileJsonData(context: common.UIAbilityContext) {
  try {
    let mainValue: Uint8Array = context.resourceManager.getRawFileContentSync('main.json');
    let mainStr = buffer.from(mainValue.buffer).toString();
    let main: KinshipMap = JSON.parse(mainStr)
    let prefixValue: Uint8Array = context.resourceManager.getRawFileContentSync('prefix.json');
    let prefixStr = buffer.from(prefixValue.buffer).toString();
    let prefix: KinshipDictionary = JSON.parse(prefixStr)
    let branchValue: Uint8Array = context.resourceManager.getRawFileContentSync('branch.json');
    let branchStr = buffer.from(branchValue.buffer).toString();
    let branch: KinshipMap = JSON.parse(branchStr)
    setMapData(main, prefix, branch)
  } catch (e) {
    UtilLog.error(`getRawFileJsonData failed with error ${JSON.stringify(e)}`)
  }
}

function setMapData(data: KinshipMap, prefix: KinshipDictionary, branch: KinshipMap) {
  mapData = data
  setBranchData(prefix, branch)
}

function setBranchData(prefix: KinshipDictionary, branch: KinshipMap) {
  // 分支 - 前缀处理
  const prefixMap: KinshipMap = {}
  const prefixKeys = Object.keys(prefix)
  prefixKeys.forEach((key) => {
    Reflect.set(prefixMap, key, {})
    const selectors = Object.keys(prefix[key])
    selectors.forEach((selector) => {
      expandSelector(selector).forEach((s) => {
        prefixMap[key][s] = prefix[key][selector]
      });
    })
  })

  // 分支 - 节点处理
  const branchMap: KinshipMap = {}
  const branchKeys = Object.keys(branch)
  branchKeys.forEach((key) => {
    expandSelector(key).forEach((s) => {
      branchMap[s] = branch[key];
    });
  })

  getMap(prefixMap, branchMap)
}

function getMap(prefixMap: KinshipMap, branchMap: KinshipMap) {
  const map: KinshipMap = {}
  const branchKeys = Object.keys(branchMap)
  branchKeys.forEach((key) => {
    const arr = key.match(/\{.+?\}/) ?? ['']
    const tag = arr[0]
    const nameList = branchMap[key]
    const prefixKeys = Object.keys(prefixMap[tag])
    prefixKeys.forEach((k) => {
      const prefixList: string[] = prefixMap[tag][k]
      const newKey = key.replace(tag, k)
      const isFilter = ['h,h', 'w,w', 'w,h', 'h,w'].some(pair => (newKey.includes(pair)))
      if (!isFilter) {
        const newList = prefixList.flatMap((prefix) =>
        nameList.map((name) => (name.includes('?') ? name.replace('?', prefix) : prefix + name)),
        );
        if (!map[newKey]) {
          map[newKey] = mapData[newKey] || [];
        }
        map[newKey] = newList.concat(map[newKey]);
      }
    })
  })
  const mapKeys = Object.keys(map)
  mapKeys.forEach((key) => {
    mapData[key] = map[key]
  })

  workerPort.postMessage({
    data: mapData,
  } as WorkerDataMessage)
};