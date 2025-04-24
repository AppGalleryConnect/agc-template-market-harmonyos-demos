import { BusinessError } from '@kit.BasicServicesKit';

/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
export enum ErrorCode {
  // No HUAWEI ID has been signed in.
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // A network exception occurs in the authorization API.
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  // Internal error.
  ERROR_CODE_INTERNAL_ERROR = 1001502009,
  // Authorization revoking is performed.
  ERROR_CODE_USER_CANCEL = 1001502012,
  // System service exception.
  ERROR_CODE_SYSTEM_SERVICE = 12300001,
  // The agreements are not accepted.
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  // Repeated request.
  ERROR_CODE_REQUEST_REFUSE = 1001500002
}

export function dealAllError(error: BusinessError): void {
  // In app sign-in scenarios involving UI interactions,
  // it is recommended to guide users with the following error code prompts:
  if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
    // The user has not signed in with a HUAWEI ID.
    // Use a HUAWEI ID to sign in and try again, or sign in to the app in another way.
  } else if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
    // Network exception. Check the current network status and try again, or sign in to the app in another way.
  } else if (error.code === ErrorCode.ERROR_CODE_INTERNAL_ERROR) {
    // Sign-in failed. Try another sign-in option.
  } else if (error.code === ErrorCode.ERROR_CODE_USER_CANCEL) {
    // The user cancels the authorization.
  } else if (error.code === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
    // System service exception. Try again later or sign in to the app in another way.
  } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
    // The user does not accept the agreements.
  } else if (error.code === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
    // Repeated request. No further action is needed.
  } else {
    // Sign-in failed. Try another sign-in option.
  }
}
