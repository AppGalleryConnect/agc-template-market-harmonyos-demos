/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Obtain the error message.
 * @param error BusinessError.
 */
function getErrorHint(error: BusinessError): string {
  const mainErrorMessage: string = error.message.split('.').shift() as string;
  return `${error.code}: ${mainErrorMessage}.`;
}

/**
 * Display the toast message based on the prompt character string or BusinessError.
 * @param error Prompt character string or BusinessError.
 */
export function showToast(error: BusinessError | string) {
  const message: string = typeof error === 'string' ? error : getErrorHint(error);
  promptAction.showToast({
    message,
    duration: 2000
  });
}
