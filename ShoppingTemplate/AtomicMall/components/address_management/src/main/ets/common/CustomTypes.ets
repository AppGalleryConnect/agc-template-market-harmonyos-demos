import { AddressDTO } from '../models/AddressDTO';

export enum Operation {
  CREATE,
  EDIT
}

export enum BreakpointType {
  XS = 'xs',
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
  XXL = 'xxl'
}

export enum ShippingAddressErrorCode {
  INTERNAL_ERROR = 1008100001,
  NETWORK_ERROR = 1008100002,
  ACCOUNT_NOT_LOGGED_IN = 1008100003,
  PACKAGE_FINGERPRINT_CHECK_ERROR = 1008100004,
  PERMISSION_CHECK_ERROR = 1008100005,
  USER_CANCELED = 1008100006,
  UNSUPPORTED = 1008100007
}

export interface AddressManagementOptions {
  onAddressSelected?: Callback<AddressDTO>;
  updateAddress?: Callback<AddressDTO>;
  deleteAddress?: Callback<AddressDTO>;
}
