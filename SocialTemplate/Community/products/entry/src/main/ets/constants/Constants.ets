import { AddressBookPageBuilder } from 'address_book';
import { MessageListPageBuilder } from 'message';
import { MinePageBuilder } from 'person';
import { TabSingleItem } from '../viewmodels/TabSingleItem';

export const TAB_CONFIG: TabSingleItem[] = [
  {
    label: $r('app.string.message_tab_title'),
    index: 0,
    fontColor: '#66000000',
    fontColorActive: '#564AF7',
    icon: $r('app.media.message_tab'),
    iconActive: $r('app.media.message_tab_active'),
    component: wrapBuilder(MessageListPageBuilder),
  },
  {
    label: $r('app.string.address_book_tab_title'),
    index: 1,
    fontColor: '#66000000',
    fontColorActive: '#564AF7',
    icon: $r('app.media.address_book_tab'),
    iconActive: $r('app.media.address_book_tab_active'),
    component: wrapBuilder(AddressBookPageBuilder),
  },
  {
    label: $r('app.string.person_tab_title'),
    index: 2,
    fontColor: '#66000000',
    fontColorActive: '#564AF7',
    icon: $r('app.media.person_tab'),
    iconActive: $r('app.media.person_tab_active'),
    component: wrapBuilder(MinePageBuilder),
  },
];