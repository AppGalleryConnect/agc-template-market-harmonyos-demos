import { InsightIntentExecutor, insightIntent } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

/**
 * Entry for insight intent execution.
 */
export default class IntentExecutorImpl extends InsightIntentExecutor {
  /**
   * Called when a UIAbility executes the insight intent in the foreground.
   * @param { string } intentName - Indicates the insight intent name.
   * @param { Record<string, Object> } intentParam - Indicates the insight intent parameters.
   * @param { window.WindowStage } pageLoader - Indicates the page loader.
   * @returns { Promise<insightIntent.ExecuteResult> } The result of insight intent execution.
   */
  async onExecuteInUIAbilityForegroundMode(intentName: string, intentParam: Record<string, object>,
    pageLoader: window.WindowStage): Promise<insightIntent.ExecuteResult> {
    const result: insightIntent.ExecuteResult = {
      code: 0,
    };
    return Promise.resolve(result);
  }

  /**
   * Called when a UIAbility executes the insight intent in the foreground.
   * @param { string } intentName - Indicates the insight intent name.
   * @param { Record<string, Object> } intentParam - Indicates the insight intent parameters.
   * @returns { Promise<insightIntent.ExecuteResult> } The result of insight intent execution.
   */
  async onExecuteInUIAbilityBackgroundMode(intentName: string, intentParam: Record<string, object>):
    Promise<insightIntent.ExecuteResult> {
    const result: insightIntent.ExecuteResult = {
      code: 0,
    };
    return Promise.resolve(result);
  }
}