export class ErrorMessage {
  code: number = 0
  message: string = ''

  constructor(code: number, message: string) {
    this.code = code
    this.message = message
  }
}
