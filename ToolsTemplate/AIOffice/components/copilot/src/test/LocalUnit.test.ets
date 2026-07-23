import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import {
  TextMessage,
  MessageRole,
  MessageType,
  MessageStatusCode,
  MessageStatus
} from '../main/ets/model/Messages';
import { messagesToJson, jsonToMessages } from '../main/ets/utils/utils';
import { ChatCompletionChunk, ChatCompletionStreamChoiceDelta } from '../main/ets/openai/Index';

export default function localUnitTest() {
  describe('ThinkingModeTest', () => {
    beforeAll(() => {
    });
    beforeEach(() => {
    });
    afterEach(() => {
    });
    afterAll(() => {
    });

    it('TextMessage_with_thinkingContent', 0, () => {
      const textMessage = new TextMessage({
        role: MessageRole.ASSISTANT,
        content: '这是最终回答',
        thinkingContent: '这是思考过程'
      });
      expect(textMessage.content).assertEqual('这是最终回答');
      expect(textMessage.thinkingContent).assertEqual('这是思考过程');
      expect(textMessage.type).assertEqual(MessageType.TextMessage);
      expect(textMessage.role).assertEqual(MessageRole.ASSISTANT);
    });

    it('TextMessage_without_thinkingContent', 0, () => {
      const textMessage = new TextMessage({
        role: MessageRole.ASSISTANT,
        content: '这是最终回答'
      });
      expect(textMessage.content).assertEqual('这是最终回答');
      expect(textMessage.thinkingContent).assertUndefined();
    });

    it('TextMessage_empty_thinkingContent', 0, () => {
      const textMessage = new TextMessage({
        role: MessageRole.ASSISTANT,
        content: '这是最终回答',
        thinkingContent: ''
      });
      expect(textMessage.content).assertEqual('这是最终回答');
      expect(textMessage.thinkingContent).assertEqual('');
    });

    it('messagesToJson_with_thinkingContent', 0, () => {
      const textMessage = new TextMessage({
        role: MessageRole.ASSISTANT,
        content: '最终回答',
        thinkingContent: '思考过程'
      });
      const json = messagesToJson([textMessage]);
      expect(json).assertContain('思考过程');
      expect(json).assertContain('最终回答');
    });

    it('jsonToMessages_with_thinkingContent', 0, () => {
      const textMessage = new TextMessage({
        role: MessageRole.ASSISTANT,
        content: '最终回答',
        thinkingContent: '思考过程'
      });
      const json = messagesToJson([textMessage]);
      const messages = jsonToMessages(json);
      expect(messages.length).assertEqual(1);
      expect(messages[0].isTextMessage()).assertTrue();
      const restored = messages[0] as TextMessage;
      expect(restored.content).assertEqual('最终回答');
      expect(restored.thinkingContent).assertEqual('思考过程');
    });

    it('jsonToMessages_without_thinkingContent', 0, () => {
      const textMessage = new TextMessage({
        role: MessageRole.ASSISTANT,
        content: '最终回答'
      });
      const json = messagesToJson([textMessage]);
      const messages = jsonToMessages(json);
      expect(messages.length).assertEqual(1);
      const restored = messages[0] as TextMessage;
      expect(restored.content).assertEqual('最终回答');
      expect(restored.thinkingContent).assertUndefined();
    });

    it('ChatCompletionStreamChoiceDelta_has_reasoning_content', 0, () => {
      const delta: ChatCompletionStreamChoiceDelta = {
        reasoning_content: '思考内容片段',
        content: '回答内容'
      };
      expect(delta.reasoning_content).assertEqual('思考内容片段');
      expect(delta.content).assertEqual('回答内容');
    });

    it('ChatCompletionStreamChoiceDelta_reasoning_content_null', 0, () => {
      const delta: ChatCompletionStreamChoiceDelta = {
        content: '仅回答内容'
      };
      expect(delta.reasoning_content).assertUndefined();
    });

    it('ChatCompletionChunk_structure', 0, () => {
      const chunk: ChatCompletionChunk = {
        id: 'chatcmpl-123',
        object: 'chat.completion.chunk',
        created: 1234567890,
        model: 'deepseek-chat',
        choices: [{
          index: 0,
          delta: {
            reasoning_content: '思考中...',
            content: '回答中...'
          },
          finish_reason: null
        }]
      };
      expect(chunk.choices[0].delta.reasoning_content).assertEqual('思考中...');
      expect(chunk.choices[0].delta.content).assertEqual('回答中...');
    });
  });
}
