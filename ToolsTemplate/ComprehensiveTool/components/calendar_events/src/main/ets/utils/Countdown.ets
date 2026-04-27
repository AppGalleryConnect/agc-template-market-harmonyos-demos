import dayjs from 'dayjs';
import { UserEventItem } from '../model/UserEventModel';

@ObservedV2
export class Countdown {
  private intervalId: number | null = null;
  @Trace days: number = 0
  @Trace hours: number = 0
  @Trace minutes: number = 0
  @Trace seconds: number = 0
  @Trace timerID: number = -1
  @Trace currenTitle: string = ''

  private getNextBirthday(birthday: Date): Date {
    const today = new Date();
    const thisYearBirthday = new Date(
      today.getFullYear(),
      birthday.getMonth(),
      birthday.getDate(),
      birthday.getHours(),
      birthday.getMinutes(),
      birthday.getSeconds(),
    );

    return thisYearBirthday < today
      ? new Date(thisYearBirthday.getFullYear() + 1, thisYearBirthday.getMonth(), thisYearBirthday.getDate())
      : thisYearBirthday;
  }

  private updateCountdown(targetDate: Date): void {
    const now = new Date();
    const diff = targetDate.getTime() - now.getTime();
    if (diff <= 0) {
      targetDate = this.getNextBirthday(targetDate);
      this.updateCountdown(targetDate);
      return;
    }

    this.days = Math.floor(diff / (1000 * 60 * 60 * 24)) > 10 ? Math.floor(diff / (1000 * 60 * 60 * 24)) :
    Math.floor(diff / (1000 * 60 * 60 * 24));
    this.hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    this.minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    this.seconds = Math.floor((diff % (1000 * 60)) / 1000);
  }

  public startCountdown(target: UserEventItem): void {
    if (!target) {
      clearInterval(this.intervalId);
      return
    }
    let date = new Date(`${dayjs(target.date[0].date).format('YYYY-MM-DD')} ${target.date[0].time}`)
    this.currenTitle = target.content
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
    }
    this.intervalId = setInterval(() => this.updateCountdown(date), 1000);
  }

  public stopCountdown(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  public isToday(birthdayDate: Date): boolean {
    const today = new Date();
    const isSameMonth = today.getMonth() === birthdayDate.getMonth();
    const isSameDate = today.getDate() === birthdayDate.getDate();
    return isSameMonth && isSameDate;
  }
}