export enum AVPlayerState {
  /**
   * Idle state of avPlayer.
   */
  IDLE = 'idle',

  /**
   * Initialized state of avPlayer.
   */
  INITIALIZED = 'initialized',

  /**
   * Prepared state of avPlayer.
   */
  PREPARED = 'prepared',

  /**
   * Playing state of avPlayer.
   */
  PLAYING = 'playing',

  /**
   * Pause state of avPlayer.
   */
  PAUSED = 'paused',

  /**
   * Completed state of avPlayer.
   */
  COMPLETED = 'completed',

  /**
   * Stopped state of avPlayer.
   */
  STOPPED = 'stopped',

  /**
   * Release state of avPlayer.
   */
  RELEASED = 'released',

  /**
   * Error state of avPlayer.
   */
  ERROR = 'error'
}


export class CommonConstants {
  /**
   * Track Thickness size min
   */
  static readonly TRACK_SIZE_MIN: number = 4;
  /**
   * Track Thickness borderRadius
   */
  static readonly TRACK_BORDER_RADIUS: number = 2;
  /**
   * Track Thickness size max
   */
  static readonly TRACK_SIZE_MAX: number = 6;
  /**
   * Timer interval number
   */
  static readonly TIMER_INTERVAL: number = 100;
  /**
   * The surface width
   */
  static readonly SURFACE_WIDTH: number = 1920;
  /**
   * The surface height
   */
  static readonly SURFACE_HEIGHT: number = 1080;
  /**
   * Slider step
   */
  static readonly SLIDER_STEP: number = 0.1;
  /**
   * Slider min
   */
  static readonly SLIDER_MIN: number = 0;
  /**
   * Slider index
   */
  static readonly SLIDER_INDEX: number = 3;
  /**
   * Seek hour unit
   */
  static readonly HOUR_UNIT: number = 60;
  /**
   * Second to Millisecond
   */
  static readonly SECOND_TO_MS: number = 1000;
  /**
   * Time const number
   */
  static readonly TIME_CONST_TEN: number = 10;
  /**
   * Duration time
   */
  static readonly DURATION_TIME: number = 300;
  /**
   *  Video aspect
   */
  static readonly ASPECT: number = 16 / 9;
  /**
   *  Cast playing initial
   */
  static readonly PLAYBACK_STATE_INITIAL: number = 0;
  /**
   *  Cast playing prepare
   */
  static readonly PLAYBACK_STATE_PREPARE: number = 1;
  /**
   *  Cast playing pause
   */
  static readonly PLAYBACK_STATE_PAUSE: number = 3;
  /**
   *  Cast playing stop
   */
  static readonly PLAYBACK_STATE_STOP: number = 6;
  /**
   *  Cast playing play
   */
  static readonly PLAYBACK_STATE_PLAY: number = 2;
}