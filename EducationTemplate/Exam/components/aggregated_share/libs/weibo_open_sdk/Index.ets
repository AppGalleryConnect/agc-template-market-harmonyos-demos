import { common, Want } from '@kit.AbilityKit';

export interface IWBAPI {
  registerApp: (authInfo: AuthInfo, listener?: SdkListener) => void;
  authorize: (context: common.UIAbilityContext, listener: WbASListener) => void;
  authorizeClient: (context: common.UIAbilityContext, listener: WbASListener) => void;
  authorizeWeb: (listener: WbASListener) => void;
  shareMessage: (context: common.UIAbilityContext, message: WeiboMultiMessage, listener: WbASListener) => void;
  doWBAsResult: (want: Want, context: common.UIAbilityContext) => boolean;
}

export class WBAPI {
  private constructor() {
  };

  static _instance: IWBAPI = {
    registerApp: (authInfo: AuthInfo, listener?: SdkListener) => {
    },
    authorize: (context: common.UIAbilityContext, listener: WbASListener) => {
    },
    authorizeClient: (context: common.UIAbilityContext, listener: WbASListener) => {
    },
    authorizeWeb: (listener: WbASListener) => {
    },
    shareMessage: (context: common.UIAbilityContext, message: WeiboMultiMessage, listener: WbASListener) => {
    },
    doWBAsResult: (want: Want, context: common.UIAbilityContext) => true,
  } as IWBAPI;

  static getInstance(): IWBAPI {
    return WBAPI._instance;
  };
}

export interface SdkListener {
  onInitSuccess: Function;
  onInitFail: Function;
}

export class WeiboMultiMessage {
  textObject: TextObject | null = null;
  multiImageObject: MultiImageObject | null = null;
  videoSourceObject: VideoSourceObject | null = null;
}

export class TextObject {
  text: string = '';
}

export class MultiImageObject {
  uriStrs: string[] | null = [];
}

export class VideoSourceObject {
  coverPath: string = '';
  videoPath: string = '';
}

export class AuthInfo {
  constructor(context: Context, d2: string, e2: string, scope: string, f2?: boolean) {
  }

  getHash(): string {
    return '';
  };
}

export interface WbASListener {
  onComplete: Function;
  onError: Function;
  onCancel: Function;
}

export class UiError {
  errorCode: number = 0;
  errorMessage: string = '';
  errorDetail: string = '';

  constructor(errorCode: number, errorMessage: string, o6: string) {
  };
}

export class FileUtils {
  static _instance: FileUtils;

  static getInstance(): FileUtils {
    return FileUtils._instance;
  };

  createFile(path: string): number {
    return 0;
  };

  deleteFile(path: string): void {
  };

  copyFile(w11: string, x11: string): void {
  };

  uint8ArrayToBuffer(array: Uint8Array): ArrayBuffer {
    return new ArrayBuffer(10);
  };
}

export class WeiboLogger {
  static logEnable: boolean = false;

  constructor(prefix: string) {
  };

  debug(...args: (number | string | boolean | null | undefined)[]): void {
  };

  info(...args: (number | string | boolean | null | undefined)[]): void {
  };

  warn(...args: (number | string | boolean | null | undefined)[]): void {
  };

  error(...args: (number | string | boolean | null | undefined)[]): void {
  };

  fatal(...args: (number | string | boolean | null | undefined)[]): void {
  };
}

export class Utility {
  getSign(a14?: boolean): Promise<string> {
    return Promise.resolve('')
  };
}