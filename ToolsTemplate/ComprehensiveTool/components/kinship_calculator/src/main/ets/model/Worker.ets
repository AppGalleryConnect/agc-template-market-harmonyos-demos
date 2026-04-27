import { common } from '@kit.AbilityKit';
import { KinshipMap } from './Data';

export interface WorkerMessage {
  context: common.UIAbilityContext
}

export interface WorkerDataMessage {
  data: KinshipMap
}