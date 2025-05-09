export enum RouterPageEnum {
  MINE = 'MinePage',
  CITY_SELECTION_PAGE = 'CitySelectionPage',
  WEB_PAGE = 'WebPage',
  FLIGHT_LIST_PAGE = 'FlightListPage',
  FLIGHT_SEARCH_LIST_PAGE = 'FlightSearchListPage',
  FLIGHT_TRACK_INFO_PAGE = 'FlightTrackInfoPage',
  FLIGHT_NUM_LIST_PAGE = 'FlightNumListPage',
  FLIGHT_DETAIL_PAGE = 'FlightDetailPage',
  CALENDAR_PAGE = 'CalendarPage',
  SUBMIT_ORDER_PAGE = 'SubmitOrderPage',
  SELECT_PASSENGER_PAGE = 'SelectPassengerPage',
  ADD_PASSENGER_PAGE = 'AddPassengerPage',
  ORDER_DETAIL_PAGE = 'OrderDetailPage',
  PAY_PAGE = 'PayPage',
  ITINERARY_DETAIL_PAGE = 'ItineraryDetailPage',
  USER_INFO_SETTING_PAGE = 'UserInfoSettingPage',
  ORDER_CENTER_PAGE = 'OrderCenterPage',
  PASSENGER_LIST_PAGE = 'PassengerListPage',
  SETTING_PAGE = 'SettingPage',
}

export enum LoadingStatus {
  OFF = 'off',
  EMPTY = 'empty',
  LOADING = 'loading',
  SUCCESS = 'success',
  FAILED = 'failed'
}

export enum LocationType {
  DEPARTURE = 'departure',
  DESTINATION = 'destination'
}

/**
 * 自定义日历类型：MONTH月视图 WEEK周视图
 */
export enum CalendarViewType {
  MONTH, // 月视图
  WEEK, // 周视图
}

export enum CardMap {
  'idCard' ='身份证',
  'Hukou'='户口簿',
  'passport' = '护照',
  'taiwan' = '台胞证',
  'hkMacau' = '港澳台居民居住证',
}

