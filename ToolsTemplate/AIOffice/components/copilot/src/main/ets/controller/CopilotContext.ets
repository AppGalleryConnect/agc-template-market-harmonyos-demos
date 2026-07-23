import { CopilotControllerOptions } from './CopilotControllerOptions';
import { Message } from '../model/Messages';
import { util } from '@kit.ArkTS';
import { FrontendAction } from '../model/FrontendAction';

@ObservedV2
export class CopilotContext {
  threadId: string;
  @Trace isLoading: boolean = false;
  @Trace visibleMessages: Message[] = [];
  @Trace title?: string;
  createTime: number;

  actions: FrontendAction[] = [];

  constructor(options: CopilotControllerOptions) {
    this.threadId = options.threadId ?? util.generateRandomUUID();
    this.title = options.title;
    this.createTime = Date.now();
  }

  reset() {
    this.threadId = util.generateRandomUUID();
    this.isLoading = false;
    this.visibleMessages = [];
    this.title = undefined;
    this.createTime = Date.now();
  }

  /**
   * 注册一个Action
   */
  registerAction(action: FrontendAction) {
    // 检查是否已存在同名action
    const existingIndex = this.actions.findIndex(a => a.name === action.name);
    if (existingIndex >= 0) {
      // 替换已存在的action
      this.actions[existingIndex] = action;
      console.warn(`替换已存在的Action: ${action.name}`);
    } else {
      // 添加新action
      this.actions.push(action);
    }
  }

  getAction(actionName: string): FrontendAction | undefined {
    return this.actions.find(a => a.name === actionName);
  }

  getAvailableActions(): FrontendAction[] {
    return this.actions.filter(a => a.available !== 'disabled');
  }
}