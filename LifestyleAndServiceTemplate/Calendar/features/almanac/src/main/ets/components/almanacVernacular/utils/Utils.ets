export function convertToEmperorEra(date: string): number {
  let year = new Date(date).getFullYear()
  return year + 2697;
}

export function fullDateTransfer(date: string): string {
  let year = date.split('-')[0]
  let month = date.split('-')[1]
  let day =date.split('-')[2]
  return `${year}年${month}月${day}日`;
}