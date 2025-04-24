export class Constants {
  public static readonly TAB_BACKGROUND_COLOR: ResourceColor = Color.Pink
  public static readonly CARD_BACKGROUND_COLOR: ResourceColor = Color.White
  public static readonly TAB_CONTENT_BACKGROUND_COLOR: ResourceColor = Color.Gray
  public static readonly TAB_CONTENT_FOREGROUND_COLOR: ResourceColor = Color.White
  public static readonly COMMON_BAR_BACKGROUND_COLOR: ResourceColor = Color.White
  public static readonly CUSTOM_DIALOG_BACKGROUND_COLOR: ResourceColor = Color.White
  public static readonly NAV_DESTINATION_BACKGROUND_COLOR: ResourceColor = '#F1F3F5'
  public static readonly PAGE_MARGIN_TOP: number = 16
  public static readonly TEXT_INPUT_BACKGROUND_COLOR: ResourceColor = '#F1F3F5'
}

export class ConnectionState {
  static STATE_CONNECTING = 1;
  static STATE_CONNECTED = 2;
  static STATE_DISCONNECTING = 3;
  static STATE_DISCONNECTED = 4;
}