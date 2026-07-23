import { ActionExecutionMessage, MessageStatusCode } from '../../model/Messages';
import { AssistantMessageCard } from './AssistantMessageCard';
import { CopilotContext } from '../../controller/CopilotContext';
import { FrontendAction, RenderFunctionStatus } from '../../model/FrontendAction';
import { CopilotChatOptions } from '../CopilotChatOptions';

@ComponentV2
export struct RenderActionExecutionMessage {
  @Param options: CopilotChatOptions = {};
  @Param @Require message: ActionExecutionMessage;
  @Param @Require context: CopilotContext;
  @Param isCurrentMessage: boolean = false;
  @Param inProgress: boolean = false;
  @Param result?: ESObject = undefined;
  frontAction?: FrontendAction = undefined

  aboutToAppear(): void {
    this.frontAction = this.context.getAction(this.message.name);
  }

  build() {
    AssistantMessageCard({
      options: this.options,
      message: this.message,
      subComponent: () => {
        this.subComponentBuilder();
      }
    })
  }

  @Builder
  subComponentBuilder() {
    if (this.frontAction?.render) {
      this.buildCustomActionRender();
    } else if (this.frontAction?.renderAndWaitForResponse) {
      this.buildWaitActionRender();
    } else if (this.options.isShowDefaultActionCard) {
      this.defaultActionCard();
    }
  }

  @Builder
  buildCustomActionRender() {
    this.frontAction?.render!.builder({
      status: this.getRenderStatus(),
      args: this.message.args,
      result: this.result
    });
  }

  @Builder
  buildWaitActionRender() {
    this.frontAction?.renderAndWaitForResponse!.builder({
      status: this.getRenderStatus(),
      args: this.message.args,
      respond:(result: ESObject)=>{
        this.message._waitPromiseResolve(result);
      },
      reject:(error: Error) => {
        this.message._waitPromiseReject(error);
      },
      result: this.result
    })
  }

  getRenderStatus(): RenderFunctionStatus {
    let status: RenderFunctionStatus = 'inProgress';
    if (this.result !== undefined) {
      status = 'complete'
    } else if (this.message.status.code !== MessageStatusCode.Pending) {
      status = 'executing'
    }
    return status;
  }

  @Builder
  defaultActionCard() {
    Text(`工具执行：${this.message.name}`)
      .height(44)
      .fontColor('#666666')
  }
}