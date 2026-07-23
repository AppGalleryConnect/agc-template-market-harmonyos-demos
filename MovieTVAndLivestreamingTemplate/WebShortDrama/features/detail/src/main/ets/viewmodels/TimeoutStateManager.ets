import { TimeoutPersistence, TimeoutState } from '../viewdata/TimeoutPersistence'

@ObservedV2
export class TimeoutStateManager {
  @Trace private dramaId: string = ''
  @Trace private remainTime: number = 0
  @Trace private isCheck: boolean = false
  @Trace private itemName: string = ''

  static instance(): TimeoutStateManager {
    return new TimeoutStateManager()
  }

  static getInstance(): TimeoutStateManager {
    return TimeoutStateManager.instance()
  }

  setDramaId(dramaId: string): void {
    this.dramaId = dramaId
  }

  getDramaId(): string {
    return this.dramaId
  }

  getRemainTime(): number {
    return this.remainTime
  }

  setRemainTime(time: number): void {
    this.remainTime = time
  }

  getIsCheck(): boolean {
    return this.isCheck
  }

  setIsCheck(check: boolean): void {
    this.isCheck = check
  }

  getItemName(): string {
    return this.itemName
  }

  setItemName(name: string): void {
    this.itemName = name
  }

  hasActiveTimeout(): boolean {
    return this.isCheck && this.remainTime > 0
  }

  saveState(): void {
    if (this.dramaId && this.hasActiveTimeout()) {
      let expireTime = Date.now() + (this.remainTime * 1000)
      TimeoutPersistence.saveTimeoutState(this.dramaId, {
        dramaId: this.dramaId,
        itemName: this.itemName,
        expireTime: expireTime,
        isActive: this.isCheck,
        createdAt: Date.now()
      })
    }
  }

  loadState(dramaId: string): TimeoutState | null {
    return TimeoutPersistence.loadTimeoutState(dramaId)
  }

  clearState(): void {
    if (this.dramaId) {
      TimeoutPersistence.clearTimeoutState(this.dramaId)
    }
  }

  restoreTimeout(dramaId: string): boolean {
    const state = this.loadState(dramaId)
    if (state && state.isActive && state.expireTime > Date.now()) {
      this.dramaId = dramaId
      this.itemName = state.itemName
      let remainMs = state.expireTime - Date.now()
      this.remainTime = Math.ceil(remainMs / 1000)
      this.isCheck = state.isActive
      return true
    }
    return false
  }

  hasActiveTimeoutForDrama(dramaId: string): boolean {
    const state = this.loadState(dramaId)
    return state !== null && state.isActive && state.expireTime > Date.now()
  }

  clearTimeout(): void {
    this.remainTime = 0
    this.isCheck = false
    this.itemName = ''
  }

  formatTime(seconds: number): string {
    const hours: number = Math.floor(seconds / 3600)
    const minutes: number = Math.floor((seconds % 3600) / 60)
    const secs: number = seconds % 60
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
  }
}