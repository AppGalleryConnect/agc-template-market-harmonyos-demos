import { Logger } from './Logger';

export class NormalizedError extends Error {

  public code?: number;

  public data?: ESObject;

  public static from(cause: ESObject): NormalizedError {
    if (cause === null || cause === undefined) {
      return new NormalizedError();
    }
    if (typeof cause === 'object') {
      let msg: string | undefined = undefined;
      let code: number | undefined = undefined;
      let data: ESObject = cause.data;
      if (typeof cause.message === 'string') {
        msg = cause.message;
      }
      if (typeof cause.code === 'number') {
        code = cause.code;
      }
      const err: NormalizedError = new NormalizedError(msg, code, data);
      if (typeof cause.stack === 'string') {
        err.stack = cause.stack;
      }
      if (typeof cause.name === 'string') {
        err.name = cause.name;
      }
      return err;
    }
    return new NormalizedError(String(cause));
  }

  public static logAndThrow(cause: ESObject): never {
    const err: NormalizedError = NormalizedError.from(cause);
    Logger.error(err.toLogLine());
    throw err;
  }

  public toLogLine(): string {
    const name: string = this.name ?? NormalizedError.name;
    if (this.code || this.code === 0) {
      return `${name}: code=${this.code} msg=${this.message}`;
    } else {
      return `${name}: ${this.message}`;
    }
  }

  constructor(message?: string, code?: number, data?: ESObject) {
    super(message);
    this.code = code;
    this.data = data;
    this.name = NormalizedError.name;
  }
}
