export enum MusicPlayMode {
  SINGLE_CYCLE = 0,
  ORDER = 1,
  RANDOM = 2
}

export enum AudioPlayerState {
  IDLE,
  INITIALIZED,
  LOAD,
  PREPARED,
  PLAY,
  PAUSE,
  STOP,
  ERROR,
  COMPLETED,
  RELEASED,
  PROGRESS_SPEED,
  TIME_UPDATE,
  VOLUME_CHANGE,
  UNKNOWN
}

export const SECOND_BUFFER_WALK = 48000 * 2 * 2;

export const SELECT_MUSIC_INDEX = 'selectIndex';

export const TOTAL_MS_NUMBER_NUMBER_DURATION = 'totalMsDuration';

export const TOTAL_TIME_STRING_NUMBER_DURATION = 'totalTimeDuration';

export const SILENT_ID = 'silentId';

export class Options {
  offset?: number;
  length?: number;
}


