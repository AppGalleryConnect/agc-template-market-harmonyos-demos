import { BookInfo } from './Book'

export interface BorrowInfo {
  id: string // 借阅 id
  borrowBegin: number // 借出时间 ms
  borrowEnd: number // 归还时间 ms
  borrowNum: number // 借阅数量
  borrowDeadline: number // 借阅期限
  status: number // 借书状态，0 已归还，1 未归还， 2 逾期
  statusInfo: StatusInfo
  borrowBooks?: Array<BookInfo> // 借阅书籍
}

export class StatusInfo {
  public status: number;
  public statusText: ResourceStr;
  public statusColor: ResourceColor;

  constructor(status: number) {
    this.status = status;
    this.statusText = this.getBorrowStatus(status);
    this.statusColor = this.getBorrowFontColor(status);
  }

  getBorrowStatus(status: number): ResourceStr {
    if (status === BorrowStatus.RETURNED) {
      return $r('app.string.borrow_returned')
    } else if (status === BorrowStatus.BORROWING) {
      return $r('app.string.borrowing')
    } else {
      return $r('app.string.borrow_overdue')
    }
  }

  getBorrowFontColor(status: number) {
    if (status === BorrowStatus.RETURNED) {
      return $r('app.color.font_returned')
    } else if (status === BorrowStatus.BORROWING) {
      return $r('app.color.font_borrowing')
    } else {
      return $r('app.color.font_overdue')
    }
  }
}

export enum BorrowStatus {
  RETURNED,
  BORROWING,
  OVERDUE,
}
