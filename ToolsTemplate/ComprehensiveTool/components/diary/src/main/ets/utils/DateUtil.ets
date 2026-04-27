export class DateUtil {
  static dateTimeFormat(value: TimePickerResult) {
    let hour: string = value.hour.toString()
    let minute: string = value.minute.toString()
    if (value.hour < 10) {
      hour = '0' + value.hour
    }
    if (value.minute < 10) {
      minute = '0' + value.minute
    }
    return hour + ':' + minute
  }
}