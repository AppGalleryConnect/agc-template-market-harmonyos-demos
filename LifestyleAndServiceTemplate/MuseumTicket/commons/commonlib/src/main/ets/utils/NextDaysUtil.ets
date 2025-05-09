type day = '星期日' | '星期一' | '星期二' | '星期三' | '星期四' | '星期五' | '星期六';

export interface DateInfo {
  date: Date;
  day: day;
}


export function getNextDays(nextDay: number): DateInfo[] {
  const result: DateInfo[] = [];
  const today = new Date();

  const WEEKDAYS = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

  for (let i = 0; i < nextDay; i++) {
    // 创建新的日期对象避免污染原日期
    const date = new Date(today);
    date.setDate(today.getDate() + i);
    // 通过类型断言确保星期值合法
    const dayOfWeek = WEEKDAYS[date.getDay()] as day;

    result.push({ date: date, day: dayOfWeek });
  }

  return result;
}

