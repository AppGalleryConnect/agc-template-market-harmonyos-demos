let bmiPathStack: NavPathStack;

export interface BmiRouteParams {
  recordId?: string;
}

let currentParams: BmiRouteParams = {};

export const setBmiNavPathStack = (bmiNavPathStack: NavPathStack) => {
  bmiPathStack = bmiNavPathStack;
}

export const getBmiNavPathStack = (): NavPathStack => {
  return bmiPathStack;
}

export const setRouteParams = (params: BmiRouteParams): void => {
  currentParams = {
    recordId: params.recordId
  };
}

export const getRouteParams = (): BmiRouteParams => {
  return {
    recordId: currentParams.recordId
  };
}

export const clearRouteParams = (): void => {
  currentParams = {};
}
