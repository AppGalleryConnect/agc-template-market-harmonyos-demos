@ObservedV2
export class CountdownModel {
  @Trace
  countdown: number = 0;
  private _endTimestamp: number;
  private _countdownTimer: number = -1;

  constructor(endTimestamp: number) {
    this._endTimestamp = endTimestamp;
  }

  @Computed
  get countdownLabelArr() {
    if (this.countdown < 0) {
      this.countdown = 0;
      return ['00', '00', '00'];
    }
    const hours = Math.floor(this.countdown / 3600);
    const minutes = Math.floor((this.countdown % 3600) / 60);
    const seconds = this.countdown % 60;
    const formattedHours = String(hours).padStart(2, '0');
    const formattedMinutes = String(minutes).padStart(2, '0');
    const formattedSeconds = String(seconds).padStart(2, '0');
    return [formattedHours, formattedMinutes, formattedSeconds];
  }

  @Computed
  get countdownLabel() {
    if (this.countdown < 0) {
      this.countdown = 0;
      return '00:00:00';
    }
    const hours = Math.floor(this.countdown / 3600);
    const minutes = Math.floor((this.countdown % 3600) / 60);
    const seconds = this.countdown % 60;
    const formattedHours = String(hours).padStart(2, '0');
    const formattedMinutes = String(minutes).padStart(2, '0');
    const formattedSeconds = String(seconds).padStart(2, '0');
    return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
  }

  startCountdownTimer() {
    this.updateCountdown();
    this._countdownTimer = setInterval(() => {
      this.updateCountdown();
    }, 1000);
  }

  stopCountdownTimer() {
    this.countdown = 0;
    if (this._countdownTimer >= 0) {
      clearInterval(this._countdownTimer);
      this._countdownTimer = -1;
    }
  }

  updateCountdown() {
    const now = Date.now();
    if (now <= this._endTimestamp) {
      // 距离结束
      this.countdown = Math.floor((this._endTimestamp - now) / 1000);
    } else {
      // 已结束
      this.countdown = 0;
      if (this._countdownTimer >= 0) {
        clearInterval(this._countdownTimer);
        this._countdownTimer = -1;
      }
    }
  }
}