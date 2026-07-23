import { ImageMessage } from '../../model/Messages';
import { CopilotChatOptions } from '../CopilotChatOptions';


@ComponentV2
export struct RenderImageMessage {
  @Param options: CopilotChatOptions = {};
  @Param @Require message : ImageMessage;

  build() {

  }
}