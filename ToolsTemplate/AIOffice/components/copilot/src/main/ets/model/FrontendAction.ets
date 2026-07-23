import { Parameter } from './Parameter';
import { actionParametersToJsonSchema } from './JSONSchema';
import { ActionInput } from '../client/CopilotClient';

export type RenderFunctionStatus = 'inProgress' | 'executing' | 'complete'

export interface ActionRenderProps {
  status: RenderFunctionStatus;
  args: Record<string, ESObject>;
  result?: ESObject
}

export interface ActionWaitRenderProps extends ActionRenderProps  {
  respond: (result: string) => void;
  reject: (error: Error) => void;
}

export interface FrontendAction {
  name: string;
  description?: string;
  available?: 'disabled' | 'enabled';
  followUp?: boolean;
  parameters?: Parameter[];
  handler?: (props: Record<string, ESObject>) => Promise<ESObject>;
  render?: WrappedBuilder<[ActionRenderProps]>;
  //可交互组件
  renderAndWaitForResponse?: WrappedBuilder<[ActionWaitRenderProps]>;
}

export function processActionsForRuntimeRequest(actions: FrontendAction[]) {
  const filteredActions: ActionInput[] = actions
    .filter(
      (action) =>
      action.available !== 'disabled' &&
        action.name !== '*'
    )
    .map((action) => {
      return {
        name: action.name,
        description: action.description || '',
        jsonSchema: JSON.stringify(actionParametersToJsonSchema(action.parameters || [])),
        available: action.available,
      } as ActionInput;
    });
  return filteredActions;
}
