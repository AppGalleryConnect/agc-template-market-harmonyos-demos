import { common } from '@kit.AbilityKit';

let context: common.UIAbilityContext;

export const setContext = (context: common.UIAbilityContext) => {
  context = context;
}

export const getContextInstance = (): common.UIAbilityContext => {
  return context;
}