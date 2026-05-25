import { formProvider } from '@kit.FormKit'

export { MockService, VIDEO_URL } from './src/main/ets/Service/MockService'

export { CourseDetailModel,
  CourseBookingInfo,
  CoachCourseInfo,
  CardInfo,
  UserCard,
  BookingRecordInfo,
  BookingInfo,
  BookState,
  OrderInfo,
  Account,
  OrderState,
  OrderType,
  SportTypeEnum,
  SportType,
  TeachType,
  ConsumeType,
  UserCourse } from './src/main/ets/model/MockModel'

export { DateUtil } from './src/main/ets/Service/DateUtil'

// 断点
export {
  BreakpointTypeOptions,
  BreakpointType,
  BreakpointNameEnum,
  BreakpointValueEnum,
  GridRowColSetting,
  GridSettingInfo
} from './src/main/ets/constant/GridRowColSetting';

export { CommonConstants } from './src/main/ets/constant/CommonConstants';

export { ScreenPropStorage,
  LoginState,
  JumpLogin,
  AccountUpdate,
  GlobalBalance,
  BookJumpSearch,
  BookingRestQuotaUpdate,
  ClearPath,
  ListLength
} from  './src/main/ets/constant/ClassConstant'

export { BreakpointModel } from './src/main/ets/model/BreakpointModel';

export { BreakpointUtils } from './src/main/ets/model/BreakpointUtils';

export {
  EmitterConstant
} from './src/main/ets/constant/EmitterConstant'

export { getCalendarPermission } from './src/main/ets/utils/CalendarUtil'

export { BaseViewModel } from './src/main/ets/model/BaseViewModel'
export { Logger } from './src/main/ets/utils/Logger';
export { WindowUtil } from './src/main/ets/utils/WindowUtil'
export * from './src/main/ets/utils/PreferenceUtil'
export { FormDataClass, CardManager } from './src/main/ets/utils/CardManager'
export { AppPrivacyUtils } from './src/main/ets/utils/AppPrivacyUtils'