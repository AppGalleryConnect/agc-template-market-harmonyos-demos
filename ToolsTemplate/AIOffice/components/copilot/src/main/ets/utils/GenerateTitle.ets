import { CopilotClient } from '../client/CopilotClient';
import { Message, MessageRole, TextMessage } from '../model/Messages';

interface GeneratedObjectLiteralInterface_1 {
  threadId: string;
  content: string;
}

export async function generateTitle(threadId: string, messages: Message[], client: CopilotClient) {
  let systemPrompt =
    '你需要根据如下的聊天记录总结生成一段简短的标题，标题的长度不超过20个字，要能明确表达聊天记录的内容，并且不能和历史标题有重复。';
  let historyMsg = '聊天记录如下：';
  messages.forEach((msg) => {
    if (msg.isTextMessage()) {
      let text = msg as TextMessage;
      historyMsg += `{角色：${text.role}, 内容：${text.content} } \n`;
    }
  })
  let prompt = `${systemPrompt}\n${historyMsg}`;

  try {
    let response = await client.chat({
      messages: [new TextMessage({
        role: MessageRole.USER,
        content: prompt,
      })]
    });
    if (response.messages.length > 0 && response.messages[0].isTextMessage()) {
      let textMsg = response.messages[0] as TextMessage;
      return ({ threadId: threadId, content: textMsg.content } as GeneratedObjectLiteralInterface_1);
    } else {
      throw new Error('generate title fail');
    }
  } catch (error) {
    throw new Error('generate title fail');
  }

}