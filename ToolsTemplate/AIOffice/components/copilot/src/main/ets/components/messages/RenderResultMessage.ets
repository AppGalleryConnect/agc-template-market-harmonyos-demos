import { ResultMessage } from '../../model/Messages';
import { CopilotChatOptions } from '../CopilotChatOptions';


@ComponentV2
export struct RenderResultMessage {
  @Param options: CopilotChatOptions = {};
  @Param @Require message : ResultMessage;

  build() {

  }
}