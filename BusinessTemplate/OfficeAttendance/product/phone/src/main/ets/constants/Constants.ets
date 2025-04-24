import { TabListItem } from '@ohos_agcit/office_attendance_agency'

export const TAB_LIST: TabListItem[] = [
  {
    label: $r('app.string.attendance'),
    icon: $r('app.media.attendance'),
    iconChecked: $r('app.media.attendance_checked'),
    titleBackgroundColor: Color.White
  },
  {
  label: $r('app.string.agency_task'),
  icon: $r('app.media.agency_task'),
  iconChecked: $r('app.media.agency_task_checked'),
  titleBackgroundColor: Color.White
  },
  {
    label: $r('app.string.schedule'),
    icon: $r('app.media.schedule'),
    iconChecked: $r('app.media.schedule_checked'),
    titleBackgroundColor: Color.White
  },
  {
    label: $r('app.string.mine'),
    icon: $r('app.media.mine_unchecked'),
    iconChecked: $r('app.media.mine_checked'),
    titleBackgroundColor: $r('app.color.title_background_color')
  }
];