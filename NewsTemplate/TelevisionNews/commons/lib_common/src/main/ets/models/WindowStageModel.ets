import { window } from '@kit.ArkUI';


@ObservedV2
export class WindowStageModel {
  // WindowStage生命周期变化的监听事件
  @Trace windowStageEventListeners: Map<string, (type: window.WindowStageEventType) => void> = new Map();
}