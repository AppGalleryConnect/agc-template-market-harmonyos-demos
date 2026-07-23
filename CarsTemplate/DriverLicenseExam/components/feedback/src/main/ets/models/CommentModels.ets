export interface CommentDialogConfig {
    // 间隔天数，默认3天
    intervalDays?: number;

    // 是否强制弹出
    forceShow?: boolean;
}

export interface CommentCallback {
    onSuccess?: () => void;
    onFailed?: (error: ErrorMessage) => void;
}

export class ErrorMessage {
    code: number;
    message: string;

    constructor(code: number, message: string) {
        this.code = code;
        this.message = message;
    }
}