@ObservedV2
export class CaloriesSummaryVM {
  @Trace currentIndex: number = 1;
  @Trace xData: string[] = ['周一', '周二', '周三', '周四', '周五', '周二', '周日'];
  gradientColor: LinearGradient =
    new LinearGradient([{ color: '#C6F093', offset: 0.25 }, { color: '#83CE26', offset: 0.5 },
      { color: '#88DB23', offset: 0.85 }, { color: '#88DB24', offset: 1.0 }])

  changeTabs(index: number) {
    this.currentIndex = index
  }
}