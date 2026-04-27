export enum ErrorCode {
  // The agreements are not accepted.
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  // No HUAWEI ID has been signed in.
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // This HUAWEI ID does not support one-tap sign-in as it is a child account or not registered in the Chinese mainland.
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  // The operation for obtaining the shipping address is canceled.
  SHIPPING_ADDRESS_USER_CANCELED = 1008100006,
  // Authorization revoking is performed.
  AUTHENTICATION_USER_CANCELED = 1001502012,
  // The operation for obtaining the invoice title is canceled.
  INVOICE_ASSISTANT_USER_CANCELED = 1010060001,
  // A network exception occurred in the API for obtaining the shipping address.
  SHIPPING_ADDRESS_NETWORK_ERROR = 1008100002,
  // A network exception occurs in the authorization API.
  AUTHENTICATION_NETWORK_ERROR = 1001502005,
  // A network exception occurred in the API for obtaining the invoice title.
  INVOICE_ASSISTANT_NETWORK_ERROR = 1010060005
}
